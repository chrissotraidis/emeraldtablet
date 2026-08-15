# G1 patched macOS build and package audit

Date: 2026-08-13
Host: Chris-Macbook-Air-M1.local, macOS 26.5.2 (25F84), Darwin 25.5.0 arm64
Xcode: 26.6 (17F113)
CMake: 4.4.0
Wrapper: `e979df7` plus uncommitted G0/G1 wrapper files
Engine: `38cb947ead3895408ea32f74fda6e37921a42bd3`
Patch queue:
- `patches/akhenaten/0001-macos-propagate-deployment-target.patch`
- `patches/akhenaten/0002-macos-curl-secure-transport.patch`

## Commands

```sh
scripts/apply-patches.sh
scripts/build-macos.sh
scripts/audit-macos-app.sh build/macos/akhenaten.app
tests/packaging/test_macos_self_contained.sh
```

Stale unpatched cache was moved aside to `build/macos.old-unpatched-51852` before this rebuild.

## Results

- Configure/build produced `build/macos/akhenaten.app`.
- Binary is `Mach-O 64-bit executable arm64`.
- Main executable `LC_BUILD_VERSION` is `platform MACOS`, `minos 11.7`, `sdk 26.5`.
- SDL2, SDL2_mixer, FreeType, and HarfBuzz static objects are `minos 11.7`.
- The patched build log contains no `built for newer macOS version` warnings.
- Dynamic linkage is system-only. No Homebrew OpenSSL/nghttp2, no `/usr/local`, workspace, temporary, or `@rpath` runtime libraries.
- Cache flags: `CURL_USE_SECTRANSP=ON`, `CURL_USE_OPENSSL=OFF`, `USE_NGHTTP2=OFF`, `CURL_USE_LIBPSL=OFF`.
- `scripts/audit-macos-app.sh` passed. `tests/packaging/test_macos_self_contained.sh` also passes after the audit ignores the Mach-O header line that contains the workspace path.

## What this proves

- Patched Mac **build** and **package** (self-contained, deployment-target inheritance).

## What this does not prove

- Full hermetic suite
- Authentic gameplay, input, audio, save/reload, or Cleopatra detection

## Fact vs inference

Fact.
