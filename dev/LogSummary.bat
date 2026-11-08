@echo off
rem Log summary of all profiles (last 24 h, or since the time given: LogSummary.bat "2026-10-31 00:00")
rem Result also saved in dev\ocrtest\logsum\<date>.txt
"C:\Program Files\Git\bin\bash.exe" "%~dp0ocrtest\logsum.sh" %1
pause
