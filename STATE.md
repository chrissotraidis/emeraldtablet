# Emerald Tablet state

Last updated: 2026-08-13

Host: Chris-Macbook-Air-M1.local, macOS 26.5.2 (25F84), Darwin 25.5.0 arm64.
Xcode 26.6 (17F113). CMake 4.4.0. Git 2.36.1. Ninja present. No physical iPhone
or iPad is attached. Available Simulators include iPhone 16 / 16e / 17 families
and iPad mini / 11-inch / 13-inch on iOS 18.5 and 26.5. About 57 GiB free.

## Gates

| Gate | Status | Evidence |
|---|---|---|
| G0 — Workspace and source safety | PASS | Clean pin `38cb947ead3895408ea32f74fda6e37921a42bd3`, empty patch queue, ignored `ref/`, `scripts/check-repo-safety.sh` passed. `docs/validation/g0-workspace.md` |
| G1 — macOS baseline | PASS | Patched self-contained arm64 app (`minos 11.7`, system frameworks only), hermetic suite `194 passed, 0 failed`, authentic Pharaoh+Cleopatra play in Nubt city with render/input/audio/save evidence and user confirmation. `docs/validation/g1/patched-macos.md`, `docs/validation/g1/hermetic-full.md`, `docs/validation/g1/play-macos.md` |
| G2 — iOS build seam | PASS | `GAME_PLATFORM_IOS` split, minimal iOS backend, iOS app target (families 1,2), desktop-only components off. iPhone Simulator SDK build links and audits clean (arm64, iOS 15.0, UIKit/Metal only). `docs/validation/g2-ios-seam.md`, `docs/validation/g2-ios-audit.txt` |
| G3 — iPhone Simulator | CORE PASS | Installed + launched on iPhone 16 (iOS 18.5); native Game Data Required flow; UIDocumentPicker importer end-to-end; authentic data reaches menu, family, chronology, Nubt briefing; macOS save (format 189) loaded via Continue → Nubt city on phone with autosaves; in-city tap works. G3 remainder measured 2026-08-15: touch works full flow, bottom UI clears the home indicator, virtual keyboard wired (SDL text input both layers; no reachable phone text field on Simulator — device verification is G7). `docs/validation/g3-iphone-simulator.md` |
| G4 — iPhone lifecycle | CORE PASS | Background → lifecycle autosave + pause implemented and measured; 30 bg/fg cycles survive with one PID; lifecycle save loads via Continue (VERSION 189, 114 sections); manual saves byte-identical across cycles and in-place update; app relaunches with data intact after reinstall; importer gained a low-space preflight (patch 0003). `docs/validation/g4-iphone-lifecycle.md` |
| G5 — iPad Simulator and Pencil shell | CORE PASS | Proven on all three iPads: mini (Pencil row toggles), 13" (full-screen city-from-save, native "⋮" overlay, Pause/Speed actions), 11" (city-from-save, full-screen render, overlay, Pencil toggle). `docs/validation/g5-ipad-pencil-shell.md` |
| G6 — Compatibility matrix | NOT STARTED | Developer-preview subset after G5. |
| G7 — Physical iPhone | HUMAN GATE | No iPhone is attached. |
| G8 — Physical iPad and Apple Pencil | HUMAN GATE | No iPad or Pencil is attached. |
| G9 — Release engineering | NOT STARTED | Local data-free artifacts after the Simulator gates. |

## Pinned inputs

- Akhenaten submodule: `38cb947ead3895408ea32f74fda6e37921a42bd3` (`dalerank/Akhenaten`).
- CaesarPad local checkout: ignored `ref/caesarpad` at `07a8d38a4eae77d01c6d980ecbc36de8fad97ef6`.
- Pharaoh + Cleopatra: local ignored folder under `ref/`. Required markers `campaign.txt` and `Data/` exist. No hashes or file listings are recorded here.

## Decisions

