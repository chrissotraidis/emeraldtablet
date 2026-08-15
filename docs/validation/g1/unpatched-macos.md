# G1 unpatched macOS first build

Date: 2026-08-13
Host: Chris-Macbook-Air-M1.local, macOS 26.5.2 (25F84), Darwin 25.5.0 arm64
Xcode: 26.6 (17F113)
CMake: 4.4.0
Wrapper: `e979df7` plus uncommitted G0 files
Engine: `38cb947ead3895408ea32f74fda6e37921a42bd3`
Patch queue: empty

## Commands

```sh
scripts/build-macos.sh
file build/macos/akhenaten.app/Contents/MacOS/akhenaten
otool -L build/macos/akhenaten.app/Contents/MacOS/akhenaten
vtool -show-build build/macos/akhenaten.app/Contents/MacOS/akhenaten
```

Hermetic smoke (not the full suite):

```sh
SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy   build/macos/akhenaten.app/Contents/MacOS/akhenaten   --integraltests --no-logo --no-resource --window --size 800x600   --integraltest-only 01_main_menu
```

## Results

- Configure/build exit 0. App path: `build/macos/akhenaten.app`.
- Binary is `Mach-O 64-bit executable arm64`.
- Main executable `LC_BUILD_VERSION` is `platform MACOS`, `minos 11.7`, `sdk 26.5`.
- SDL2/FreeType/HarfBuzz/SDL2_mixer static objects are `minos 26.0`. The link log contains many `was built for newer 'macOS' version (26.0) than being linked (11.7)` warnings.
- Dynamic Homebrew linkage:
  - `/opt/homebrew/opt/openssl@3/lib/libssl.3.dylib`
  - `/opt/homebrew/opt/openssl@3/lib/libcrypto.3.dylib`
  - `/opt/homebrew/opt/libnghttp2/lib/libnghttp2.14.dylib`
- `akhenaten-updater` was also produced. That helper is optional for the Apple MVP.
- Hermetic smoke: `tests/01_main_menu.js` PASS, process `EXIT:0`. The driver listed 194 files but only executed the requested single test. This is **not** a green hermetic baseline.
- No authentic Pharaoh data, audio, mission, save, or Cleopatra check was performed in this experiment.

## What this proves

- Unpatched Mac **build** reproduction at the research pin.

## What this does not prove

- Self-contained package
- Deployment-target inheritance
- Full hermetic suite
- Authentic gameplay, input, audio, save/reload, or Cleopatra detection

## Fact vs inference

Fact. The list-splitting explanation for the deployment-target miss is an inference confirmed by `CMakeLists.txt` passing `BUILD_ADDITIONAL_CMAKE_ARGS` as a CMake list through one `-D` argument; SDL2 objects being arm64 with `minos 26.0` matches that split.
