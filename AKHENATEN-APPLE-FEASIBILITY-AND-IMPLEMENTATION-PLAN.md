# Akhenaten on macOS, iOS, and iPadOS

## Feasibility research and end-to-end implementation plan

**Research date:** 2026-08-13  
**Status:** Conditional GO; executable implementation plan  
**Reference Apple product:** CaesarPad  
**Engine:** Akhenaten, pinned during research to `38cb947ead3895408ea32f74fda6e37921a42bd3`  
**Original game:** the 1999 Windows release sold as *Pharaoh + Cleopatra*, not *Pharaoh: A New Era*

---

## 1. Executive verdict

An Akhenaten-based Pharaoh + Cleopatra experience for Apple Silicon macOS, iPhone, and
iPad is **technically feasible**. Proceed with the implementation, subject to the gates in
this document.

This is a stronger starting point than a new port:

- Akhenaten is itself a Julius/Augustus-derived, portable C/C++17 and SDL2 engine.
- It already builds for arm64 and x86_64 macOS, Android, Linux, Windows, and the web.
- It already accepts SDL finger events and contains touchpad, direct, and original touch
  modes.
- It has an engine/platform seam, a CMake build, a bring-your-own-data flow, original-save
  loading code, and 194 JavaScript integral-test files plus C++ smoke checks.
- The current source built locally as an arm64 macOS `.app` during this research.
- CaesarPad supplies proven designs for the remaining Apple product layer: landscape
  configuration, Files-visible data, native folder import, background autosave, touch
  gestures, an unobtrusive help/Pencil toolbar, Simulator scripts, device packaging, and
  repository-safety checks.

The project is **not** a copy-and-rename of CaesarPad. Akhenaten has diverged substantially:
it is roughly 460,000 source lines, most of its game code is C++, it embeds a MuJS-driven
game/UI layer, its dependency graph is larger, its root Apple logic currently means
macOS—not iOS—and its data and save contracts are Pharaoh-specific. CaesarPad is a design
and validation reference, not a patch source to apply blindly.

There are two separate feasibility claims:

1. **Apple-platform feasibility: GO, medium-high confidence.** There is no discovered
   architectural blocker to compiling, launching, importing data, rendering, handling
   touch/Pencil, saving, and packaging Akhenaten on iOS/iPadOS.
2. **Complete Pharaoh + Cleopatra compatibility: unproven.** Akhenaten's own README says
   development is in progress and currently describes original-save loading and initial
   campaign missions without major issues. A finished Apple shell cannot make an
   incomplete engine complete. The product must remain a developer preview until the
   campaign, Cleopatra, save, audio, video, monument, naval, and long-session gates pass.

The correct product statement at the outset is therefore:

> An experimental Apple port of the open-source Akhenaten engine that requires the user's
> own legally obtained Pharaoh + Cleopatra data. Compatibility is validated mission by
> mission and is not yet universal.

### Confidence by dimension

| Dimension | Confidence | Why |
|---|---:|---|
| Apple Silicon macOS compile | High | Current pinned source built locally as arm64 |
| macOS launch to engine/data gate | High | Executable and CLI initialized locally |
| macOS authentic gameplay | Pending | No proprietary data was supplied in this research phase |
| iOS/iPadOS compile | Medium-high | SDL2 and CMake support iOS; code is portable, but Akhenaten has no iOS target today |
| iPhone/iPad rendering | Medium-high | SDL renderer/touch paths exist; device SDK and dependency work remain |
| Touch-first play | Medium | Existing touch layer plus CaesarPad prior art; needs adaptation and usability testing |
| Apple Pencil | Medium | CaesarPad implementation is proven, but SDL/UIKit changes must be ported deliberately |
| Save/data safety | Medium-high | Clear filesystem seam and CaesarPad design; Akhenaten currently writes saves with game data |
| Full base campaign | Unknown | Must be proven with authentic files and a mission matrix |
| Full Cleopatra campaign | Unknown/high risk | Upstream work-in-progress and expansion-specific systems require direct testing |
| Public binary distribution | Medium | Technically straightforward; licensing, trademark, and source-offer review required |

---

## 2. Evidence and research boundaries

### 2.1 Primary sources inspected