- Working repository name is Emerald Tablet. Public branding remains subject to later naming and trademark review.
- `ref/` is local-only and must never be staged.
- The engine lives as a pinned submodule at `engines/akhenaten`.
- Apple changes go in `patches/akhenaten` as a small ordered queue.
- CaesarPad is a behavioral reference only. Do not apply its Augustus patches blindly.
- Physical G7/G8 stay human-only until hardware and signing are available.
- Authentic Mac play is user-confirmed working (2026-08-14); G1 is PASS with open sub-items (clean quit, save reload, Cleopatra entry, build+inspect clicks) tracked into the G6 desktop compatibility pass.
- The macOS window honors resize events and re-renders; launch size/position come from the cfg (`window_width=1280`, `window_height=800`) or `--size/--pos` args. OS window repositioning is expected and not a game defect.
- 2026-08-15: the windowed desktop game was stopped and extra Simulator windows
  shut down; only one iPad mini Simulator remains for G5 work.

### 2026-08-15 — G5 pencil shell proven on iPad mini

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper: `e979df7` + uncommitted G0-G5 tree. Engine pin
  `38cb947ead3895408ea32f74fda6e37921a42bd3` + patches 0001-0004.
- Device: iPad mini (A17 Pro) Simulator, iOS 18.5, UDID
  `7D8C148F-3B11-43B3-A032-0D6DBE40C366`.
- Command: `scripts/build-ios-sim.sh` (BUILD SUCCEEDED, audit OK); `simctl
  install/launch`; cfg/conf re-pointed; UI driven to city via Continue (loaded
  the macOS `Save/EmeraldG1/quicksave.svx`, same `Db 3730` state as G1).
- Result: Options menu shows "Pencil mode: OFF" and toggles to
  "Pencil mode: ON" on click (device-accurate screenshots both states).
- Evidence: `docs/validation/g5-ipad-pencil-shell.md`,
  `artifacts/private/g5-sim/` (gitignored).
- Proves: iOS build of 0004, install, PID, render, menu, cross-device save
  reload, Pencil-mode option plumbing.
- Next: iPad Pro 11"/13" installs + city-from-save, then G3/G4 remainders,
  G6 subset, G9.
- Fact vs inference: all facts measured; simulated Pencil is not physical
  Pencil acceptance (G8).

### 2026-08-15 — iPad screen-fill fix (letterboxing defect)

- User report: on iPad Pro 11"/13" Simulators the game rendered small and
  centered with black padding; the playable area was much smaller than the
  screen. Root cause: iOS legacy compatibility mode — the app's Info.plist
  declared portrait on iPad and had no `UILaunchScreen`, so iOS ran the app in
  a 1024x768 logical viewport centered on the larger physical screen.
- Fix (in `0003-ios-build-seam.patch`, res/ios/Info.plist):
  `UISupportedInterfaceOrientations~ipad` → landscape-only, and added empty
  `UILaunchScreen` dict. Additional `0005-ios-auto-display-scale.patch`
  defaults the engine display scale per device (CaesarPad-style) so the fixed
  1024x768 logical view fills each screen.
- Verified (engine log): 11" `Creating screen 1210 x 834`, 13"
  `Creating screen 1376 x 1032` (both were 1024 x 768 before). 13" city view
  (macOS save loaded) fills the device framebuffer 100% (measured content bbox
  = full 2064x2752). Evidence: `artifacts/private/g5-sim/13inch-city-*`,
  `docs/validation/g5-ipad-pencil-shell.md`.
- Proves: window/render at full native size on all three iPads; gameplay
  (city) fills the screen.
- Open: the main-menu art is the game's own fixed-size centered design (same
  on desktop); CaesarPad-style native overlay toolbar ("three-dot" menu) is
  separate UI work, not started.

