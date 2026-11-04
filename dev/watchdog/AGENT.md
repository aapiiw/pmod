# Bot supervisor agent (one pass; run with: /loop 30m follow dev/watchdog/AGENT.md)

Restarts are done by BotWatchdog.ps1, not by you. Each pass:

1. `tail -40 dev/watchdog/run/watchdog.log`: restarts, AUTOIT ERROR texts.
   RESTART LOOP line = a bot fails at every start: fix with priority. New `dev/watchdog/run/bot*_*.log` with content = AutoIt error of a bot started by the watchdog.
2. `bash dev/ocrtest/logsum.sh "<time of the last pass, from DEVLOG 'Agent pass'>"` -> read only the summary:
   failed switches, wrong account (gems), red errors, crashes, repeating warnings, work done.
3. Something new or worse than the last pass -> trace it in the code (targeted reads only).

Change code WITHOUT asking only when the bot cannot run or fails every time:
- AutoIt error / crash (syntax, array index, undeclared variable), a function that errors on every call,
  a loop that never ends, restart loops.
- Smallest fix, same behavior otherwise. Au3Check must give 0 errors:
  `"/c/Program Files (x86)/AutoIt3/Au3Check.exe" MyBot.run.au3`
- Keep CRLF line endings. Then write `dev/watchdog/restart-<n>.flag` (text = short reason) for each running
  instance (1 and 2): the watchdog restarts that bot so the fix is used.

ASK the user first (write the proposal in the pass report, change nothing) for:
- optimizations, timings, upgrade / attack / donate / switch logic, OCR thresholds, settings in config.ini,
  anything touching gems, potions or account choice, changes over ~20 lines or in several functions.

Never: commit, push, reset, change branches, edit config.ini while a bot runs, delete logs, spend gems by hand.

End of pass: add one line to DEVLOG.md under NOW: `- Agent pass <yyyy-mm-dd HH:MM>: <ok / found X / fixed X in file:line /
proposal X>` (replace the previous 'Agent pass' line when nothing new). Reply in Indonesian, 2-4 lines.
