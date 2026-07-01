# Micro Wars Lobby

A tiny lobby for hosting and joining Micro Wars matches. No installs needed. It uses the Windows built-in PowerShell and works on any Windows 10/11 PC that already has Beyond All Reason and the MicroWars.sdd set up (see BROTHER_SETUP.md).

## Run it

Double-click **MicroWarsLobby.bat**.

## For the host (Michael)

1. Set "I am: Host" at the top.
2. Pick a preset, or tweak any field (time limit, points, armies, waves).
3. Click **LAUNCH MATCH**. The game opens and waits for the joiner.
4. When the game closes, the lobby is right where you left it. Adjust and relaunch.
5. Made a composition you like? **Save as preset** keeps it for next time.

## For the joiner (Mark)

1. Set "I am: Joiner" at the top.
2. If Michael says he changed the mod, click **Sync mod files from GitHub** once. It downloads the 3 mod files and refreshes the game's checksum cache.
3. Wait for Michael to say the match is up, then click **JOIN MATCH**.
4. After the game closes you are back in the lobby. Just hit JOIN again for a rematch.

## Notes

- Both PCs must be on the same Tailscale network. The host IP field is pre-filled with Michael's.
- Armies are typed as `unitname count, unitname count` (example: `armpw 50,armrock 10`). Click **Unit names** in the app for the cheat sheet.
- Mod settings (points, timers, armies) come from the host only. The joiner never needs to configure anything.
- The joiner only needs to re-sync when the mod CODE changes, not when the host changes armies or settings.