### 2026-08-15 — G5 13" overlay + city-from-save (patches 0005/0006)

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper: `e979df7` + uncommitted G0-G5/G9-prep tree. Engine pin
  `38cb947ead3895408ea32f74fda6e37921a42bd3` + patches 0001-0006.
- Device: iPad Pro 13-inch (M4) Simulator, iOS 18.5, UDID
  `02BFE363-AA20-48BD-BBE0-7DBEB4AD8713`.
- Command: incremental `cmake --build build/ios-sim --config RelWithDebInfo`
  (`** BUILD SUCCEEDED **`, audit OK); `simctl install`; cfg re-pointed to the
  new data container; `simctl launch` (PID 23684).
- Result: log `Creating screen 1376 x 1032, fullscreen` +
  `Render texture created (1376 x 1032)`; Continue loaded the macOS save into
  Nubt city; device screenshot content bbox = full 2064x2752 framebuffer
  (100% x 100%). The native "⋮" overlay (AX ID `emeraldtablet.overlay-menu`)
  opens a UIKit sheet: Speed + moved the readout 80% → 90%, Speed − 90% → 50%,
  Pause/Resume dismisses cleanly. 0005 (auto display scale) and 0006 (overlay)
  apply cleanly after 0001-0004.
- Evidence: `docs/validation/g5-ipad-pencil-shell.md`,
  `artifacts/private/g5-sim/13inch/` (gitignored).
- Proves: 0005/0006 build+install on 13", full-screen render, city-from-save
  on 13", overlay presence, sheet open, Pause/Speed reach the engine.
- Next: 11" city-from-save + Options-row check, then G3/G4 remainders, G6, G9.
- Fact vs inference: all facts measured; simulated Pencil is not physical
  Pencil acceptance (G8).

### 2026-08-15 — G5 11" city-from-save + overlay + Pencil toggle

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper: `e979df7` + G0-G5/G9-prep tree. Engine pin
  `38cb947ead3895408ea32f74fda6e37921a42bd3` + patches 0001-0006.
- Device: iPad Pro 11-inch (M4) Simulator, iOS 18.5, UDID
  `08636791-2675-4675-8335-EF72EF954DCF` (13" shut down first; one simulator
  per session).
- Command: `simctl install` of the 0001-0006 build; cfg re-pointed to the new
  data container; `simctl launch` (PID 29326).
- Result: log `Creating screen 1210 x 834` + `Render texture created
  (1210 x 834)`; Continue loaded the macOS save into Nubt city; device
  screenshot content bbox = full 1668x2420 framebuffer (99.9% x 100%).
  The native "⋮" overlay opens the UIKit sheet (Speed + 80% → 90%); the
  Options dropdown Pencil row toggles OFF → ON.
- Evidence: `docs/validation/g5-ipad-pencil-shell.md`,
  `artifacts/private/g5-sim/11inch/` (gitignored).
- Proves: 11" install/PID/render, city-from-save, full-screen fill, overlay,
  Pencil-row toggle on a second iPad size.
- Next: G3/G4 remainders (iPhone), G6 subset, G9.
- Fact vs inference: facts measured; simulated Pencil is not physical
  Pencil acceptance (G8).

### 2026-08-15 — G4 remainders on iPhone 16

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Device: iPhone 16 Simulator, iOS 18.5, UDID
  `212F13B4-01EE-453E-8B30-EFD7198D6C42` (only simulator booted).
- Wrapper/engine: main + patches 0001-0006; launch PID 32993.
- Result:
  1. Lifecycle-save UI load: Continue loaded `lifecycle.svx` (`VERSION 189,
     114 sections (0 missing)`), city rendered.
  2. 30 bg/fg cycles (Preferences background + app relaunch): same PID alive,
     lifecycle.svx written each background, pause banner after cycles.
  3. Manual-save preservation: `quicksave.svx` + `family.sav` SHA-256
     identical before/after 30 cycles and the in-place update.
  4. In-place update: `simctl terminate` + reinstall + relaunch; saves
     byte-identical, data loads after re-pointing the new container cfg.
