# BotWatchdog.ps1: keeps both MyBot instances running (Windows PowerShell 5.1, run elevated via StartWatchdog.bat)
# Every minute, per instance:
#  - "AutoIt Error" dialog of the bot -> dialog text logged, bot killed, started again
#  - bot running but its newest profile log not written for $StallMin minutes -> killed, started again
#  - bot not running -> started again (not when the log ends with Bot Stop / Closing My Bot = closed by hand)
#  - restart-<n>.flag (written by the agent after a code fix) -> killed, started again
#  - pause.flag / pause-<n>.flag -> instance left alone
# First pass: a bot not running is started with its first profile (list $Inst below) even when it was closed by hand.
# After every start the watchdog waits (max $ReadyMin min) until that bot reaches the main screen, so bot 2 starts after bot 1.
# Started with the profile of the newest log = the account the bot was on (bot autostarts by its own setting), /ErrorStdOut
# (an AutoIt error goes to run\bot<n>_<time>.log and the bot exits instead of waiting on the dialog).

$ErrorActionPreference = 'Continue'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path # bot folder = 2 levels above this script (dev\watchdog)
$Dir = Join-Path $Root 'dev\watchdog'
$Run = Join-Path $Dir 'run'
$AutoIt = 'C:\Program Files (x86)\AutoIt3\AutoIt3.exe'
$StallMin = 5          # log silent this long = bot hung
$GraceMin = 5          # no stall check this long after a start
$MaxPerHour = 4        # max starts per instance in 1 h (restart loop = wait, the agent fixes the cause)
$ReadyMin = 4          # max wait after a start for the main screen before the next instance is handled

$Inst = @{
	1 = @{ Title = 'MuMuPlayerGlobal-12.0-1'; Profiles = @('zone', 'qurlk', 'qruel', 'quirk', 'qarelith', 'qassa') }
	2 = @{ Title = 'MuMuPlayerGlobal-12.0-2'; Profiles = @('qath', 'quartz', 'quazzy', 'qiralle', 'quiver', 'macia') }
}
foreach ($n in $Inst.Keys) { $Inst[$n].Started = [datetime]::MinValue; $Inst[$n].Restarts = @(); $Inst[$n].Note = '' }
# only-1.flag / only-2.flag (this device, from StartWatchdog-1.bat): only that instance is started and watched, the other is never touched
$Active = @(1, 2)
foreach ($n in @(1, 2)) { if (Test-Path (Join-Path $PSScriptRoot "only-$n.flag")) { $Active = @($n) } }

New-Item -ItemType Directory -Force $Run | Out-Null
$WLog = Join-Path $Run 'watchdog.log'
function W($s) { $l = '{0:yyyy-MM-dd HH:mm:ss} {1}' -f (Get-Date), $s; Add-Content -Path $WLog -Value $l; Write-Host $l }

