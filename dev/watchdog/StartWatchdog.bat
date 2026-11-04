@echo off
rem Starts the watchdog (task from InstallWatchdogTask.bat = no admin prompt). It starts both bots when they are not running.
schtasks /query /tn MyBotWatchdog >nul 2>&1 && (schtasks /run /tn MyBotWatchdog & exit /b)
echo Task MyBotWatchdog missing: run InstallWatchdogTask.bat once, or accept the admin prompt now.
powershell -NoProfile -Command "Start-Process -Verb RunAs powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0BotWatchdog.ps1\"'"