- Evidence: `docs/validation/g4-iphone-lifecycle.md`,
  `artifacts/private/g4-iphone/` (gitignored).
- Proves: lifecycle-load via UI, 30-cycle survival, manual-save preservation,
  update survival.
- Open: interrupted-import/low-storage preflight (destructive storage test),
  physical-device behavior (G7).
- Fact vs inference: facts measured; no test was weakened.

### 2026-08-15 — importer low-space preflight (patch 0003 regenerated)

- Change: `src/platform/platform_ios_picker.mm` now measures the picked game
  folder with `folder_size()` and fails before copying when the app container
  volume's available capacity
  (`NSURLVolumeAvailableCapacityForImportantUsageKey`) is smaller than the
  folder. Import staging/promotion was already atomic (no partial live tree;
  stale staging removed on the next import).
- Patch: `patches/akhenaten/0003-ios-build-seam.patch` regenerated from
  pin+0001+0002 so the queue stays clean; `check-repo-safety.sh` passes;
  0004-0006 apply cleanly after it.
- Verified: iOS Simulator rebuild `** BUILD SUCCEEDED **`, audit OK, string
  present in the binary, post-change launch (PID 41561) renders and loads
  data.
- Not verified: a full low-storage runtime simulation (would require filling
  the host disk). The failure path is compile/link-verified.
- Fact vs inference: build/launch facts measured; runtime low-storage path
  inferred from the preflight code.

### 2026-08-15 — G3 remainder measured on iPhone 16

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Device: iPhone 16 Simulator, iOS 18.5, UDID
  `212F13B4-01EE-453E-8B30-EFD7198D6C42` (only simulator booted).
- Result:
  1. Touch scale: full phone flow works (splash, menu, Continue→city,
     terrain inspector, "⋮" overlay) at the native 852x393 window with the
     0005 per-device scale.
  2. Safe areas: game fills the framebuffer; in-city bottom UI clears the
     home indicator by ~10px; no control clipped.
  3. Virtual keyboard: engine `SDL_StartTextInput` ↔ SDL UIKit driver both
     present; no text-field dialog reachable via the phone UI on the
     Simulator (fullscreen-only layout hides the desktop File menu; console
     hotkey not delivered by the hardware-keyboard route). Device
     verification is a G7 item.
- Evidence: `docs/validation/g3-iphone-simulator.md`,
  `artifacts/private/g3-sim/safearea-city-11.png`,
  `artifacts/private/g3-sim/touch-menu-11.png` (gitignored).
- Proves: touch reachability + safe-area clearance on the phone; keyboard
  wiring at both layers.
- Open: on-screen keyboard end-to-end on a physical device (G7).
- Fact vs inference: touch/safe-area facts measured; keyboard appearance
  inferred from wiring (no reachable field on Simulator).

### 2026-08-15 — check-repo-safety.sh patch-queue fix

- `scripts/check-repo-safety.sh` now allows the exact untracked new files the
  patch queue creates (0003: `res/ios/Info.plist`, `platform_ios.cpp`,
  `platform_ios_picker.{h,mm}`; 0006: `platform_ios_overlay.{h,mm}`) and
  verifies the queue by sequential reverse-apply/re-apply (patches overlap in
  `platform_ios.cpp`, so independent reverse checks were false-negatives).
  Full scan now passes with patches 0001-0006 applied.
- Fact vs inference: fact (script behavior measured locally).

### 2026-08-15 — stable developer-preview build published to main

- User-directed: update the repo to the latest stable state, make the README
  follow the CaesarPad structure/tone, and push/merge to main.
- Commit `bef7d8a` (wrapper): pinned engine gitlink `38cb947...`, patch queue
  0001-0006, CaesarPad-structured README, updated STATE/GOAL_LOOP/G5 docs,
  safety-script patch-queue handling, raw hermetic logs moved to ignored
  `artifacts/private/g1/`.
