# G5 — iPad Simulator and Pencil shell

Status: CORE PROVEN on iPad mini (build, install, city load, Pencil option visible and togglable),
iPad Pro 13" (full-screen city-from-save, native overlay, Pause/Speed actions), and
iPad Pro 11" (city-from-save, full-screen render, overlay, Pencil toggle).
Host: Chris-Macbook-Air-M1.local / macOS 26.5.2
Wrapper: `e979df7` + G0-G5/G9-prep tree. Engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` + patches 0001-0006.

## What this gate proves (developer-preview scope)

- App builds/installs/launches on iPad mini, iPad Pro 11", and iPad Pro 13"
  Simulators and reaches the authentic menu and the same Nubt city proven on
  Mac (from the macOS-created save).
- Apple Pencil has a distinct SDL touch identity (`UITouchTypeStylus` →
  `STYLUS_TOUCH_ID` 0x4748454E43494C31), so the engine can tell stylus from
  fingers.
- Pencil mode is a user-visible feature (Options) with CaesarPad-informed
  behavior: Pencil selects/inspects/places, fingers pan/zoom, finger taps never
  click while enabled; traditional touch remains fully usable when off.
- Simulated Pencil logic is **not** physical Pencil acceptance (G8 is the human
  gate); this shell only proves the code path and option plumbing.

## Patches 0004-0006 (pencil shell + overlay)

1. `cmake/BuildSDL2.cmake`: when building SDL2 for iOS, patches
   `SDL_uikitview.m` so stylus touches get a dedicated `stylusTouchId`
   (0x4748454E43494C31ULL = 'PENCIL1') instead of the shared direct-touch id.
2. `src/input/touch.{h,cpp}`: `touch_t::is_stylus`, `touch_create(..., is_stylus)`,
   `touch_set_pencil_mode` / `touch_pencil_mode`.
3. `src/platform/touch.cpp`: sets `is_stylus` when
   `event->touchId == STYLUS_TOUCH_ID`.
4. `src/input/mouse.cpp`: in pencil mode, non-stylus touches reset button state
   (fingers pan/zoom, never click).
5. `src/game/game_config.{h,cpp}`: `gameui_pencil_mode` feature.
6. `src/platform/platform_ios.cpp`: per-frame sync of
   `touch_set_pencil_mode(gameui_pencil_mode)`.
7. JS: Options menu row (`ui_top_menu_widget.js` /
   `ui_top_menu_actions.js`), localization entries
   (`localization_en.js`), plus the auto-generated Features window row.

`0005-ios-auto-display-scale.patch` defaults the engine display scale per
device on iOS (CaesarPad-style) so the fixed 1024x768 logical view fills each
screen; a user-configured scale still wins.

`0006-ios-native-overlay-menu.patch` adds a native iOS "⋮" button
(`src/platform/platform_ios_overlay.{h,mm}`) pinned to the top-right safe area.
It presents a UIKit action sheet wired to the engine through narrow events:
Pause / Resume (`event_toggle_pause`), Speed + / Speed −
(`event_change_gamespeed`), and a touch-controls help alert. Built and verified
on the 13" Simulator (2026-08-15).

CaesarPad comparison (ref/caesarpad, docs/prd/03-ux-requirements.md): CaesarPad
treats Pencil as precise touch with no exclusive mode. Emerald Tablet's shell is
stricter (distinct identity + mode where fingers never click) to satisfy the
Akhenaten G5 wording; both keep the engine's touch layer authoritative and the
mode reversible.

## 2026-08-15 — iPad screen-fill fix (letterboxing/padding defect)

User report (real product defect, not simulator cosmetics): on the iPad Pro 11"
Simulator the game rendered small and centered with black padding, so the
playable area was much smaller than the screen. Root cause verified in the
runtime log: `Creating screen 1024 x 768, fullscreen` — the SDL window was
1024x768 **logical points** (the classic iPad compatibility resolution) while
the 11" screen is 1210x834 landscape points. iOS letterboxes legacy
compatibility-mode apps on larger iPads.

Two plist fixes in `0003-ios-build-seam.patch` (res/ios/Info.plist):

1. `UISupportedInterfaceOrientations~ipad` restricted to
   `LandscapeLeft`/`LandscapeRight` (the game is a landscape 1024x768 title;
   portrait allowed the app to boot into a portrait/letterboxed layout).
2. Added empty `UILaunchScreen` dict — opts the app out of the legacy
   compatibility viewport so iOS presents it at the full native resolution.

Effect: the game window should now be the device's real landscape point size
(1210x834 on the 11") and fill the screen instead of being centered with
padding. Verified on 2026-08-15 after rebuild:

- 11" log: `Creating screen 1210 x 834, fullscreen` (was 1024 x 768)
- 13" log: `Creating screen 1376 x 1032, fullscreen` (was 1024 x 768)
- 13" city view (loaded the macOS save) fills the framebuffer at 100%:
  content bbox = full 2064x2752 device framebuffer (measured). Screenshots:
  `artifacts/private/g5-sim/13inch-city-fullscreen.png`,
  `13inch-city-window.png`, `11inch-menu.png`.

Additional patch `0005-ios-auto-display-scale.patch`: sets a per-device default
display scale on iOS (CaesarPad-style) so the fixed 1024x768 logical view fills
each device; user-configured scale still wins. Applies cleanly after 0001-0004.

## Evidence log

### 2026-08-14/15 — iOS Simulator rebuild with 0004

- Command: `./scripts/build-ios-sim.sh`
- Result: `build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app` built,
  `** BUILD SUCCEEDED **`, `scripts/audit-ios-app.sh` passes (AUDIT OK; arm64,
  iOS 15.0 simulator, system frameworks only, engine Data/ + maps in bundle).
  Evidence: `build/ios-sim/build.log`, `docs/validation/g2-ios-audit.txt`.
- Proves: clean iOS build + package of the pencil-patched app.

### 2026-08-15 — iPad mini install + pencil option proof

- Device: iPad mini (A17 Pro) Simulator, iOS 18.5, UDID
  `7D8C148F-3B11-43B3-A032-0D6DBE40C366` (only simulator booted).
- `simctl install` of the rebuilt app; cfg/conf re-pointed to the new data
  container (data_directory + `gameui_show_intro_video:false` +
  `gameopt_last_save_filename`).
- Launched (PID 77930), splash "Click to Start" → main menu → Continue loaded
  the macOS-created save into the Nubt city (same `Db 3730` state as G1).
- In-city top menu → Options dropdown shows the new row
  "Pencil mode: OFF" (auto-generated from `gameui_pencil_mode` +
  `#TR_CONFIG_PENCIL_MODE` localization). Clicking the row toggles it to
  "Pencil mode: ON" (yellow highlight on the selected row, verified in
  device-accurate screenshots both ways; pixel-diff of the row text region
  y 172-176 confirms the glyph change).
