# G1 authentic play - launch attempt 1 failed at engine-data check

Date: 2026-08-13. Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 arm64.
Wrapper: `e979df7` plus uncommitted G0/G1 tree. Engine pin:
`38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001 and 0002 applied.

## Command

```sh
build/macos/akhenaten.app/Contents/MacOS/akhenaten \
  --window --size 1280x800 --pos 40,40 --no-logo --nointro \
  --noconfig-window --nocrashdlg \
  artifacts/private/g1-play
```

## Result

- PID `87045` was captured; process exited within seconds.
- `stdout.log` ends with:

```
Akhenaten version 0.2.7 b12613 2026-08-13 20:48:11 macosx
Initializing SDL
SDL initialized
Engine set to Akhenaten
Attempting to load game from /Users/chrissotraidis/GitHub/emeraldtablet/artifacts/private/g1-play
Detected language: English
error: engine data missing: Data/neucha.ttf
error: engine data missing: Data/pharaoh_fonts_pack.sgx
error: engine data missing: Data/pharaoh_custom_pack.sgx
error: engine data missing: Data/pharaoh_houses_pack.sgx
```

- Raw evidence: `artifacts/private/g1-play-logs/stdout.log`,
  `artifacts/private/g1-play-logs/stderr.log`, `pid.txt`, `launch-start.txt`.

## Root cause (verified in source)

`check_engine_data_files()` in `engines/akhenaten/src/platform/akhenaten.cpp`
requires four Akhenaten engine-owned files under `Data/` (or `data/`) in the
game data directory:

- `neucha.ttf`
- `pharaoh_fonts_pack.sgx`
- `pharaoh_custom_pack.sgx`
- `pharaoh_houses_pack.sgx`

These are engine assets shipped by the Akhenaten build (see
`AKHENATEN_DATA_FILES` in `engines/akhenaten/CMakeLists.txt`) and are **not**
part of the original Pharaoh install. They are present in the app bundle at
`build/macos/akhenaten.app/Contents/MacOS/Data/`.

The overlay `artifacts/private/g1-play/Data` is a symlink into
`ref/Pharaoh + Cleopatra/Data` (original game data), which does not contain
these files. The engine abort path shows an SDL message box and exits.

Mission maps also resolve as `data/maps/<mission>.map` (for example
`data/maps/m_000_nubt.map`), and those maps are engine-owned too (54 maps in
the app bundle `Data/maps`). The original Data folder has no `maps/`.

## Fix (private overlay only, ref/ untouched)

Replace the overlay `Data` symlink with a real directory that contains
per-entry symlinks to the original data **plus** the engine-owned files and
maps. Never write into `ref/`.

```sh
PLAY=artifacts/private/g1-play
ORIG="ref/Pharaoh + Cleopatra/Data"
APP_DATA=build/macos/akhenaten.app/Contents/MacOS/Data
rm "$PLAY/Data"                       # the symlink only; ref/ is untouched
mkdir "$PLAY/Data"
for f in "$ORIG"/*; do ln -s "$f" "$PLAY/Data/$(basename "$f")"; done
for f in neucha.ttf pharaoh_fonts_pack.sgx pharaoh_custom_pack.sgx pharaoh_houses_pack.sgx default.map; do
  ln -s "$APP_DATA/$f" "$PLAY/Data/$f"
done
ln -s "$APP_DATA/maps" "$PLAY/Data/maps"
```

Then relaunch the exact command above. Verify the process stays alive, the
main menu appears, and `[test-marker] main_menu_shown` is logged.

## Proves

Process launch and data-directory selection are wired; the engine-data gate is
real and must be satisfied before authentic play can be attempted. This is a
measured failure, not a gameplay pass.

## Next

Merge engine data into the overlay, relaunch, drive menu -> Nubt.
