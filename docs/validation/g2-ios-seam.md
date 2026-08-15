# G2 — iOS build seam

Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 (25F84) arm64.
Wrapper `e979df7` plus uncommitted G0/G1/G2 tree. Engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001, 0002, and
`0003-ios-build-seam.patch` applied in the submodule worktree.

## What was built

`scripts/build-ios-sim.sh` configures the pinned engine with the Xcode
generator for the iPhone Simulator SDK and produces a data-free app at
`build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app`. Dependencies
(SDL2, SDL2_mixer, FreeType, HarfBuzz, zlib, libpng) are built as static
libraries for `arm64-apple-ios15.0-simulator` through the existing `cmake -P`
helpers, with SDK/arch/deployment/build-type propagated via
`BUILD_ADDITIONAL_CMAKE_ARGS`.

## Platform split

`src/platform/platform.h` now distinguishes iOS from macOS inside the Apple
branch (`TARGET_OS_IOS`):

- `GAME_PLATFORM_IOS` + `GAME_PLATFORM_APPLE` for iPhone/iPad
- `GAME_PLATFORM_MACOSX` + `GAME_PLATFORM_APPLE` for macOS
- `GAME_PLATFORM_APPLE` is the shared marker for common Apple behavior

CMake detects iOS via `IOS` or the `iphoneos|iphonesimulator` sysroot before
any generic APPLE handling (`PLATFORM_IOS`), and the iOS app target sets
`TARGETED_DEVICE_FAMILY 1,2` (iPhone + iPad), `mt.dalerank.akhenaten`, and the
same deployment target as the dependencies.

## Mobile-off components (verified absent)

| Component | Status on iOS |
|---|---|
| Cocoa / Carbon / ForceFeedback / AppKit | not linked (UIKit + system frameworks only) |
| `akhenaten-updater` helper | not built |
| innoextract / installer extraction | not built; stubs return "not supported on iOS" |
| curl / network (`GAME_HAVE_CURL`) | not built |
| cpptrace / Tracy / video recording | disabled |
| desktop `launch.sh` / `Contents/` layout | not produced |
| `system()` / fork / exec / getpwuid | excluded or stubbed (TTS synth, imgui mkdir, URL open via `SDL_OpenURL`) |
| shell-based URL opening | replaced with `SDL_OpenURL` on iOS |

## New/adapted sources

- `src/platform/platform_ios.cpp` — minimal iOS backend: SDL poll loop, user
  directory via `SDL_GetPrefPath`, `SDL_OpenURL`, virtual-keyboard via
  `SDL_StartTextInput`/`SDL_StopTextInput`, landscape orientation hint.
- `res/ios/Info.plist` — iPhone landscape; iPad all orientations; full-screen,
  hidden status bar.
- macOS-only guards added for the FSEvents folder notifier, `getpwuid` config
  paths, `system()`-based mkdir, and the desktop TTS helper.
- SDL2_mixer helper: native-MIDI disabled on iOS (macOS-only AudioUnit path);
  timidity remains the MIDI backend. MIDI playback quality is tracked in the
  G6 matrix.

## Audit (2026-08-14)

`scripts/audit-ios-app.sh` passes:

- architecture: arm64
- platform: `IOSSIMULATOR`, minos 15.0, sdk 26.5
- linkage: only system iOS frameworks (UIKit, Metal, CoreBluetooth,
  GameController, AudioToolbox, …); no Homebrew dylibs
- bundle id: `mt.dalerank.akhenaten`
- no desktop artifacts (`launch.sh`, `akhenaten-updater`, `Contents/`)
- engine `Data/` (fonts, packs, `default.map`) + 54 mission maps in the bundle

Full output: `docs/validation/g2-ios-audit.txt`.

## Notes / open items

- MIDI on iOS uses timidity; a runtime soundfont is not yet confirmed in the
  shipped data (G6 music item).
- The iOS app is unsigned (`CODE_SIGNING_ALLOWED=NO`), correct for the
  Simulator; physical-device signing is a G7 human gate.
- `CMAKE_FIND_ROOT_PATH_MODE_*` are set to `BOTH` for dependency helpers so
  local static installs stay findable under the iOS cross environment.

## Next

G3 — boot a small iPhone Simulator, install and launch the app, verify process
launch, then the Game Data Required flow and the document-picker importer.