- Verified: local `HEAD` == `origin/main` == GitHub API `main`
  (`bef7d8a00c5b61a9e74bbaf55cd3f80675a68796`); published tree contains only
  wrapper sources/docs/patches/scripts/tests and the engine gitlink; no game
  data, saves, packages, signing material, or private evidence on the remote.
- Fact vs inference: fact (SHA triple-match and tree audit measured).

## Experiments

### 2026-08-13 — workspace inventory

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` (`Add files via upload`) plus uncommitted G0 files
- Engine commit: pin target `38cb947ead3895408ea32f74fda6e37921a42bd3`
- Command: read-only `git status`, `xcodebuild -version`, `xcrun simctl list`, marker existence check
- Result: empty wrapper except the plan and ignored original-game folder; tools are present; no devices attached
- Evidence: this file
- Proves: inventory only
- Next: G1 macOS baseline
- Fact vs inference: fact

### 2026-08-13 — G0 reconstruction and safety scan

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3`
- Command: `scripts/check-repo-safety.sh && scripts/apply-patches.sh && scripts/validate-ref-markers.sh`
- Result: safety scan passed; empty patch queue; private data remains untracked
- Evidence: `docs/validation/g0-workspace.md`
- Proves: source reconstruction and private-data scan
- Next: reproduce the arm64 macOS baseline
- Fact vs inference: fact

### 2026-08-13 — unpatched macOS G1 first build

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3` (empty patch queue)
- Command: `scripts/build-macos.sh` then a dummy-driver `--integraltests --integraltest-only 01_main_menu` smoke
- Result: `build/macos/akhenaten.app` is Mach-O arm64 RelWithDebInfo and the process exits 0. This is **not** a G1 pass.
- Measured defects:
  1. Dependency sub-builds did not inherit `CMAKE_OSX_DEPLOYMENT_TARGET=11.7`. SDL2, FreeType, HarfBuzz, and SDL2_mixer objects have `minos 26.0`; the final link emits many "built for newer macOS version (26.0)" warnings. Root cause: `BUILD_ADDITIONAL_CMAKE_ARGS` is a CMake list passed through a single `-D..._ADDITIONAL_CMAKE_ARGS=`, so the deployment-target item splits off the value and never reaches the `cmake -P` dependency scripts.
  2. The app is not self-contained. `otool -L` shows Homebrew `libssl.3.dylib`, `libcrypto.3.dylib`, and `libnghttp2.14.dylib` because in-tree curl is configured with `CURL_USE_OPENSSL=ON` and `USE_NGHTTP2=ON`.
  3. The hermetic evidence is only `tests/01_main_menu.js` (`1 passed, 0 failed`). That is a single-test smoke, not the 194-file baseline. Authentic gameplay, audio, save/reload, and Cleopatra detection were not run.
- Evidence: `docs/validation/g1/build.log`, `docs/validation/g1/hermetic-01-stdout.txt`, `docs/validation/g1/unpatched-macos.md`
- Proves: unpatched Mac **build** only. Does not prove package, hermetic suite, gameplay, input, audio, save, or lifecycle.
- Next: smallest patches for deployment-target propagation and Homebrew-free linkage, then a full hermetic run, then authentic Mac play.
- Fact vs inference: fact


### 2026-08-13 — patched self-contained macOS app

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0/G1 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001 and 0002 applied in the submodule worktree
- Command: `scripts/apply-patches.sh && scripts/build-macos.sh && scripts/audit-macos-app.sh build/macos/akhenaten.app`
- Result: arm64 RelWithDebInfo app, `minos 11.7` on the main executable and SDL2 / SDL2_mixer / FreeType / HarfBuzz, system-framework linkage only
- Evidence: `docs/validation/g1/patched-macos.md`, `docs/validation/g1/patched-audit.txt`
- Proves: patched Mac **build** and **package**. Does not prove authentic play.
- Next: authentic Mac play
- Fact vs inference: fact

### 2026-08-13 — full hermetic suite

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0/G1 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3`
- Command: `scripts/run-macos-hermetic.sh` (cwd `engines/akhenaten`, dummy SDL drivers)
- Result: `[integraltests] 194 passed, 0 failed`. Wrapper-root cwd finds 0 tests and is not green.
- Evidence: `docs/validation/g1/hermetic-full.md`, `docs/validation/g1/hermetic-full.stdout`, `docs/validation/g1/hermetic-cwd-miss.md`
- Proves: hermetic **test** baseline only
- Next: private overlay + authentic menu / Nubt / Cleopatra play
- Fact vs inference: fact

