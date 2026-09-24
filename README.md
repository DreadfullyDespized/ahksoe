# AHKSOE — AutoHotkey Doohickey for GTAV Roleplay
**Repo label: TEST** — see [CONTRIBUTING.md](CONTRIBUTING.md).

AutoHotkey (v1) scripts by DreadfullyDespized that automate repetitive chat commands and hotkey tasks while roleplaying GTA V (via FiveM) on the SoE community servers.

## Scripts

- **AHKSOE.ahk** (v2.20200506) — the current script, built for GTAV RP on SoE (EvolPC Gaming community). Tabbed GUI (LEO / TOW / CIV / SAFR / Help / General) with fully rebindable hotkeys, per-role configuration, and a built-in auto-updater.
- **AHKGTAV.ahk** (v5.0.0) — earlier version of the same concept, built for GTAV FiveM roleplay on New Dawn Gaming (NDG). Kept here for reference.

Supporting files: `SOE-Config.ini` / `GTAV-Config.ini` (settings), `Changelog-SOE.txt` / `Changelog.txt` (version history). Licensed under GPLv3 (see `LICENSE`).

## What it does

**Text-expansion chat commands** (type the trigger in-game):

- Police: `tdutystart`, `tfrisk`, `tsearch`, `tmedical`, `timpound`, `tplate`, `tvin`, `ttrunk`, `tsglovebox`
- Tow: `tadv`, `tstart`, `tsend`, `tonway`, `ttow`, `tsecure`, `trelease`, `tkitty`
- Help/OOC: `tmic`, `tpaystate`, `tsoehelp`

**Hotkeys** (all rebindable in the GUI, Ctrl+1):

- Police: spike strip toggle, plate run, vehicle image search, call/respond to tow
- General: seatbelt toggle, force engine on, valet pull/check, phone recording
- Utility: reload script, update checker, police overlay on/off

**Configuration** — role, callsign, department, display name, chat-command prefixes (`/me`, `/do`, `/r`, …), and every hotkey are stored in the `-Config.ini` file and editable through the GUI.

## Requirements

- Windows
- AutoHotkey 1.1 or newer (the script exits on older versions; a compiled build works too)
- The script requests administrator rights on launch
- GTA V with FiveM, connected to the relevant RP server

## Notes

- While running, the script keeps NumLock on and ScrollLock off, and adds Win+Del (empty recycle bin), Win+ScrollLock (pause hotkeys), Win+Insert (reload script).
- Command prefixes and syntax are configurable so they can track server changes.
- The full command list is shown in the script's Help tab (Ctrl+1 → Help).

## Status

Not actively maintained — last updated 2020 (AHKSOE) / 2019 (AHKGTAV). Server command syntax may have drifted since; check the Help tab and your `-Config.ini` before relying on it.
