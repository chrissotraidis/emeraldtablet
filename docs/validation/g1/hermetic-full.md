# G1 hermetic integral suite

Date: 2026-08-13
Host: Chris-Macbook-Air-M1.local, macOS 26.5.2 (25F84), Darwin 25.5.0 arm64
Xcode: 26.6 (17F113)
CMake: 4.4.0
Wrapper: `e979df7` plus uncommitted G0/G1 wrapper files
Engine: `38cb947ead3895408ea32f74fda6e37921a42bd3`
Patch queue:
- `patches/akhenaten/0001-macos-propagate-deployment-target.patch`
- `patches/akhenaten/0002-macos-curl-secure-transport.patch`

## Command

```sh
scripts/run-macos-hermetic.sh
```

The wrapper `cd`s to `engines/akhenaten` before launching
`build/macos/akhenaten.app/Contents/MacOS/akhenaten --integraltests --no-logo --no-resource --window --size 800x600`.
Dummy SDL video/audio drivers are used for this suite only.

## Result

- `[integraltests] 194 test file(s)`
- `[integraltests] 194 passed, 0 failed`
- `[integraltests] all checks passed`

The earlier wrapper-root cwd miss (`0 test file(s)`) is recorded separately in
`docs/validation/g1/hermetic-cwd-miss.md`. An empty suite is not a green baseline.

## What this proves

- Hermetic **test** baseline only.

## What this does not prove

- Authentic gameplay
- Real-window rendering
- Live input
- Real audio output
- Save/reload of an authentic city
- Cleopatra campaign entry
- Package, install, PID, or lifecycle

## Fact vs inference

Fact. Raw stdout/stderr remain in ignored `artifacts/private/g1/hermetic-full.stdout`
and `artifacts/private/g1/hermetic-full.stderr`.
