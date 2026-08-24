# Emerald Tablet — goal loop and handoff

Last updated: 2026-08-24.

## The goal (do not shrink it)

Build a native Apple product from the pinned open-source Akhenaten engine that
lets users supply their own legally obtained Pharaoh + Cleopatra game files and
play the supported Akhenaten experience on:

1. Apple Silicon macOS
2. iOS on iPhone
3. iPadOS on iPad, with Apple Pencil mode modeled on CaesarPad

Developer-preview definition of done: **G0–G5 and G9 pass**, the agreed
developer-preview subset of **G6** is measured and documented, Mac/iPhone
Simulator/iPad Simulator were tested in that order, every required evidence
class (clean build, package, install, PID, authentic gameplay, input, audio,
save/reload, lifecycle) is separate and present, artifacts are data-free and
reproducible, and compatibility wording matches measured reality.

Physical G7/G8 remain human/device gates. G7 is open because no iPhone has been
attached. G8 is partial: the current iPad build has physical acceptance for
Pencil movement, construction/cancellation, game-speed controls, representative
one- and multi-tile placement, and Save Game flow. Do not extend those results
to audible output, lifecycle interruption, sustained performance, or broader
campaign play without separate evidence.

## The loop (repeat every turn)

1. **Read first**: this file, `docs/IMPLEMENTATION_PLAN.md`, `STATE.md`, and
   `AGENTS.md`. Preserve the original goal; never shrink it to an easier subset.
2. **Audit current state**: `git status`, engine pin
   (`engines/akhenaten` = `38cb947ead3895408ea32f74fda6e37921a42bd3`), patch
   queue (`patches/akhenaten/0001..0017`), latest STATE.md experiments, and the
   live Simulator/desktop state (`xcrun simctl list`, `pgrep`, `osascript`
   window bounds). Work from current evidence, not memory.
3. **Pick the next single gate/step** from the priority queue below. Do not
   start cosmetic work on a gate that is blocked by a prerequisite.
4. **Make the smallest falsifiable change** (patch or test), **run the
   reproducible command**, and **capture evidence** under
   `docs/validation/<gate>/` or `artifacts/private/<gate>-*/` (screenshots and
   raw logs stay private; docs get the summaries).
5. **Record the experiment in STATE.md** with: date, host, wrapper+engine
   commits, exact command, result, evidence path, what it proves, next action,
   fact vs inference.
6. **Verify no regression** on already-passed gates when a patch touches shared
   code (macOS build after engine patches; iOS build after macOS patches).
7. If blocked: retry the authorized path once, then either continue with
   independent work or stop with an honest report. Do not fabricate passes.
8. **Stop only when** the developer-preview DoD is achieved (all evidence
   present) or a genuine human-only gate (G7/G8, signing, publication, naming)
   remains.

## Priority queue (next steps first)

| # | Step | Gate | Status |
|---|---|---|---|
| 1 | G5: 11"/13" city-from-save, overlay, Pencil toggle | G5 | DONE 2026-08-15 |
| 2 | G3 remainder: touch scale / safe areas / keyboard wiring | G3 | DONE 2026-08-15 |
| 3 | G4 remainder: 30 bg/fg cycles, lifecycle UI load, manual-save preservation, update survival, low-space preflight | G4 | DONE 2026-08-15 |
| 4 | G6 subset: compat matrix + save directionality + flake audit | G6 | DONE 2026-08-15 |
| 5 | G9: dmg, IPA, manifests, checksums, notices, docs, verifier | G9 | DONE 2026-08-15 (local artifacts) |
| 6 | Physical G7/G8, hosted release, legal review | HUMAN | G8 partial and current control/placement slice accepted; G7 and remaining hardware/release gates open |

## Current gate state (verified 2026-08-14)

| Gate | Status |
|---|---|
| G0 workspace/source safety | PASS — clean pin, safety scan, ignored ref/ |
| G1 macOS baseline | PASS — user-confirmed authentic Nubt play; open sub-items tracked into G6 (clean quit, save reload, Cleopatra entry, build/inspect clicks) |
| G2 iOS build seam | PASS — GAME_PLATFORM_IOS split, mobile-off options, iOS app target families 1+2, audit clean |
| G3 iPhone Simulator | CORE PASS — install/PID, data-required flow, real UIDocumentPicker import, menu → Nubt briefing, macOS save loaded (VERSION 189), in-city tap. Remains: phone touch scale/keyboard/safe-area polish |
| G4 iPhone lifecycle | CORE DONE — background → pause + lifecycle.svx autosave measured, survives relaunch. Remains: 20 cycles, UI load of lifecycle save, manual-save preservation, import-interrupt/low-storage, update survival |
| G5 iPad + Pencil shell | CORE PASS — mini/11"/13" proven |
| G6 subset / G9 | CORE DONE (developer-preview subset + local artifacts) |
| G7/G8 physical | G7 HUMAN/OPEN; G8 PARTIAL — current iPad construction, cancellation, Pencil movement, speed controls, and Save Game flow physically accepted |