### 2026-08-13 — authentic play launch attempt 1 (engine-data gate)

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0/G1 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001 and 0002 applied
- Command: `build/macos/akhenaten.app/Contents/MacOS/akhenaten --window --size 1280x800 --pos 40,40 --no-logo --nointro --noconfig-window --nocrashdlg artifacts/private/g1-play`
- Result: PID `87045` captured, SDL initialized, data directory accepted, then the process exited at the engine-data check: `error: engine data missing: Data/neucha.ttf` plus `pharaoh_fonts_pack.sgx`, `pharaoh_custom_pack.sgx`, `pharaoh_houses_pack.sgx`. Root cause verified in `engines/akhenaten/src/platform/akhenaten.cpp` (`check_engine_data_files`): these are Akhenaten engine-owned files required under `Data/` (or `data/`) in the game data directory. The overlay `Data` symlink points at original game data, which lacks them and also lacks the engine `maps/` used by missions.
- Evidence: `docs/validation/g1/play-launch-1-fail.md`, raw logs `artifacts/private/g1-play-logs/stdout.log`, `stderr.log`, `pid.txt`, `launch-start.txt`
- Proves: process launch and data-directory selection only. Does **not** prove render, gameplay, input, audio, save, or lifecycle.
- Next: rebuild the overlay `Data/` as a union (per-entry symlinks to original data + engine files + engine `maps/`), relaunch, drive menu -> Nubt
- Fact vs inference: fact

### 2026-08-13/14 — authentic Nubt play and stuck quit dialog

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0/G1 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001 and 0002 applied
- Command: windowed launch from `~/Library/Application Support/Akhenaten/akhenaten.cfg` (data_directory = overlay `artifacts/private/g1-play`, window_mode=1, renderer=metal), driven via Computer Use
- Result: overlay `Data/` union fixed the engine-data gate; game reached the main menu, then Nubt city (mission 0) via real UI (Play Pharaoh/Cleopatra → New family `EmeraldG1` → Begin Family History → Predynastic → Nubt → briefing). Simulation advanced months/years; autosave_month.svx updated 22:13 (format 189); F5 quicksave.svx written 21:16; pause banner, advisor keys, and audio init (FLAC/MP3/OGG/MIDI) observed. Later, a Quit yes/no dialog stopped responding to Escape/clicks/Return for 30+ min while rendering continued; SIGTERM/SIGINT ignored; SIGKILL required (unclean quit, not a clean-exit pass). Goal owner then confirmed authentic play works and directed the session to the mobile gates.
- Evidence: `docs/validation/g1/play-macos.md`, raw logs/screenshots in `artifacts/private/g1-play-logs/`, saves in `artifacts/private/g1-play/Save/EmeraldG1/`
- Proves: render, input, gameplay, audio init, save (format 189). Does **not** prove clean process exit, save reload, or Cleopatra entry (open items).
- Next: G2 iOS build seam, then iPhone/iPad Simulator UI layer (Apple Pencil compared to CaesarPad)
- Fact vs inference: facts measured above; clean-quit/reload on a fresh session is an inference