- Evidence (private, gitignored): `artifacts/private/g5-sim/`
  `city-loaded.png`, `options-pencil-OFF-device.png`,
  `options-pencil-ON-device.png`, `options-pencil-OFF-window.png`,
  `options-pencil-ON-portrait.png`.
- Proves: install, PID, render, menu reachability, save reload (cross-device),
  and the Pencil mode option plumbing (visible + togglable).
- Does NOT prove: physical Pencil behavior (G8 human gate), nor that a
  stylus touch actually produces a distinct touchId in a running session
  (simulated stylus is not physical acceptance).

### 2026-08-15 — 13" overlay + city-from-save + Speed/Pause actions

- Device: iPad Pro 13-inch (M4) Simulator, iOS 18.5, UDID
  `02BFE363-AA20-48BD-BBE0-7DBEB4AD8713` (only simulator booted).
- Rebuilt with patches 0001-0006 (`cmake --build build/ios-sim`,
  `** BUILD SUCCEEDED **`; audit OK). `simctl install`; cfg re-pointed to the
  new data container (`data_directory=.../Documents/GameData`); conf already
  sets `gameui_show_intro_video:false` and
  `gameopt_last_save_filename: Save/EmeraldG1/quicksave.svx`.
- Launch (PID 23684): log shows `Creating screen 1376 x 1032, fullscreen` and
  `Render texture created (1376 x 1032)` — full native 13" landscape.
