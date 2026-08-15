# G4 — iPhone lifecycle (core done + remainders measured)

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

## Remainders measured (2026-08-15, patches 0001-0006)

Host: Chris-Macbook-Air-M1.local / macOS 26.5.2. Device: iPhone 16 Simulator,
iOS 18.5, landscape (UDID `212F13B4-...`), the only simulator booted. App
installed from the 0001-0006 build; cfg re-pointed to the data container;
launch PID 32993.

### Lifecycle-save UI load

Main menu → Continue loaded `Save/EmeraldG1/lifecycle.svx`:

```text
File read successful: .../Save/EmeraldG1/lifecycle.svx 0@ --- CONTAINER rev 1,
VERSION 189, 114 sections (0 missing) ---
```

The Nubt city rendered (same `Db 5750` family state as G1). Evidence:
`artifacts/private/g4-iphone/lifecycle-ui-load.png` (gitignored).

### 30 background/foreground cycles

Scriptable cycle: background via `simctl launch com.apple.Preferences`
(forces the game to background), foreground via
`simctl launch mt.dalerank.akhenaten`. 30 cycles ran in ~2.5 min; the game
process stayed alive (same PID in `launchctl list`), and every background
write produced `File write successful: ...lifecycle.svx VERSION: 189`. After
the cycles the game showed the expected pause banner
(`Game paused ('P' key continues)`), confirming the background pause path.

### Manual-save preservation

`quicksave.svx` and `family.sav` were hashed before and after the 30 cycles
and the in-place update:

```text
quicksave.svx 366e3aac...7633a0  (unchanged)
family.sav    df3f6198...81119   (unchanged)
```

Lifecycle writes touched only `lifecycle.svx`; manual saves stayed
byte-identical.

### In-place update survival

`simctl terminate` + `simctl install` (same bundle id, newer build) +
relaunch. The data container moved to a new path (normal for `simctl`
reinstall); after re-pointing `akhenaten.cfg` to the new container, the app
relaunched and loaded the same campaign data with saves byte-identical
before/after (SHA-256 match for quicksave/lifecycle/family). Evidence:
`artifacts/private/g4-iphone/update-survival-menu.png`.

### Interrupted-import / low-storage preflight

The native importer (`src/platform/platform_ios_picker.mm`, in patch 0003)
already staged imports into `GameData.staging` and promoted atomically
(backup + move), so a killed copy never leaves a partial live tree, and the
next import removes any stale staging first. On 2026-08-15 a low-space
preflight was added: `folder_size()` measures the picked game folder and the
import fails with a clear error before copying when the app container volume
has less available capacity than the folder needs
(`NSURLVolumeAvailableCapacityForImportantUsageKey`). Verified by rebuild
(`** BUILD SUCCEEDED **`, audit OK, string present in the binary) and a
post-change launch (PID 41561, window renders, data loads). A full
low-storage runtime simulation was not performed because it would require
filling the host disk; the failure path is compile- and link-verified.

### Still open

- Full low-storage runtime simulation on-device (requires filling the host
  disk; the preflight code path is build-verified).
- Physical-device behavior remains a human gate (G7).
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
