@echo off
rem One time (1 admin prompt): scheduled task "MyBotWatchdog" with highest privileges and no trigger,
rem so StartWatchdog.bat starts the watchdog (and the bots it starts) as admin without a prompt.
net session >nul 2>&1 || (powershell -NoProfile -Command "Start-Process -Verb RunAs -FilePath '%~f0'" & exit /b)
schtasks /create /f /tn MyBotWatchdog /rl HIGHEST /sc ONCE /st 00:00 /sd 01/01/2020 /it ^
 /tr "powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"%~dp0BotWatchdog.ps1\""
pause