### 2026-08-14 — G2 iOS build seam

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Wrapper commit: `e979df7` plus uncommitted G0/G1/G2 wrapper files
- Engine commit: `38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001-0003 applied
- Command: `scripts/build-ios-sim.sh` (Xcode generator, `CMAKE_SYSTEM_NAME=iOS`, `iphonesimulator` sysroot, arm64, deployment 15.0, RelWithDebInfo)
- Result: `build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app` builds and links; `scripts/audit-ios-app.sh` passes (arm64, `IOSSIMULATOR` minos 15.0 sdk 26.5, system frameworks only, bundle id `mt.dalerank.akhenaten`, no Cocoa/Carbon/ForceFeedback/updater/innoextract/launch.sh, engine `Data/` + 54 maps in bundle). macOS G1 build re-verified green after the patch.
- Evidence: `docs/validation/g2-ios-seam.md`, `docs/validation/g2-ios-audit.txt`
- Proves: iOS platform split, iOS app target, mobile-off options, static iOS deps with propagated SDK/arch/deployment, app audit
- Next: G3 iPhone Simulator — boot, install, launch, Game Data Required flow, document-picker importer, phone touch scale
- Fact vs inference: facts measured by audit; MIDI (timidity) runtime behavior and physical-device signing remain open items

### 2026-08-14 — G3 iPhone Simulator

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Device: iPhone 16 Simulator, iOS 18.5, landscape (UDID 212F13B4-01EE-453E-8B30-EFD7198D6C42)
- Wrapper/engine: `e979df7` + uncommitted G0-G3 tree; pin `38cb947ead3895408ea32f74fda6e37921a42bd3` + patches 0001-0003
- Command: `simctl install/launch mt.dalerank.akhenaten`; picker driven through the real `UIDocumentPickerViewController`; data injected into `Documents/GameData`; UI driven through menu → family → career → dynasty → chronology → Nubt briefing; macOS quicksave copied to the phone `Save/` and loaded via Continue
- Result: process launch (PID) and the no-data "Pharaoh data required" flow; the document-picker import copied/merged/promoted the game data; the full UI path reached the Nubt briefing; `File read successful: ...quicksave.svx VERSION 189, 114 sections (0 missing)` loaded the macOS city on the phone; monthly autosaves written on-device; a terrain tap opened the "Empty land" inspector. Known issue: short synthetic simulator taps are sometimes dropped and the native touch start is 150 ms delayed, so some UI clicks need held/repeated taps (documented; input pass next).
- Evidence: `docs/validation/g3-iphone-simulator.md`, screenshots in `artifacts/private/g3-sim/`
- Proves: install, PID, render, menu+mission reachability, save reload (cross-device), in-city input, autosave
- Next: phone touch scale / safe areas / virtual keyboard, then G4 lifecycle
- Fact vs inference: all facts measured; tap-loss is a simulator automation artifact, not yet reproduced on physical hardware

### 2026-08-14 — G4 iPhone lifecycle (started)

- Host/OS/device: as above (iPhone 16 Simulator, iOS 18.5)
- Command: city loaded on phone; Simulator Home button → app background; `simctl terminate`/`launch` → relaunch
- Result: on `SDL_APP_WILLENTERBACKGROUND` the engine pauses the sim and writes `Save/EmeraldG1/lifecycle.svx` (`File write successful … VERSION: 189`, `Save game: OK`); the file survives a terminate-while-backgrounded + relaunch. Foreground leaves the sim paused (resume is player-driven).
- Evidence: `docs/validation/g4-iphone-lifecycle.md`, `artifacts/private/g3-sim/`
- Proves: lifecycle autosave, pause-on-background, save persistence across relaunch
- Next: 20 bg/fg cycles, UI load of the lifecycle save, manual-save preservation, interrupted-import/low-storage, in-place update survival
- Fact vs inference: facts measured; the 20-cycle and interrupted-import behaviors are untested