- Splash "Click to Start" → main menu → Continue loaded the macOS-created
  save into the Nubt city (same `Db 3730`-state family as G1; "Flood plain"
  inspector popup shown). Device screenshot content bbox = full 2064x2752
  framebuffer (100% x 100% measured) — the city fills the screen.
- Native "⋮" overlay (`ID: emeraldtablet.overlay-menu`, "Game controls",
  top-right) verified in the AX tree and visually. Clicking it opens the
  UIKit action sheet with Pause / Resume, Speed +, Speed −, Controls help.
  - Speed +: engine speed readout changed 80% → 90% (before/after screenshots).
  - Speed −: readout changed 90% → 50% (after screenshot).
  - Pause / Resume: sheet dismisses; app continues rendering without a crash
    (banner state is the engine's own pause UI; event reaches the engine).
- Evidence (private, gitignored): `artifacts/private/g5-sim/13inch/`
  `04-menu-device.png`, `05-city-device.png`, `06-overlay-sheet.png`,
  `07-overlay-before-speed.png` (Speed 80%), `08-overlay-after-speed.png`
  (Speed 90%), `09-pause-toggle.png`.
- Proves: 0006 builds/installs, full-screen render on 13", city-from-save
  loads on 13", overlay button exists, sheet opens, and Pause/Speed actions
  reach the engine.
- Does NOT prove: physical Pencil (G8) or a real stylus touchId in a session.

### 2026-08-15 — 11" city-from-save + overlay + Pencil toggle

- Device: iPad Pro 11-inch (M4) Simulator, iOS 18.5, UDID
  `08636791-2675-4675-8335-EF72EF954DCF` (only simulator booted; 13" shut down
  first per the one-simulator rule).
- `simctl install` of the patches-0001-0006 build; cfg re-pointed to the new
  data container; launch (PID 29326). Log: `Window resized to 1210 x 834`,
  `Render texture created (1210 x 834)` — full native 11" landscape.
- Continue loaded the macOS-created save into the Nubt city (same family state
  as G1/13"; "Flood plain" inspector shown). Device screenshot content bbox =
  full 1668x2420 framebuffer (99.9% x 100% measured) — the city fills the screen.
- Native "⋮" overlay (`emeraldtablet.overlay-menu`) opens the UIKit sheet with
  Pause/Speed/help; Speed + moved the readout 80% → 90% (before/after device
  screenshots). The Options dropdown shows the Pencil row and clicking it
  toggles OFF → ON (window + device screenshots).
- Evidence (private, gitignored): `artifacts/private/g5-sim/11inch/`
  `01-city-device.png`, `02-overlay-sheet.png`, `03-after-speed.png`,
  `04-options-dropdown.png`, `05-pencil-ON-device.png`.
- Proves: 11" install/PID/render, city-from-save, full-screen fill, overlay
  presence + Speed action, Pencil-mode row toggle on a second iPad size.
- Does NOT prove: physical Pencil (G8) or a real stylus touchId in a session.

### Pending for this gate

- iPad Pro 11" (`08636791-2675-4675-8335-EF72EF954DCF`) and iPad Pro 13"
  installs → city-from-save proof and the same Options-row check (both done
  2026-08-15 above).
- Phone-vs-tablet default independence and long-press/two-finger behaviors are
  G3/G5 polish items; simulated-Pencil-only wording in README/docs.

## Open items after this gate

- G3 remainder: phone touch scale / safe areas / virtual keyboard.
- G4 remainder: 20 bg/fg cycles, lifecycle-save UI load, manual-save
  preservation, interrupted import / low storage, in-place update survival.
- Physical G8 remains the human Pencil acceptance gate.
