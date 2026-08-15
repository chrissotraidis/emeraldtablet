# G4 — iPhone lifecycle (in progress)

Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 (25F84) arm64.
Device: iPhone 16 Simulator, iOS 18.5, landscape (UDID 212F13B4-…).
Wrapper `e979df7` + uncommitted G0-G4 tree; engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001-0003.

## Implementation (patch 0003)

`src/platform/platform_ios.cpp` now intercepts SDL app-lifecycle events in
`platform_poll_event`:

- `SDL_APP_WILLENTERBACKGROUND` → when a city is loaded (`city_has_loaded`):
  pause the simulation (`game.paused = true`), write a dedicated lifecycle
  autosave (`GamestateIO::write_savegame("lifecycle.svx")` → resolves to
  `Save/<player>/lifecycle.svx`), and flush game features/config.
- `SDL_APP_DIDENTERFOREGROUND` → the sim stays paused until the player
  unpauses; audio/resources are revalidated by SDL's UIKit audio-session
  handling on foreground.

## Measured (2026-08-14)

1. City loaded on the phone (macOS quicksave via Continue; format 189).
2. Home button (Simulator) → app backgrounds → the game log records:
   `Save game: writing Save/EmeraldG1/lifecycle.svx` →
   `File write successful: … VERSION: 189` → `Save game: OK`; the file
   appears in `Documents/GameData/Save/EmeraldG1/lifecycle.svx`
   (5.7 MB, format 189).
3. App terminated while backgrounded and relaunched
   (`simctl terminate` / `simctl launch`, new PID); `lifecycle.svx` is
   intact after relaunch.

## Open items (next loop)

- 20 background/foreground cycles with the sim paused each time and
  resuming paused.
- Load `lifecycle.svx` through the UI (dynasty menu → Load Saved Game) and
  verify the city resumes.
- Manual-save preservation across the lifecycle save.
- Interrupted import / low-storage behavior for the picker importer.
- Clean build/install/inject/launch twice; in-place app update survival.

## Evidence

Game log lines and file listing above; raw logs in
`artifacts/private/g3-sim/`.
