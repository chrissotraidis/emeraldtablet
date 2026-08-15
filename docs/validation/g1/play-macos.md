# G1 — authentic macOS play record

Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 (25F84) arm64.
Wrapper `e979df7` plus uncommitted G0/G1 tree. Engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` with patches
`0001-macos-propagate-deployment-target.patch` and
`0002-macos-curl-secure-transport.patch` applied in the submodule
worktree.

## Summary

Authentic Pharaoh + Cleopatra play was driven through the real UI in a
windowed arm64 app built from the pinned engine: main menu, family
creation (`EmeraldG1`), campaign chronology, and the Nubt city mission
(mission 0). The city sim ran for multiple in-game years with workers,
animals, monthly autosaves, and a quicksave. Audio formats initialized
(FLAC/MP3/OGG/MIDI). User-confirmed working authentic play on the host.

## Data setup (private, local only)

The game data directory is a private overlay at
`artifacts/private/g1-play/` (gitignored). It is a per-entry union:

- original `[private-data]` files via symlinks (never copied, never
  staged, never hashed or listed here);
- Akhenaten engine-owned files the data check requires
  (`Data/neucha.ttf`, `Data/pharaoh_fonts_pack.sgx`,
  `Data/pharaoh_custom_pack.sgx`, `Data/pharaoh_houses_pack.sgx`);
- engine `Data/maps/` used by missions;
- writable `Save/` (the only writable save location).

The engine's data check (`check_engine_data_files` in
`src/platform/akhenaten.cpp`) rejected the first overlay because the
`Data/` symlink pointed only at the original game data. See
`play-launch-1-fail.md` for the root cause and the union fix.

## Launch (windowed, one runtime)

```sh
build/macos/akhenaten.app/Contents/MacOS/akhenaten --window \
  --size 1280x800 --pos 40,40 --no-logo --nointro \
  --noconfig-window --nocrashdlg artifacts/private/g1-play
```

The same session is reproducible from
`~/Library/Application Support/Akhenaten/akhenaten.cfg`
(`data_directory=artifacts/private/g1-play`, `window_mode=1`,
`renderer=metal`, `window_width=1280`, `window_height=800`). The
window is 1280x800 content + title bar; the game honors resize events
and re-renders (`Render texture created (1029 x 688)` observed after a
resize). Window position is set from `--pos` at startup; the OS may
reposition the window afterward, which is expected window-manager
behavior and is not a game defect.

## Measured evidence (2026-08-13 session, PID 90039)

| Criterion | Evidence | Type |
|---|---|---|
| Render | `full-day2b.png` and `sky-city*.png` show the live Nubt map, sidebar, minimap, date `May 3489 BC`, `Db 3730`, `Pop 0` | render |
| Gameplay | months advance across screenshots; `Save/EmeraldG1/autosave_month.svx` mtime advances (21:16 → 22:13); game log `Save game: OK Save/EmeraldG1/autosave_month.svx`, `VERSION: 189` | gameplay/save |
| Input | real UI navigation menu → family → campaign → Nubt briefing → city; clicks and key events (`keys-*.log`, `sky-*.png`) | input |
| Audio | `music formats initialized: FLAC, MP3, OGG, MIDI (57)`; BIK video frames with audio bytes decoded | audio |
| Pause | `P` shows the "Game paused" banner (session screenshot) | input/lifecycle |
| Save | `Save/EmeraldG1/quicksave.svx` (F5, 21:16) and `autosave_month.svx` (22:13), both 5.7 MB, format `VERSION: 189` | save |
| Advisors | advisor hotkeys pressed in city (session key logs) | input |
| Build/inspect | city construction UI reachable (sidebar build tools visible); fine-grained build/inspect click evidence is partial | gameplay |

All raw logs and screenshots stay under `artifacts/private/g1-play-logs/`
(gitignored). No `[private-data]` file is hashed, listed, or staged.
No original `.sav` was supplied, so original-save loading is recorded
as *not available* rather than tested.

## Session incident (stuck quit dialog)

After repeated File-menu automation, a `window_popup_dialog_yesno`
"Quit" dialog stopped responding to Escape, mouse clicks, and Return
for 30+ minutes while the game kept rendering (82% CPU, main thread in
`window_city::draw_foreground`). SIGTERM and SIGINT were ignored;
SIGKILL was required. Recorded as an unclean quit of a stuck modal,
not a clean-exit pass. Clean process exit remains an open item (see
below).

## User confirmation

The goal owner confirmed on 2026-08-14 that authentic play works on
this host, and directed the session to stop click-driving the Mac game
and proceed to the mobile gates. That confirmation is recorded here
and gates G1 as PASS; the items below remain open but do not block the
mobile order.

## Open items (tracked, not blocking)

- Clean process exit via the in-game quit dialog (the stuck-dialog
  incident above is not a clean-exit pass).
- Save reload through main-menu Continue / dynasty Resume after a
  relaunch (save files exist and are format-189; the reload path exists
  in `ui_main_menu.js` / `ui_dynasty_menu.js`).
- Cleopatra expansion scenario entry (Individual Missions tab,
  `m_048_alexandria_1.js` … `m_052_actium.js`; maps present in engine
  `Data/maps/`).
- Dedicated build+inspect click evidence with a placed building and an
  inspected structure.

These are folded into the G6 compatibility pass on desktop as part of
the developer-preview subset.

## Fact vs inference

- Fact: the pinned patched build boots, renders, and plays Nubt with
  real UI input, audio init, and format-189 saves (measured).
- Fact: window resizing re-renders at the new size (measured log).
- Inference: clean quit and reload would pass on a fresh session; the
  stuck dialog was specific to the 8-hour automated session (not
  reproduced manually).
