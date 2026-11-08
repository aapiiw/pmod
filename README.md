# piwMod

A personal fork of a Clash of Clans bot written in AutoIt.

**This is not original work.** The bot was written by the MyBot.run team, and this fork is
based on **xbebenk Mod**. I (aapiiw) only maintain it, fix bugs and add changes for my own
setup. All credit for the base bot goes to the original authors listed below.

## Credits

- **MyBot.run**: the original bot and most of the code base (<https://github.com/MyBotRun/MyBot>).
  The authors of each file are named in its header.
- **xbebenk Mod** (`MBR_xbebenkMod`), the base of this fork, by xbebenk
  (<https://github.com/xbebenk/MBR_xbebenkMod>). Upstream fixes are reviewed and adopted here when they fit.
- **Mod PH**: some features and GUI layouts (e.g. Donate, Clan Capital) follow Mod PH.

## What this fork changes

Most of the changes are about running several accounts unattended on MuMu Player:

- Upgrades through the Build menu: builder, Laboratory and Pet House upgrades, type filters, an upgrade order,
  and an "upgrades must end before" deadline.
- Account switching checks: the village name is read after a switch, so a wrong account is caught and the
  switch is retried. The Supercell ID list is read again when it is off grid.
- Hero pets: a free pet is picked when a hero is switched in or its pet is upgrading.
- Telegram notifications: idle builder, lab and pet alerts, and BUILDER and SHIELD commands.
- Watchdog (`dev/watchdog`): restarts a bot after an AutoIt error, a silent log, a crash or a MuMu boot loop.
- Cleanup: unused legacy code is removed (for example the Lab building image search and the Star Laboratory
  path), following xbebenk Mod.

## Requirements

- Windows 10/11
- AutoIt v3.3.16 (run `MyBot.run.au3` as a script)
- MuMu Player 12 (tested), Background Mode with WinAPI
- Microsoft Visual C++ 2010 Redistributable (x86), .NET Framework 4.5

## License

- MyBot AutoIt code is open source under the GNU General Public License v3, see `License.txt`
  (<http://www.gnu.org/licenses/gpl-3.0.txt>). This fork keeps that license.
- Third party libraries used by MyBot (#SystemLibraryException):
  - OpenCV - BSD license - <https://github.com/MyBotRun/Libraries>
  - ImageSearch - GNU license - <https://github.com/MyBotRun/Libraries>
  - MyBotRunImgLoc.dll - TRlopes 2016, the owner can restrict use, inspection, modification and redistribution
  - MBRfunctions.dll - proprietary library, Didipe 2015
  - curl.exe - <http://curl.haxx.se/>
