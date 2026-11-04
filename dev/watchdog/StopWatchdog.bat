@echo off
rem Stops the watchdog only (the bots keep running).
schtasks /end /tn MyBotWatchdog >nul 2>&1
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='powershell.exe'\" | Where-Object { $_.CommandLine -like '*BotWatchdog.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }"
echo Watchdog stopped.