## Environment facts (verify live, don't trust stale values)

- Host: Chris-Macbook-Air-M1.local, macOS 26.5.2, one built-in Retina display
  (2560x1600 @2x = 1440x900 points, visible frame 1440x870). No external
  displays. Anything that tries to move a window beyond the visible frame gets
  clamped by the window server.
- Desktop game (windowed): the user moved the window themselves. **Do not fight
  the user's window placement or spend time re-confirming desktop play** — G1 is
  accepted. If a window bounces between positions/sizes in the engine log, it is
  an automation loop, not the game; stop the automation and leave the window
  where the user put it.
- One windowed Mac runtime may stay running for Mac-side evidence; the current
  PID lives at `artifacts/private/g1-play/akhenaten-log.txt`.
- Simulators: iPhone 16 `212F13B4-01EE-453E-8B30-EFD7198D6C42` (G3/G4 data +
  saves), iPad mini `7D8C148F-3B11-43B3-A032-0D6DBE40C366` (menu reached,
  city-loadable), iPad Pro 11" `08636791-2675-4675-8335-EF72EF954DCF` (menu
  reached, taps unreliable), iPad Pro 13" `02BFE363-AA20-48BD-BBE0-7DBEB4AD8713`
  (splash reached). After `simctl install`, re-write cfg/conf for the NEW app
  container path (see STATE.md G3/G4 entries).
- Simulator windows: only one is visible/frontmost at a time; use
  `osascript` AXRaise on the target window before tapping. Sky coordinates are
  window-relative; `simctl io ... screenshot` gives device-accurate pixels.

## Patch queue (validated clean-apply 0001→0017)

- `0001-macos-propagate-deployment-target.patch` — minos 11.7 across deps.
- `0002-macos-curl-secure-transport.patch` — Secure Transport for curl.
- `0003-ios-build-seam.patch` — GAME_PLATFORM_IOS split + iOS backend/target.
- `0004-ios-pencil-shell.patch` — Apple Pencil distinct SDL touch identity,
  `is_stylus` touch flag, pencil mode feature (`gameui_pencil_mode`), Options
  menu toggle ("Pencil mode: OFF/ON"), JS/localization wiring.
- `0005-ios-auto-display-scale.patch` — per-device iOS display-scale default so
  the fixed 1024x768 logical view fills each iPad.
- `0006-ios-native-overlay-menu.patch` — native iOS "⋮" control overlay
  (pause, speed +/−, touch help) pinned to the top-right safe area.
- `0007`-`0009` — physical-iPad usability, refined input, local mod import,
  presentation defaults, and the persistent native control popover.
- `0010`-`0012` — isolated save-loader/legacy compatibility repairs with
  explicit support boundaries.
- `0013`-`0015` — complete construction cancellation and Pencil/touch tool
  exit behavior, plus direct iOS game startup and in-engine options access.
- `0016` — independent two-finger pan tuning and the live game-speed display.
- `0017` — correct multi-tile confirmation at every camera orientation.

`scripts/apply-patches.sh` reverse-applies and re-applies the queue on a clean
pinned engine. Build scripts: `scripts/build-macos.sh`,
`scripts/build-ios-sim.sh`, audits `scripts/audit-macos-app.sh` /
`scripts/audit-ios-app.sh`. Full iOS Simulator rebuilds take ~30-45 min; use
incremental `cmake --build build/ios-sim --config RelWithDebInfo` for source-only
changes (but rebuild SDL2 after `BuildSDL2.cmake` edits).

## Evidence and privacy rules

- Raw logs/screenshots → `artifacts/private/` (gitignored). Summaries → docs.
- Never stage/commit/push unless the user asks. `ref/`, `build/`, apps, saves,
  IPAs, signing material stay local/ignored.
- Never list/hash/reproduce original game data, art, saves, or private refs.
  Redact as `[private-data]`.
- One evidence class never substitutes for another (compile ≠ install ≠ PID ≠
  gameplay ≠ audio ≠ save ≠ lifecycle).

## Open non-goals (explicitly not part of this task)

- No Discord servers, community outreach, or third-party accounts.
- No App Store / TestFlight / paid / notarized distribution without user
  authorization and legal review.
- No physical-device claims without physical hardware.