# Telegram of the instance (token + chat id of the first profile with Telegram on, same bot for all its profiles):
# the bot cannot report its own crash / hang. Failure (no internet) is only logged, max 10 s
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$IcoWarn = [char]::ConvertFromUtf32(0x26A0); $IcoOk = [char]::ConvertFromUtf32(0x2705); $IcoBad = [char]::ConvertFromUtf32(0x274C)
function TG($n, $text) {
	foreach ($p in $Inst[$n].Profiles) {
		$c = Get-Content -Path (Join-Path $Root "Profiles\$p\config.ini") -Encoding Unicode -ErrorAction SilentlyContinue
		$v = @{}; foreach ($k in 'TGEnabled', 'TGToken', 'TGUserID') { $v[$k] = (($c | Where-Object { $_ -like "$k=*" } | Select-Object -First 1) -replace "^$k=", '') }
		if ($v.TGEnabled -ne '1' -or -not $v.TGToken -or -not $v.TGUserID) { continue }
		try {
			$body = [Text.Encoding]::UTF8.GetBytes((ConvertTo-Json @{ chat_id = $v.TGUserID; text = "MuMu-$n | $text" }))
			Invoke-RestMethod -Uri "https://api.telegram.org/bot$($v.TGToken)/sendMessage" -Method Post -Body $body `
				-ContentType 'application/json; charset=utf-8' -TimeoutSec 10 | Out-Null
		} catch { W "[$n] Telegram not sent: $($_.Exception.Message)" }
		return
	}
}

Add-Type @'
using System; using System.Text; using System.Collections.Generic; using System.Runtime.InteropServices;
public class WdWin {
	delegate bool EnumProc(IntPtr h, IntPtr l);
	[DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
	[DllImport("user32.dll")] static extern bool EnumChildWindows(IntPtr p, EnumProc f, IntPtr l);
	[DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
	[DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
	[DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
	static string Text(IntPtr h) { var sb = new StringBuilder(4096); GetWindowText(h, sb, 4096); return sb.ToString(); }
	// "pid<TAB>title<TAB>child texts" of every visible top-level window
	public static List<string> List() {
		var r = new List<string>();
		EnumWindows((h, l) => {
			if (!IsWindowVisible(h)) return true;
			uint pid; GetWindowThreadProcessId(h, out pid);
			string t = Text(h), c = "";
			if (t == "AutoIt Error") EnumChildWindows(h, (k, m) => { string s = Text(k); if (s != "") c += s.Replace("\r", " ").Replace("\n", " ") + " | "; return true; }, IntPtr.Zero);
			r.Add(pid + "\t" + t + "\t" + c); return true;
		}, IntPtr.Zero);
		return r;
	}
}
'@

function Get-Bots {
	# AutoIt3 processes running MyBot.run.au3 (not the Watchdog / MiniGui scripts): pid, profile, instance
	$out = @()
	foreach ($p in Get-CimInstance Win32_Process -Filter "Name like 'AutoIt3%'") {
		if ($p.CommandLine -notmatch 'MyBot\.run\.au3"?\s+"?([^\s"]+)') { continue }
		$prof = $Matches[1]
		foreach ($n in $Inst.Keys) { if ($Inst[$n].Profiles -contains $prof) { $out += [pscustomobject]@{ Pid = $p.ProcessId; Profile = $prof; N = $n } } }
	}
	# bot started some other way (no profile on its command line): by window title
	foreach ($w in [WdWin]::List()) {
		$f = $w -split "`t"
		foreach ($n in $Inst.Keys) {
			if ($f[1] -like "My Bot*$($Inst[$n].Title)*" -and -not ($out | Where-Object { $_.Pid -eq [int]$f[0] })) { $out += [pscustomobject]@{ Pid = [int]$f[0]; Profile = ''; N = $n } }
		}
	}
	return $out
}

function Get-NewestLog($n) {
	$files = foreach ($p in $Inst[$n].Profiles) { Get-ChildItem -Path (Join-Path $Root "Profiles\$p\Logs") -Filter '20*.log' -ErrorAction SilentlyContinue }
	# the folder listing keeps a stale LastWriteTime while the bot holds the log open: read it from the file itself
	$f = $files | ForEach-Object { [IO.FileInfo]$_.FullName } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if (-not $f) { return $null }
	$t = $f.LastWriteTime
	$last = Get-LogTime (Get-Content -Path $f.FullName -Tail 1 -ErrorAction SilentlyContinue)
	if ($last -and $last -gt $t) { $t = $last }
	return [pscustomobject]@{ File = $f.FullName; Profile = $f.Directory.Parent.Name; Age = ((Get-Date) - $t).TotalMinutes; Time = $t }
}

function Get-LogTime($line) {
	# "2: D [2026-11-02 21:27:30.060] ..." -> datetime
	if ("$line" -match '\[(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d)') { return [datetime]::ParseExact($Matches[1], 'yyyy-MM-dd HH:mm:ss', $null) }
	return $null
}

function Start-Bot($n, $prof, $why) {
	$now = Get-Date
	$Inst[$n].Restarts = @($Inst[$n].Restarts | Where-Object { ($now - $_).TotalMinutes -lt 60 })
	if ($Inst[$n].Restarts.Count -ge $MaxPerHour) {
		# restart loop (e.g. error at start): wait until the oldest restart is 1 h old, then try again
		$next = ($Inst[$n].Restarts | Sort-Object | Select-Object -First 1).AddMinutes(60)
		if ($Inst[$n].Note -ne 'wait') {
			W "[$n] RESTART LOOP: $MaxPerHour restarts in 1 h ($why), next try at $('{0:HH:mm}' -f $next)"; $Inst[$n].Note = 'wait'
			TG $n "$IcoBad RESTART LOOP: $MaxPerHour restarts in 1 h ($why), next try at $('{0:HH:mm}' -f $next)"
		}
		return
	}
	$out = Join-Path $Run ('bot{0}_{1:yyyyMMdd_HHmmss}.log' -f $n, $now)
	Start-Process -FilePath $AutoIt -WorkingDirectory $Root -RedirectStandardOutput $out -RedirectStandardError "$out.err" `
		-ArgumentList @('/ErrorStdOut', "`"$Root\MyBot.run.au3`"", $prof)
	$Inst[$n].Started = $now; $Inst[$n].Restarts += $now; $Inst[$n].Note = ''
	W "[$n] started with profile $prof ($why), output $out"
	if ($why -ne 'watchdog start') { TG $n "$IcoWarn restart $prof`n$why" }
	Wait-Ready $n $prof $now
}

function Wait-Ready($n, $prof, $since) {
	# main screen line written after the start in the newest log = MuMu + bot ready (a restart appends to the old log)
	while (((Get-Date) - $since).TotalMinutes -lt $ReadyMin) {
		Start-Sleep -Seconds 10
		$log = Get-NewestLog $n
		if (-not $log) { continue }
		$hit = Get-Content -Path $log.File -Tail 500 -ErrorAction SilentlyContinue | Select-String -SimpleMatch -Pattern 'checkMainScreen : MainVillage', 'MainScreen Located' |
			Where-Object { $tl = Get-LogTime $_.Line; $tl -and $tl -ge $since.AddSeconds(-2) }
		if ($hit) {
			$s = '{0:N0} s' -f ((Get-Date) - $since).TotalSeconds
			W "[$n] ready ($s)"; TG $n "$IcoOk ready $prof ($s)"; return
		}
	}
	W "[$n] not ready after $ReadyMin min, going on"; TG $n "$IcoBad not ready after $ReadyMin min ($prof)"
}

function Stop-Bot($bot, $why) {
	W "[$($bot.N)] kill pid $($bot.Pid) ($why)"
	Stop-Process -Id $bot.Pid -Force -ErrorAction SilentlyContinue
	Start-Sleep -Seconds 5
}

function Is-ClosedByHand($log) {
	# last lines of the newest log: Stop button or the bot window closed
	$tail = Get-Content -Path $log.File -Tail 30 -ErrorAction SilentlyContinue
	return [bool]($tail | Select-String -SimpleMatch -Pattern '===== Bot Stop =====', 'Closing My Bot')
}

W "watchdog started (instance $($Active -join ', '), stall $StallMin min, max $MaxPerHour restarts / h)"
$first = $true
while ($true) {
	$bots = Get-Bots
	$wins = [WdWin]::List()
	foreach ($n in $Active) {
		if ((Test-Path (Join-Path $Dir 'pause.flag')) -or (Test-Path (Join-Path $Dir "pause-$n.flag"))) { continue }
		$bot = $bots | Where-Object { $_.N -eq $n } | Select-Object -First 1
		$log = Get-NewestLog $n
		$prof = if ($log) { $log.Profile } else { $Inst[$n].Profiles[0] }

		# AutoIt Error dialog of this bot
		$err = $null
		if ($bot) { $err = $wins | Where-Object { ($_ -split "`t")[1] -eq 'AutoIt Error' -and [int](($_ -split "`t")[0]) -eq $bot.Pid } | Select-Object -First 1 }
		if ($err) {
			$etext = ($err -split "`t")[2]
			W "[$n] AUTOIT ERROR: $etext"
			Stop-Bot $bot 'AutoIt Error dialog'
			Start-Bot $n $prof ('AutoIt Error: ' + $(if ($etext.Length -gt 300) { $etext.Substring(0, 300) } else { $etext }))
			continue
		}

		$flag = Join-Path $Dir "restart-$n.flag"
		if (Test-Path $flag) {
			$reason = (Get-Content $flag -Raw -ErrorAction SilentlyContinue)
			Remove-Item $flag -Force
			# a bot closed by hand stays closed (3 Nov 11:35: user closed both, a waiting flag started them again)
			if (-not $bot -and $log -and (Is-ClosedByHand $log)) { W "[$n] restart request dropped: closed by hand ($reason)"; continue }
			if ($bot) { Stop-Bot $bot "restart requested: $reason" }
			Start-Bot $n $prof "restart requested: $reason"
			continue
		}

		if (-not $bot) {
			if ($first) { Start-Bot $n $Inst[$n].Profiles[0] 'watchdog start'; continue }
			if ($log -and (Is-ClosedByHand $log)) {
				if ($Inst[$n].Note -ne 'closed') { W "[$n] not running, closed by hand ($prof log), not started"; $Inst[$n].Note = 'closed' }
				continue
			}
			$tail = if ($log) { (Get-Content -Path $log.File -Tail 1 -ErrorAction SilentlyContinue) } else { '' }
			W "[$n] not running (last log line: $tail)"
			Start-Bot $n $prof 'bot not running'
			continue
		}

		if (-not $log -or ((Get-Date) - $Inst[$n].Started).TotalMinutes -lt $GraceMin) { continue }
		# MuMu reboot loop: the bot restarts MuMu by itself again and again, its log never goes silent (bot2 4 Nov 22:54-23:44,
		# "MuMu refuses to load" 19x, fixed by a bot restart) -> 3 of them in 30 min, after this bot start = restart the bot
		$since = (Get-Date).AddMinutes(-30)
		if ($Inst[$n].Started -gt $since) { $since = $Inst[$n].Started }
		$boot = @(Get-Content -Path $log.File -Tail 4000 -ErrorAction SilentlyContinue | Select-String -SimpleMatch -Pattern 'MuMu refuses to load' |
			Where-Object { $tl = Get-LogTime $_.Line; $tl -and $tl -ge $since })
		if ($boot.Count -ge 3) {
			W "[$n] MuMu boot loop: $($boot.Count)x 'MuMu refuses to load' since $('{0:HH:mm}' -f $since) ($prof)"
			Stop-Bot $bot 'MuMu boot loop'
			Start-Bot $n $prof 'MuMu boot loop'
			continue
		}
		if ($log.Age -ge $StallMin) {
			if (Is-ClosedByHand $log) {
				if ($Inst[$n].Note -ne 'stopped') { W "[$n] stopped with the Stop button ($prof), left alone"; $Inst[$n].Note = 'stopped' }
				continue
			}
			$tail = (Get-Content -Path $log.File -Tail 1 -ErrorAction SilentlyContinue)
			W ("[$n] log silent {0:N1} min ($prof, last line: $tail)" -f $log.Age)
			Stop-Bot $bot 'log silent'
			Start-Bot $n $prof 'log silent'
		}
		else { $Inst[$n].Note = '' }
	}
	$first = $false
	Start-Sleep -Seconds 60
}