- [Akhenaten repository](https://github.com/dalerank/Akhenaten), including the pinned
  [README](https://github.com/dalerank/Akhenaten/blob/38cb947ead3895408ea32f74fda6e37921a42bd3/README.md),
  [CMake build](https://github.com/dalerank/Akhenaten/blob/38cb947ead3895408ea32f74fda6e37921a42bd3/CMakeLists.txt),
  [platform selection](https://github.com/dalerank/Akhenaten/blob/38cb947ead3895408ea32f74fda6e37921a42bd3/src/platform/platform.h),
  [touch implementation](https://github.com/dalerank/Akhenaten/blob/38cb947ead3895408ea32f74fda6e37921a42bd3/src/input/touch.cpp),
  [test documentation](https://github.com/dalerank/Akhenaten/blob/38cb947ead3895408ea32f74fda6e37921a42bd3/tests/README.md),
  workflows, resource layout, save schemas, data validation, updater, and license.
- [Pharaoh + Cleopatra Steam listing](https://store.steampowered.com/app/564530/Pharaoh__Cleopatra/),
  which identifies the 1999 Impressions Games title, the included Cleopatra expansion,
  Windows-only system requirements, and the approximately 1 GB storage requirement.
- SDL's official [CMake iOS guidance](https://wiki.libsdl.org/SDL2/README-cmake) and
  [iOS guidance](https://wiki.libsdl.org/SDL2/README-ios).
- Apple's official guidance for
  [directory access with `UIDocumentPickerViewController`](https://developer.apple.com/documentation/uikit/providing-access-to-directories)
  and security-scoped URLs.
- The local CaesarPad checkout at the research date, including its 13 maintained Augustus
  patches, build/package scripts, touch tests, UI tests, lifecycle tests, importer, and
  prior feasibility/PRD material.

### 2.2 Direct experiments performed

At Akhenaten commit `38cb947ead3895408ea32f74fda6e37921a42bd3`, on an arm64 Mac with
Xcode 26.6 and CMake 4.4.2:

1. Configured an arm64 RelWithDebInfo macOS build with Tracy, video recording, and installer
   extraction disabled.
2. Built the engine successfully to `akhenaten.app`.
3. Verified the executable is Mach-O arm64 and the app is approximately 73 MB before
   release cleanup.
4. Invoked the executable and confirmed engine initialization and its data/CLI gate.
5. Started the hermetic integral suite using dummy video/audio drivers.

The experiment also found three actionable baseline defects:

- Dependency sub-builds did not consistently inherit `CMAKE_OSX_DEPLOYMENT_TARGET=11.7`;
  the final link warned that many objects were built for macOS 26.0.
- The locally built binary dynamically referenced Homebrew OpenSSL and libssh2. That app is
  not yet a self-contained distributable macOS product.
- The hermetic test run was not clean. Many tests printed expected success markers and then
  failed because their checker could not find those markers in the configured log path.
  This looks like a logging/path/harness issue, but it is **not** counted as a pass. The
  pinned upstream test baseline must be repaired or conclusively explained before Apple
  patches are assessed.

### 2.3 What this research does not claim

- It does not claim authentic gameplay, music, video, saving, or mission completion; no
  Pharaoh data was used.
- It does not claim an iOS binary already exists. It does not.
- It does not claim every Akhenaten test or every campaign mission passes.
- It does not claim App Store acceptance or give legal advice.
- It does not authorize committing or distributing original game data, signing material,
  user saves, screenshots containing copyrighted art, or generated packages.

---

## 3. Product and scope definition

### 3.1 Product goal

Create one Apple-focused wrapper product around a pinned Akhenaten engine that:

- builds and runs natively on Apple Silicon macOS;
- builds and runs on iPhone and iPad using one iOS application target;
- imports the user's own Pharaoh + Cleopatra installation folder;
- offers playable touch controls on both phone and tablet;
- reproduces CaesarPad's precise Apple Pencil mode on supported iPads;
- preserves original data and saves through lifecycle transitions and upgrades;
- produces reproducible ROM/data-free source and binary artifacts; and
- states Akhenaten compatibility honestly.

Use a neutral working repository name until the user chooses branding. `PharaohPad` may be
used in private notes as a placeholder only. Before public distribution, perform a naming
and trademark review and prefer an original name that does not imply ownership or official
endorsement by Activision, Impressions Games, Akhenaten, Julius, or Augustus.

### 3.2 Required platform order

The implementation and validation order is fixed:

1. **macOS arm64**: prove upstream data compatibility and gameplay before mobile work.
2. **iOS on an iPhone Simulator**: prove cross-compilation, app lifecycle, layout floor,
   import, and phone usability.
3. **iPadOS on an iPad Simulator**: prove tablet layout, touch defaults, menu shell, and
   Pencil-facing UI.
4. **Physical iPhone**, then **physical iPad**: prove real touch, audio, lifecycle,
   performance, thermal behavior, and Pencil. Simulator results never substitute for these.

Do not start iPad polish while the equivalent iPhone gate is red unless the red item is
explicitly documented as form-factor-specific and the shared engine/runtime gates are green.

### 3.3 MVP and non-goals

The MVP is a developer preview that can import a valid English Steam/GOG Pharaoh +
Cleopatra folder, start a known-supported mission, place and inspect buildings, play audio,
save, background/foreground safely, relaunch, and reload the save on Mac, iPhone Simulator,
and iPad Simulator.

Initial non-goals:

- no *Pharaoh: A New Era* assets or compatibility;
- no bundled original game files;
- no on-device extraction of Windows `.exe` installers for MVP;
- no in-app updater on iOS/iPadOS;
- no downloaded executable scripts or code on iOS/iPadOS;
- no iCloud synchronization until local data safety is proven;
- no controller-first redesign;
- no gameplay rewrites to work around upstream Akhenaten incompleteness;
- no universal “all missions work” claim without the release matrix;
- no App Store submission in the core implementation loop.

---

## 4. Why CaesarPad helps—and where it does not

### 4.1 Reuse as a behavioral reference

The implementation bot should inspect, understand, and selectively adapt these CaesarPad
components:

| CaesarPad area | Reuse intent |
|---|---|
| `scripts/fetch-deps.sh` | Pinned downloads, hashes, repeatability, temporary directories |
| `scripts/build.sh` / `build-device.sh` | Separate Simulator/device products and signing-free builds |
| `scripts/install.sh` / `inject-data.sh` | Select, boot, install, inject, launch, and verify distinctly |
| `scripts/package-ios.sh` | Unsigned IPA layout and package audit |
| `scripts/check-repo-safety.sh` | Patch-chain, private-data, package, and generated-artifact exclusions |
| iOS folder picker | Security-scoped selection, async copy, progress, self-copy handling, recoverable errors |
| lifecycle patch | Background autosave, pause, foreground/cold-launch behavior |
| touch patches | Long press, two-finger tap, pan-vs-pinch intent, visible cursor |
| Pencil patch | Separate SDL Pencil touch identity, persistent mode, finger navigation while Pencil selects |
| native help/Pencil bar | Small safe-area-aware overlay with accessibility labels |
| UI/touch/lifecycle tests | Test style and evidence structure |
| README/license/release docs | Bring-your-own-data wording and artifact boundaries |

### 4.2 Do not copy mechanically

Do not apply CaesarPad's Augustus patches directly. Re-derive each change against Akhenaten:

- Akhenaten touch code is C++, uses different types and names, and lacks CaesarPad's current
  long-press, Pencil, and gesture-intent fields.
- Akhenaten's app loop lives in `src/platform/akhenaten.cpp`, not Augustus's SDL platform
  file.
- Akhenaten currently treats every `__APPLE__` target as macOS.
- Akhenaten has MuJS, ImGui, Freetype, HarfBuzz, curl, cpptrace, Tracy, OpenH264 options,
  installer helpers, an updater, and a larger static dependency graph.
- Akhenaten's validator looks for `campaign.txt` and Pharaoh/Cleopatra packs; CaesarPad
  looks for Caesar III markers.
- Akhenaten writes saves relative to its data root. Preserve that semantic initially, then
  sandbox it deliberately.
- The game menu, help wording, pause semantics, cursor scale, and supported gestures must
  describe Pharaoh/Akhenaten, not Caesar III/Augustus.

The right standard is behavioral parity with CaesarPad's good Apple experience, implemented
through Akhenaten's own seams.

---

## 5. Target repository architecture

### 5.1 Repository layout

```text
<new-repo>/
├── AGENTS.md
├── README.md
├── LICENSE
├── RIGHTS_AND_LICENSES.md
├── THIRD_PARTY_NOTICES.md
├── STATE.md
├── FINAL_REPORT.md
├── .gitignore
├── .gitmodules
├── assets/
│   └── ios/                       # original app icon/launch assets only
├── docs/
│   ├── IMPLEMENTATION_PLAN.md     # a copy/evolution of this document
│   ├── INSTALL_MACOS.md
│   ├── INSTALL_IPA.md
│   ├── CONTROLS.md
│   ├── COMPATIBILITY.md
│   ├── RELEASE_CHECKLIST.md
│   └── validation/                # dated evidence, no proprietary art unless explicitly approved
├── engines/
│   └── akhenaten/                 # pinned upstream git submodule
├── patches/
│   └── akhenaten/                 # small ordered patch queue
├── platform/
│   └── ios/                       # app-owned UIKit/Obj-C or Swift glue if not suitable upstream
├── scripts/
│   ├── bootstrap-ref.sh
│   ├── fetch-deps.sh
│   ├── apply-patches.sh
│   ├── build-macos.sh
│   ├── build-ios-simulator.sh
│   ├── build-ios-device.sh
│   ├── install-simulator.sh
│   ├── inject-data-simulator.sh
│   ├── package-macos.sh
│   ├── package-ios.sh
│   ├── check-repo-safety.sh
│   └── verify-release-candidate.sh
├── tests/
│   ├── touch/
│   ├── ui/
│   ├── lifecycle/
│   └── fixtures/                  # synthetic only
└── ref/                           # local-only, completely ignored by Git
    ├── Akhenaten/                  # user-supplied/reference source checkout
    ├── CaesarPad/                  # reference implementation checkout
    └── Pharaoh + Cleopatra/        # user-owned installed game data
```

### 5.2 `ref/` contract

The bot must treat `ref/` as read-only input unless it creates a clearly named temporary
copy beneath `build/` or the operating-system temporary directory.

Expected contents:

- `ref/Akhenaten`: a complete upstream checkout. Record its remote and exact commit.
- `ref/CaesarPad`: a complete CaesarPad checkout. Record its exact commit and patch list.
- `ref/Pharaoh + Cleopatra`: the installed original game data supplied by the user. It
  should contain `campaign.txt` and a `Data/` tree. Validate Cleopatra packs according to
  the pinned Akhenaten validator rather than guessing filenames from memory.

Rules:

1. Add `/ref/`, `/build/`, `/artifacts/private/`, signing files, profiles, archives,
   `.ipa`, `.dmg`, and local saves to `.gitignore` in the first commit.
2. Never `git add -f` anything beneath `ref/`.
3. Never copy original data into source, tests, app resources, documentation, releases, or
   CI artifacts.
4. Test fixtures must be synthetic marker/header fixtures that contain no original art,
   music, video, text, maps, or scenarios.
5. Before every commit and package, run a safety scan for known Pharaoh markers, extensions,
   large files, and paths.
6. `engines/akhenaten` is the tracked submodule used for builds. If network access is
   unavailable, initialize it from the local `ref/Akhenaten` object store, but leave its
   canonical upstream URL and pinned SHA recorded.

### 5.3 Patch policy

- Pin Akhenaten to a known SHA; never build release artifacts from a floating branch.
- Keep Apple changes as ordered, reviewable patches until they are upstreamed.
- Every patch header must contain purpose, upstream status, affected platforms, and tests.
- Split platform enablement, importer, lifecycle, touch, Pencil, identity, and packaging.
- Do not mix upstream gameplay fixes with Apple product work.
- A patch that changes game logic requires a focused upstream regression test and its own
  decision record.
- Rebuild from a clean submodule plus the patch queue in CI. An inherited dirty engine
  checkout is never release evidence.

---

## 6. Required technical design

### 6.1 Create a real iOS platform identity

The first source task is to stop equating all Apple targets with macOS.

Current risk: `src/platform/platform.h` classifies `__APPLE__` as
`GAME_PLATFORM_MACOSX`. The root CMake's `if(APPLE)` branches link Cocoa, Carbon,
ForceFeedback, create `Contents/MacOS`, and copy a desktop launch script. Those choices are
invalid for an iOS app even though CMake also sets `APPLE` when targeting iOS.

Implement explicit identities:

- `GAME_PLATFORM_IOS` for iPhone/iPad;
- `GAME_PLATFORM_MACOSX` only for macOS;
- optionally common `GAME_PLATFORM_APPLE` for shared code;
- use `TargetConditionals.h` or CMake compile definitions so device and Simulator agree;
- branch CMake using `CMAKE_SYSTEM_NAME STREQUAL "iOS"` before generic `APPLE` logic.

Add an iOS backend implementing Akhenaten's existing platform functions:

- SDL initialization flags and hint setup;
- event polling;
- the SDL-controlled iOS main loop;
- sandbox user directory resolution;
- initial data-directory request through UIKit;
- startup/error presentation;
- virtual keyboard show/hide;
- URL opening through documented UIKit APIs;
- lifecycle callbacks;
- no desktop `system("open …")`, passwd/home lookup, shell updater, or launch script.

Acceptance: a tiny iOS Simulator build compiles with `GAME_PLATFORM_IOS`, never compiles
the macOS backend, and links no Cocoa/Carbon/ForceFeedback framework.

### 6.2 Build profiles and dependencies

Introduce explicit options instead of platform side effects:

- `AKHENATEN_ENABLE_UPDATER`
- `AKHENATEN_ENABLE_NETWORK`
- `AKHENATEN_ENABLE_INSTALLER_EXTRACTION`
- `AKHENATEN_ENABLE_CPPTRACE`
- existing Tracy and video-recording options

For iOS/iPadOS MVP, set all five to OFF. The app is offline and imports an already
installed game folder. This reduces compile, review, entitlement, binary-size, dynamic
library, and downloaded-code risk.

Required iOS dependency audit:

| Dependency | MVP disposition | Proof required |
|---|---|---|
| SDL2 2.32.10 | Build from pinned source for device and Simulator | UIKit video, Metal/software renderer, touch, lifecycle events |
| SDL2_mixer 2.8.0 | Build only needed codecs statically | Music, speech, effects on device; no forbidden dynamic paths |
| zlib/libpng | Static, pinned | Device and Simulator compile; correct deployment target |
| Freetype/HarfBuzz | Static, pinned | Text renders and localized fallback works |
| stb/ImGui | Source/static | Compile; debug UI may be disabled in release |
| in-tree MuJS | Keep | No runtime download; embedded scripts bundled with source/app |
| in-tree bzip/lzma/LAME | Audit and compile statically | Architecture, license notices, warning review |
| curl/OpenSSL/libssh2 | OFF on iOS | No linked references in final binary |
| cpptrace/libdwarf/zstd | OFF initially on iOS | Re-enable only if a device-safe need is proven |
| Tracy | OFF in release | Optional internal profile build only |
| OpenH264/minimp4 recording | OFF on iOS | Original game playback is separate; debug recording is nonessential |
| desktop updater/innoextract/unshield | OFF on iOS | No helper executables in app |

Propagate `CMAKE_OSX_DEPLOYMENT_TARGET`, SDK root, architectures, bitcode setting if
applicable, and build type into **every** dependency sub-build. Treat any “built for newer
OS” linker warning as a failed deployment-floor check.

For macOS release builds, either disable networking/updater or make every non-system
dependency static/self-contained. `otool -L` must show no `/opt/homebrew`, `/usr/local`,
workspace, or temporary paths.

### 6.3 App target and resources

Generate an Xcode iOS app target through CMake or a thin maintained Xcode wrapper. Prefer
the smallest mechanism that can be regenerated and tested in CI.

Required app properties:

- one unique downstream bundle identifier;
- iPhone and iPad device families (`1,2`);
- landscape left/right initially;
- honest version/build values;
- original app icon and launch artwork;
- `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace` for Files visibility;
- documented indirect-input support if testing confirms it;
- no unsupported background modes;
- no private APIs;
- engine-owned `data/` resources bundled read-only;
- original game data stored only in the app container.

Do not add a large Swift/SwiftUI product framework unless UIKit/Objective-C becomes
unreasonably complex. CaesarPad proves a small native UIKit overlay is sufficient.

### 6.4 Data and save model

Use this container layout:

```text
Documents/
├── Pharaoh/                       # imported user-owned game installation
│   ├── campaign.txt
│   ├── Data/
│   └── ...
└── Akhenaten/                     # downstream-owned user output where feasible
    ├── Save/
    ├── Maps/
    └── Logs/
Library/Application Support/
└── <product>/                     # config, indexes, migration state
```

If separating `Save/` from the game root requires invasive engine changes, use
`Documents/Pharaoh/Save` for MVP and document it. Do not create symlinks as a shortcut on
iOS. The priority is safe, Files-visible, deterministic storage.

Importer algorithm:

1. Present a folder picker using `UIDocumentPickerViewController` with folder content type.
2. Start security-scoped access, coordinate reads, and always stop access when done.
3. Inspect before copy: locate `campaign.txt`, normalize a user selecting either the root
   or its parent, detect `Data/`, ask the pinned engine validator about required/optional
   packs, and calculate byte/file count and free-space requirement.
4. Refuse known *A New Era* or incomplete/demo layouts with a precise message.
5. Show progress while copying off the main thread into a sibling staging directory.
6. Never overwrite the live directory in place during import.
7. Validate the staged copy, record a manifest with relative path, size, and hashes for
   critical markers, then atomically promote it.
8. Preserve existing `Save/`, configs, and user maps across re-import. Back them up and
   verify restoration before deleting an old data tree.
9. On cancel/failure, remove only the task's validated staging directory and leave the
   live tree untouched.
10. On success, hand the internal path to Akhenaten and launch without restarting if safe;
    otherwise explain one controlled relaunch.

Do not persist an external security-scoped folder as the primary live data location for
MVP. Copying into the container is more predictable across providers, offline use,
revocation, and release testing.

### 6.5 Touch and Pencil model

Traditional touch:

- tap: move/select/activate;
- drag one finger on the map: pan without accidental placement;
- pinch: zoom, anchored at centroid;
- two-finger parallel drag: pan, not zoom;
- long press or two-finger tap: right click/cancel/inspect as the active game context uses it;
- maintain a visible software cursor when precision matters;
- never apply a gesture that started over a native toolbar to the game.

Pencil mode on supported iPads:

- patch SDL's UIKit view as narrowly as possible to register Pencil with a distinct touch
  identity;
- Pencil selects, inspects, draws, and places;
- fingers navigate/pan/zoom but cannot place while Pencil mode is enabled;
- persist the mode in app-owned preferences;
- expose one compact, labelled, accessible Pencil toggle and one help button;
- hide or adapt Pencil UI on iPhone and on devices without Pencil capability;
- test Pencil hover separately if supported; it is enhancement, not MVP.

Do not port CaesarPad's exact coordinates or scale constants. Measure Akhenaten's UI on
iPhone SE-class, regular iPhone, iPad mini, 11-inch iPad, and 13-inch iPad Simulator sizes.
Set form-factor-specific defaults and retain saved user choices.

### 6.6 Lifecycle and audio

Handle SDL app lifecycle events and UIKit notifications idempotently:

- on will-resign-active: pause input/simulation;
- on background: create a named lifecycle autosave if a city is active, flush config/save,
  stop rendering, and suspend audio;
- on foreground: revalidate resources and audio route, remain paused, and show a small
  resume affordance;
- on cold launch after termination: offer/load the lifecycle save according to a documented
  policy;
- never overwrite the user's sole manual save;
- debounce duplicate notifications;
- finish within iOS background time; do not start a large data copy while backgrounding.

Respect the mute switch unless the product decision explicitly chooses game-audio
playback semantics. Test headphones, Bluetooth, Control Center interruption, Siri/alarm,
and route changes on hardware.

---

## 7. Implementation phases and gates

Every phase ends in evidence. A green build alone does not imply install, launch, render,
gameplay, input, audio, save, lifecycle, or compatibility acceptance.

### Phase 0 — Bootstrap and protect the workspace

Tasks:

1. Inventory the new repo, Git status, host tools, Xcode/SDKs, Simulators, attached devices,
   and all `ref/` inputs.
2. Hash and record the exact Akhenaten and CaesarPad commits.
3. Validate—but do not display or commit—the Pharaoh folder markers.
4. Create `.gitignore`, `RIGHTS_AND_LICENSES.md`, `STATE.md`, and safety scripts first.
5. Add Akhenaten as a pinned submodule under `engines/akhenaten`.
6. Establish an empty, ordered patch queue and clean-apply check.
7. Copy this plan into the new repo and make it the controlling plan.

Exit gate G0:

- clean wrapper repo;
- `ref/` and private file scan pass;
- exact commits recorded;
- clean submodule plus empty patch queue reproduces upstream source;
- no original data is tracked.

### Phase 1 — Establish macOS upstream truth

Tasks:

1. Reproduce the current arm64 build with pinned options and dependency hashes.
2. Fix deployment-target propagation until the link has no newer-target warnings.
3. Remove Homebrew runtime linkage from the packaged app.
4. Diagnose the integral-test logging/path failure. Establish a green hermetic baseline or
   record a minimal upstream issue plus a local regression test for the fix.
5. Run the complete hermetic suite from a clean checkout.
6. With user data in `ref/`, launch the Mac app and validate the folder using current engine
   rules.
7. Start one known-supported early Pharaoh mission; play for at least 20 minutes; exercise
   build, inspect, advisor, speed, audio, save, quit, and reload.
8. Load a copy of an original Pharaoh save if one is provided; never alter the only copy.
9. Start at least one Cleopatra mission or expansion scenario to confirm packs resolve.
10. Record logs, exact source/data manifest hashes, screenshots if permitted, and failures.

Exit gate G1:

- clean arm64 Mac build and self-contained app;
- green hermetic suite;
- authentic menu and one early Pharaoh mission render;
- audio works;
- a newly created Akhenaten save reloads after process exit;
- Cleopatra content is detected and at least enters a scenario;
- unresolved engine compatibility bugs are separated from Apple wrapper bugs.

If authentic Mac gameplay cannot pass, pause mobile work and fix/report the upstream engine
or data mismatch. iOS will not repair it.

### Phase 2 — Introduce the portable iOS build seam

Tasks:

1. Add explicit iOS vs macOS platform selection.
2. Add feature options and disable desktop-only components for iOS.
3. Add the minimal iOS platform backend and app target.
4. Build pinned static dependencies for `iphonesimulator` arm64.
5. Bundle Akhenaten engine data/resources.
6. Add a CI/local script that builds from clean source with code signing off.
7. Audit binary architecture, SDK, minimum OS, frameworks, symbols, rpaths, and resources.

Exit gate G2:

- iOS Simulator `.app` builds without signing;
- no macOS-only source/framework/helper is present;
- no Homebrew/workspace/temp runtime dependency is present;
- app bundle contains only engine-owned resources;
- source tree remains clean apart from the wrapper's intentional patch queue.

### Phase 3 — iPhone Simulator boot, importer, and first gameplay

Tasks:

1. Boot a small supported iPhone Simulator and install the app.
2. On first launch with no data, show a stable, native “Game Data Required” flow—not a
   crash, black screen, or desktop ImGui file dialog.
3. Add the native folder importer and synthetic validator tests.
4. Inject a private copy of the user's data into Simulator storage through scripts for
   fast iteration; separately test the real picker flow.
5. Launch the engine, reach menu, start the same G1 mission, and reproduce the G1 save.
6. Tune minimum phone display scale and touch targets without changing tablet defaults.
7. Implement virtual keyboard behavior for player/save names.
8. Add phone UI tests for importer, menu access, save naming, settings/help, and error paths.

Exit gate G3:

- fresh install/no-data behavior passes;
- folder picker and scripted injection both work;
- critical imported hashes match source;
- menu and authentic city render on iPhone Simulator;
- core touch loop can place, inspect, pan, zoom, cancel, pause, save, and load;
- no game controls are unreachable or hidden by safe areas;
- no data is bundled in app/test artifacts.

### Phase 4 — iPhone lifecycle and repeatability

Tasks:

1. Implement background pause/autosave and audio suspend/resume.
2. Add lifecycle tests: background/foreground 20 times, terminate while backgrounded,
   relaunch, and load lifecycle save.
3. Add interrupted-import tests and low-space preflight behavior.
4. Repeat clean build/install/inject/launch twice.
5. Verify existing data and saves survive an in-place app update.

Exit gate G4:

- lifecycle save is created only when appropriate and reloads;
- manual saves are untouched;
- process remains alive or relaunches cleanly as expected;
- import recovery leaves no promoted partial tree;
- two complete runs produce equivalent results.

### Phase 5 — iPad Simulator and CaesarPad-inspired shell

Tasks:

1. Build/install the same target on iPad mini, 11-inch, and 13-inch Simulators.
2. Establish independent iPad display/cursor/touch defaults.
3. Port the small help/Pencil toolbar design using Akhenaten-specific wording.
4. Implement pan-vs-pinch gesture intent and long-press/two-finger right click.
5. Add the Pencil identity/mode plumbing and simulated logic tests; mark real Pencil
   behavior pending hardware.
6. Validate menus, advisors, overlays, build categories, monument placement, minimap,
   mission selection, editor entry if supported, save/load, and keyboard presentation.
7. Add accessibility identifiers and XCUITests for native controls.

Exit gate G5:

- all three iPad sizes render without clipped required controls;
- phone behavior remains green;
- native toolbar changes game state through a narrow tested seam;
- finger navigation cannot place while Pencil mode is on;
- traditional touch remains usable while Pencil mode is off;
- UI, touch, lifecycle, and safety tests pass from clean source.

### Phase 6 — Cross-platform save and compatibility matrix

Create a committed matrix containing no proprietary data. Store only status, hashes,
engine/data versions, durations, and issue links.

Minimum matrix:

- early, middle, and late base Pharaoh missions;
- one sandbox/custom map;
- at least three Cleopatra scenarios covering expansion assets/features;
- monument construction and save/reload mid-build;
- floodplain/farming season;
- trade and empire map;
- land combat and naval/transport behavior;
- music, speech, ambient effects, intro/victory video behavior;
- original Pharaoh save import;
- original Cleopatra save import;
- Mac-created Akhenaten save loaded on iOS and iPadOS;
- iOS-created save loaded by the same pinned desktop Akhenaten build;
- forward/backward expectations explicitly documented.

Do not promise that Akhenaten-generated version-189 `.svx` files load in the original 1999
game. Test and document actual compatibility rather than inferring it from the ability to
load original saves.

Exit gate G6:

- required preview scenarios pass or are listed as known issues;
- save directionality is documented precisely;
- no silent corruption, crash loop, or data loss;
- every red compatibility item has a reproducible upstream issue or a scoped local fix.

### Phase 7 — Physical iPhone acceptance

Tasks:

1. Build a signed development device app without replacing any existing live container.
2. Back up any pre-existing app data and verify actual copied files/hashes.
3. Install in place, launch, verify PID separately, and run a 30-minute session.
4. Test real touch, safe areas, rotation lock, keyboard, audio routes, interruptions,
   background/foreground, termination/relaunch, thermals, memory, and battery behavior.
5. Repeat on the oldest supported iPhone available.

Exit gate G7:

- hands-on gameplay acceptance recorded;
- no sustained frame-time or thermal blocker;
- audio and lifecycle pass on hardware;
- data preservation verified by read-back hashes.

### Phase 8 — Physical iPad and Apple Pencil acceptance

Tasks:

1. Install in place with the same preservation protocol.
2. Run traditional touch and Pencil task scripts.
3. Test Pencil selection, drag placement, cancellation, finger-only navigation in Pencil
   mode, mode persistence, hover if available, and accidental-placement rate.
4. Test external mouse/trackpad, hardware keyboard, and at least one controller as secondary
   inputs.
5. Profile a dense/long-running city with Instruments.
6. Complete at least a 60-minute mission session, save, force-quit, and reload.

Exit gate G8:

- physical Pencil acceptance—not only compilation—is recorded;
- stable frame pacing and memory on target iPad;
- no input deadlocks or accidental destructive actions;
- save/reload and lifecycle pass after the long session.

### Phase 9 — Release engineering

Tasks:

1. Produce a self-contained macOS `.app` archive and unsigned ROM/data-free IPA.
2. Audit architectures, SDK/minimum OS, entitlements, plist, dylibs, rpaths, privacy usage,
   archive contents, source notices, and absence of game data/saves/signing files.
3. Generate SHA-256 checksums and an exact source manifest: wrapper commit, submodule SHA,
   patch list, dependency versions/hashes, build commands.
4. Include AGPL text, appropriate legal notices, warranty statement, full third-party
   notices, prominent source link, modification date, and corresponding-source archive or
   durable source offer appropriate to the distribution method.
5. Document self-signing/sideloading honestly. An unsigned IPA is not an App Store or
   TestFlight release.
6. Download back hosted artifacts if a hosted release is later authorized and re-run the
   same verifier against the downloaded bytes.

Exit gate G9:

- all automated checks and required hardware gates green;
- package contains no proprietary data;
- package is reproducible from published corresponding source;
- compatibility page matches measured results;
- public name, attribution, trademark wording, and distribution license reviewed;
- local `HEAD`, remote branch, and released source/artifact SHAs agree if publication was
  explicitly authorized.

---

## 8. Automated test plan

### 8.1 Required layers

| Layer | Frequency | Purpose |
|---|---|---|
| Patch apply/lint | Every change | Prove clean pinned reconstruction |
| Private-data safety scan | Before commit/package | Block proprietary files and generated artifacts |
| Akhenaten hermetic integral suite | Every engine/patch change | Preserve upstream behavior |
| Resource-backed engine suite | Manual/private per release | Resolve authentic packs and art paths |
| Import validator unit tests | Every change | Root normalization, missing data, case, space, cancellation |
| C++ touch tests | Every input change | Tap, drag, long press, two-finger intent, Pencil filtering |
| XCUITest native shell | Every native UI change | Import/help/Pencil/error/accessibility flows |
| Simulator launch smoke | Every app/build change | Install, launch, PID, expected first screen |
| Lifecycle script | Every lifecycle/save change | Background, terminate, relaunch, save hashes |
| Binary/package audit | Every release candidate | Architecture, linkage, plist, entitlements, exclusions |
| Physical task scripts | Every release candidate | Real touch/audio/performance/Pencil acceptance |

### 8.2 Synthetic fixture policy

Fixtures may reproduce filenames, directory shapes, small invented headers, and sizes only
where legally and technically necessary. They must not contain copied game bytes, strings,
maps, art, audio, video, or reverse-engineered asset content. Resource-backed testing stays
local and private.

### 8.3 Performance gates

Measure, do not infer:

- frame time and effective game speed, not FPS alone;
- memory at menu, normal city, dense city, and after 20 lifecycle loops;
- cold launch after import;
- import throughput and free-space multiplier;
- save and lifecycle-save latency;
- audio underruns;
- thermal state over a 60-minute physical session.

Set numeric release thresholds only after G1/G7 baseline measurement. A reasonable initial
target is smooth 60 Hz presentation where possible, no sustained sub-30 FPS behavior, no
simulation slowdown at normal speed, and lifecycle save comfortably within available
background time. Record device/OS/build with every number.

---

## 9. Risk register

| Risk | Probability | Impact | Mitigation / stop condition |
|---|---:|---:|---|
| Akhenaten gameplay is incomplete | High | High | Preview wording; compatibility matrix; upstream issues; do not disguise logic gaps in Apple UI |
| `APPLE` means macOS throughout source/build | High | High | Explicit iOS identity and compile-source/link audit in Phase 2 |
| Dependency cross-build breaks on iOS | Medium | High | Disable optional desktop stack; build dependencies one at a time; propagate SDK/target |
| MuJS or embedded scripts violate a distribution rule | Low-medium | High | Scripts are bundled source, not downloaded; disable network/update paths; legal review before store submission |
| Save corruption during lifecycle/import/update | Medium | High | Staging/atomic promotion, separate saves, backups, hashes, repeated kill/update tests |
| Touch UX is too dense on phone | High | Medium-high | Phone-first Simulator gate, independent scale defaults, minimum target audit, honest support floor |
| Pencil patch depends on SDL internals | Medium | Medium | Small version-pinned patch, focused tests, upstream discussion, hardware gate |
| Mac app leaks Homebrew dependencies | Observed | Medium-high | Static/self-contained audit; fail package on external paths |
| Deployment target is not propagated | Observed | Medium | Fix all sub-build args; fail on linker warnings |
| Upstream integral suite is red | Observed | High | Repair/explain before Apple diffs; never normalize red baseline |
| Original data layouts vary | Medium | Medium | Use engine validator; Steam/GOG first; collect hashes/manifests privately; precise errors |
| App package accidentally includes data | Low with controls | Critical | Ignore first, scan always, package allowlist, artifact download-back audit |
| AGPL/source-offer noncompliance | Medium | High | Exact source archive/manifest/notices; legal review; no closed downstream engine |
| Trademark/official-product confusion | Medium | High | Original name/art; non-affiliation language; naming review before public release |
| App Store/sideload policy changes | Medium | Medium | Treat GitHub source/unsigned IPA as separate lane; gate other distribution on current legal/policy review |
| Scope expands into completing Akhenaten | High | High | Keep Apple port and upstream engine work separate; accept documented preview limitations |
| Upstream drift breaks patches | High | Medium | Pin releases, clean patch queue, scheduled drift build, intentional submodule bumps |

---

## 10. Licensing, rights, and public wording

Akhenaten's repository declares AGPL-3.0. Before distributing a modified binary:

- keep the downstream wrapper/engine modifications under compatible terms;
- preserve notices and modification dates;
- display appropriate legal notices in an accessible About/Licenses screen;
- provide the exact corresponding source and build/install information required for the
  shipped object code;
- audit every fetched and vendored dependency and included data asset;
- never bundle Pharaoh/Cleopatra game data;
- never imply that buying the Apple wrapper conveys the original game;
- link users to legitimate purchase pages, not downloads of game files;
- get a qualified legal review before App Store, TestFlight, paid, notarized alternative
  marketplace, or large public distribution.

Apple permits a custom EULA, but Apple distribution terms, usage rules, code-signing, and
copyleft obligations must be reviewed together at the time of submission. Do not recycle
an old blanket “AGPL can/cannot be on the App Store” claim as a substitute for current legal
analysis.

Required non-affiliation wording:

> This is an unofficial community project based on the open-source Akhenaten engine. It is
> not affiliated with or endorsed by Activision, Impressions Games, or the Akhenaten,
> Julius, or Augustus projects. Pharaoh and Cleopatra game data is not included. Users must
> provide their own legally obtained compatible files.

---

## 11. Definition of done

The project is complete for a **developer preview** only when:

- G0 through G5 and G9 pass;
- at least the preview subset of G6 passes and all failures are documented;
- macOS, iPhone Simulator, and iPad Simulator validation occur in that order;
- clean builds, install, launch/PID, authentic gameplay, input, audio, save/reload, and
  lifecycle are each evidenced separately;
- ROM/data-free macOS and unsigned IPA artifacts pass download-back-equivalent audits;
- source, patches, dependencies, licenses, and exact build steps are available;
- no original data, saves, signing assets, or private references are tracked or packaged.

The project is complete for a **public 1.0 claim** only when, in addition:

- G7 and G8 physical acceptance pass;
- the agreed base Pharaoh and Cleopatra campaign matrix passes at the published bar;
- long-session performance and save integrity pass on supported hardware;
- remaining incompatibilities are narrow enough for honest release notes;
- naming, trademark, AGPL, dependency, and distribution review is complete;
- the upstream engine's maturity supports the public claim.

If Akhenaten remains incomplete, shipping a clearly labelled developer preview is a valid
outcome. Mislabeling it as a complete Pharaoh + Cleopatra port is not.

---

## 12. Bot operating rules

The implementation bot must:

1. Read this entire document, `AGENTS.md`, `STATE.md`, and the relevant CaesarPad source
   before changing code.
2. Work one red gate at a time and choose the smallest existing seam.
3. Update `STATE.md` after every meaningful experiment with command, result, evidence path,
   next action, and whether the result is fact or inference.
4. Preserve unrelated changes and all user data.
5. Never weaken or delete a test merely to make it green.
6. Retry host-service, CoreSimulator, dependency-network, and authentication failures
   without source changes before diagnosing the product.
7. Never use Simulator success as physical-device acceptance.
8. Never use compilation as gameplay evidence.
9. Keep phone and tablet defaults independent.
10. Stop for user input only when signing authority, physical interaction, proprietary
    files, destructive replacement, publication, or a material product choice is truly
    required.

---

## 13. Final recommendation

Proceed. The fastest honest path is:

1. create the new wrapper repo and safe `ref/` contract;
2. make the pinned Mac baseline clean, self-contained, and authentically playable;
3. split iOS from macOS in Akhenaten's platform/build logic;
4. obtain the first no-data iPhone Simulator launch with optional dependencies disabled;
5. port the importer and lifecycle behavior;
6. adapt CaesarPad's touch/Pencil/menu experience;
7. validate phone, then tablet, then physical hardware;
8. publish only at the compatibility level actually measured.

The Apple port is a bounded, credible project. The uncertain part is upstream game
completeness, not whether SDL/CMake/Akhenaten can be made to run on Apple's mobile
platforms. Keeping those two questions separate is what makes this plan executable.
