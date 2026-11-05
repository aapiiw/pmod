@echo off
rem Watchdog for instance 1 only (device with one MuMu): only-1.flag makes it skip instance 2. StartWatchdog.bat = both again.
echo 1 instance> "%~dp0only-1.flag"
call "%~dp0StartWatchdog.bat" keep
