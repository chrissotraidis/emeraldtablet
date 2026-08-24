# Emerald Tablet state

Last updated: 2026-08-24

Host: Chris-Macbook-Air-M1.local, macOS 26.5.2 (25F84), Darwin 25.5.0 arm64.
Xcode 26.6 (17F113). CMake 4.4.0. Git 2.36.1. Ninja present. A physical iPad Pro
12.9-inch (6th generation), iPadOS 26.6, is attached and paired. Available Simulators include iPhone 16 / 16e / 17 families
and iPad mini / 11-inch / 13-inch on iOS 18.5 and 26.5. About 57 GiB free.

## Gates

| Gate | Status | Evidence |
|---|---|---|
| G0 — Workspace and source safety | PASS | Clean pin `38cb947ead3895408ea32f74fda6e37921a42bd3`, ordered patches 0001-0017, ignored `ref/`, and repository safety check. `docs/validation/g0-workspace.md` |
| G1 — macOS baseline | PASS | Patched self-contained arm64 app (`minos 11.7`, system frameworks only), historical hermetic baseline `194/194`; latest expanded suite `195/197` with the two documented upstream timing-sensitive kingdom-favour failures. Authentic Pharaoh+Cleopatra Nubt play has render/input/audio/save evidence and user confirmation. `docs/validation/g1/patched-macos.md`, `docs/validation/g1/hermetic-full.md`, `docs/validation/g1/play-macos.md` |
| G2 — iOS build seam | PASS | `GAME_PLATFORM_IOS` split, minimal iOS backend, iOS app target (families 1,2), desktop-only components off. iPhone Simulator SDK build links and audits clean (arm64, iOS 15.0, UIKit/Metal only). `docs/validation/g2-ios-seam.md`, `docs/validation/g2-ios-audit.txt` |
| G3 — iPhone Simulator | CORE PASS | Installed + launched on iPhone 16 (iOS 18.5); native Game Data Required flow; UIDocumentPicker importer end-to-end; authentic data reaches menu, family, chronology, Nubt briefing; macOS save (format 189) loaded via Continue → Nubt city on phone with autosaves; in-city tap works. G3 remainder measured 2026-08-15: touch works full flow, bottom UI clears the home indicator, virtual keyboard wired (SDL text input both layers; no reachable phone text field on Simulator — device verification is G7). `docs/validation/g3-iphone-simulator.md` |
| G4 — iPhone lifecycle | CORE PASS | Background → lifecycle autosave + pause implemented and measured; 30 bg/fg cycles survive with one PID; lifecycle save loads via Continue (VERSION 189, 114 sections); manual saves byte-identical across cycles and in-place update; app relaunches with data intact after reinstall; importer gained a low-space preflight (patch 0003). `docs/validation/g4-iphone-lifecycle.md` |
| G5 — iPad Simulator and Pencil shell | CORE PASS | Proven on all three iPads: mini (Pencil row toggles), 13" (full-screen city-from-save, native "⋮" overlay, Pause/Speed actions), 11" (city-from-save, full-screen render, overlay, Pencil toggle). `docs/validation/g5-ipad-pencil-shell.md` |
| G6 — Compatibility matrix | CORE DONE (developer-preview subset) | 22/22 sampled maps load; cross-device Akhenaten format-189 saves load. Both private original-save samples are unsupported for play: Sais converts but retains broken map/routing state on iPad, while Alexandria crashes in legacy religion-supply state at population 58,822. Complete campaign and broad save compatibility remain unclaimed. `docs/validation/g6-compatibility-matrix.md`, `docs/COMPATIBILITY.md` |
| G7 — Physical iPhone | HUMAN GATE | No iPhone is attached. |
| G8 — Physical iPad and Apple Pencil | PARTIAL / PATCH 0017 PHYSICALLY ACCEPTED | Physical acceptance confirms Pencil movement, long-press construction cancellation, native speed controls, Hunting Lodge/Road/Granary/Bazaar placement, and Save Game flow. The signed app remains installed with saves and preferences preserved byte-for-byte. Audible output, lifecycle interruption, sustained performance, and broader play remain human gates. `docs/validation/g8-physical-ipad.md` |
| G9 — Release engineering | CORE DONE (local developer-preview artifacts) | Self-contained macOS dmg + unsigned data-free IPA built and verified; source manifest with pin/patch hashes/dependency versions/artifact SHA-256; install/compatibility/release docs; release verifier (local == origin/main == GitHub API main); download-back-style data-free scans. Remains: hosted release (not authorized), naming/trademark/legal review (human gate). `docs/RELEASE_CHECKLIST.md`, `docs/COMPATIBILITY.md`, `docs/INSTALL_*` |

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
- Physical G7 remains human-only. G8 deployment, render, live-city entry,
  preservation-safe repair update, current-container data discovery, audio-engine
  startup, full-screen menu, Pencil movement, construction/cancellation, native
  speed controls, representative building placement, and Save Game flow are
  measured on hardware. Audible output, lifecycle interruption, sustained
  performance, and broader play remain human-only.
- Authentic Mac play is user-confirmed working (2026-08-14); G1 is PASS with open sub-items (clean quit, save reload, Cleopatra entry, build+inspect clicks) tracked into the G6 desktop compatibility pass.
- The macOS window honors resize events and re-renders; launch size/position come from the cfg (`window_width=1280`, `window_height=800`) or `--size/--pos` args. OS window repositioning is expected and not a game defect.
- 2026-08-15: the windowed desktop game was stopped and extra Simulator windows
  shut down; only one iPad mini Simulator remains for G5 work.

### 2026-08-24 — public-source release preparation

- Patch 0017's physical acceptance is recorded, public compatibility claims are
  limited to measured behavior, and unapproved original-game screenshots remain
  ignored for a later documentation pass.
- A fresh macOS build exposed Homebrew `libssh2` linkage. Patch 0002 now disables
  curl's unused SSH transport on Apple builds; the rebuilt arm64 app targets
  macOS 11.7 and passes the self-contained system-linkage audit.
- A fresh arm64 iOS Simulator build passes its iOS 15.0 bundle/linkage/AppIcon
  audit. The expanded hermetic suite reports `195 passed, 2 failed`; the two
  failures are the already documented timing-sensitive kingdom-favour tests
  `109` and `126`, while the three downstream synthetic regressions pass.
- Publication remains source-first. No GitHub Release, App Store/TestFlight
  submission, public binary upload, or repository-visibility change is implied.

### 2026-08-24 — patch 0017 multi-tile touch confirmation

- Physical testing showed green Granary and Bazaar previews that would not
  place on the confirming tap, while one-tile construction and cancellation
  behaved correctly.
- Akhenaten's shared confirmation helper applied every later camera-orientation
  transform because its `switch` cases had no exits. The resulting coordinate
  mismatch affects multi-tile footprints but is hidden for one-tile buildings.
  Patch `0017-multitile-touch-confirmation.patch` adds one `break` per transform,
  matching the one-orientation behavior in the Augustus reference without
  changing iOS gesture recognition or accepted controls.
- All 17 patches reconstruct cleanly. Simulator and signed arm64 device builds,
  strict signature verification, and both bundle audits pass. The update was
  installed in place; pre/post readbacks prove all seven save files,
  configuration, campaign state, and preferences byte-identical. The app was
  relaunched and remained live as PID 729.
- The user physically accepted Hunting Lodge, Road, Granary, and Bazaar
  placement, long-press cancellation, and the Save Game flow in this build.
  Audible output, lifecycle interruption, sustained performance, and broader
  campaign play remain separate human gates.

### 2026-08-24 — patch 0016 two-finger pan and speed indicator

- Physical testing accepts long-press construction cancellation and Pencil
  movement from patch 0015. It rejects only the separate two-finger pan as too
  sensitive and too slow to stop, and reports that Speed −/+ lacks visible
  state.
- Patch `0016-ios-pan-speed-indicator.patch` introduces a distinct two-finger
  drag source. On iOS it uses half the accepted one-contact/Pencil movement
  multiplier and half the inertia duration. The accepted Pencil path remains
  unchanged.
- The persistent native controls popover now displays the authoritative engine
  value as **Game speed: N%** and refreshes after Speed −/+ events.
- All 16 patches reconstruct cleanly. Simulator and signed arm64 device builds,
  strict signature verification, and both bundle audits pass. The update was
  installed in place; pre/post readbacks prove all seven save files,
  configuration, campaign state, and preferences byte-identical. The app was
  relaunched and remained live as PID 11223.
- Physical two-finger pan feel and speed-label behavior remain the final
  hands-on checks for this iteration.

### 2026-08-24 — patch 0015 acceptance-control repair

- Physical acceptance found that a missing standalone `akhenaten.cfg` opened
  Akhenaten's desktop-oriented Configuration window on normal iOS launch. The
  iOS path now starts the game directly; the existing data-validation failure
  path remains available when the selected game-data folder is actually bad.
- The native three-dot popover now provides **Cancel build tool** and **Game
  options**. Game options opens Akhenaten's in-engine feature window rather
  than attempting to re-enter the pre-renderer Configuration window.
- iOS construction cancellation now clears both a pending draggable preview
  and its selected tool. The active-tool re-tap works for touch as well as
  Pencil mode, while the visible cancel, two-finger tap, and long-press paths
  use the same complete cancel operation. Crisp scaling is enabled once for
  this developer-preview migration and remains user-toggleable afterward.
- All 15 patches apply cleanly. Repository safety, the Simulator build/audit,
  the signed arm64 device build, strict signature check, and device bundle
  audit pass. The update installed in place. Pre/post readbacks prove all seven
  save files, `akhenaten.conf`, campaign state, and app preferences identical.
  The relaunched process remained live as PID 11132 and its fresh log reached
  window creation and intro playback instead of the Configuration window.
- Physical confirmation of construction cancellation and the revised popover
  remains a human acceptance check before public README/release work.

### 2026-08-20 — patch 0014 Pencil construction-tool toggle

- Fresh-game physical testing confirmed patch 0013's two-finger cancel, but
  Pencil-only play still had no reliable way to leave Housing or Road mode.
- Patch `0014-pencil-tool-toggle.patch` changes only iOS Pencil mode: selecting
  the already-active non-empty construction type calls the existing cancel
  path. Map taps still place the selected tool, and finger/desktop behavior is
  unchanged. Touch Help now describes this behavior instead of promising an
  unreliable Pencil hold.
- All 14 patches apply cleanly to the pin. The signed arm64 device build,
  strict signature check, and bundle audit pass. The first post-install mirror
  exposed that the current container had retained Save but lacked the imported
  Pharaoh data. The missing data-only payload was restored from the newest
  complete ignored backup without copying its Save or configuration.
- At the user's direction, only `Showcase Alexandria` and `Showcase Sais` were
  removed from the device Save tree. A complete pre-removal backup is retained
  in ignored private storage. CoreDevice readback proves the remaining
  Amenemhet III, Amenemhet IV, and Ramses V trees byte-identical; the previous
  configuration was restored from its exact backup and read back byte-identical.
  The imported-data marker also matches its backup byte-for-byte. A direct game
  relaunch now shows the full main menu and remains live as PID 3374.
- Physical confirmation of the new Pencil re-tap behavior remains a human gate.

### 2026-08-20 — final legacy-save verdict and patch 0013 Pencil cancel update

- Physical Sais testing still shows black map gaps, stalled/looping walkers,
  and route failures; a post-update mirror again showed the 6,374-population
  city with a “Fishing Boats Can't Navigate” report. Alexandria independently
  crashes at population 58,822 in legacy religion-supply state. Both private
  original saves are rejected for play and showcase capture.
- The latest fresh Nubt log reached population 5, recorded building placement,
  and wrote two format-189 monthly autosaves without a crash signature. This
  separates the legacy-save failures from the iPad construction-control issue.
- Patch `0013-pencil-two-finger-cancel.patch` removes only the navigation-only
  rejection from the existing two-finger secondary gesture. Ordinary Pencil-
  mode finger clicks remain filtered and cannot select or place construction.
- All 13 patches apply cleanly to the pinned engine; repository safety, the
  iOS Simulator build/audit, and the signed arm64 device build/audit pass.
  The app was installed in place and relaunched as PID 3346. Pre/post readbacks
  show the complete Save tree and `akhenaten.conf` byte-identical. Physical
  two-finger cancel feel remains a user acceptance check.
- Private logs and preservation readbacks remain ignored under
  `artifacts/private/g8-showcase-final-verdict-20260820/`.

### 2026-08-20 — patch 0012 legacy temple-complex render repair and iPad redeploy

- The second physical Sais **Continue** reached the city but showed large black
  gaps and became unresponsive. The same private version-160 save reproduced
  on macOS, ruling out iPad memory pressure as the primary cause.
- The legacy save stores its Seth temple complex as one three-record same-type
  chain. Akhenaten's current typed altar/oracle post-load path refreshed only
  the first record, leaving obsolete map image `15804`; animation rendering
  then dereferenced a missing image.
- Downstream-only patch `0012-legacy-temple-complex-remap.patch` recognizes
  only that exact legacy chain, maps its three footprints to current temple
  images without rewriting the source `.sav`, and returns safely if animation
  is asked to use an unresolved image. No Akhenaten upstream proposal is made.
- The proprietary-free regression passes with and without Pharaoh resources.
  The untouched Sais save rendered 120 normal frames and 120 Flat View frames,
  wrote a format-189 `.svx`, reloaded it, and rendered 60 more frames. The
  original private save remained unchanged.
- The much larger Alexandria stress save reaches 58,822 population, then
  independently faults in `city_buildings_t::update_religion_supply_houses`.
  That unrelated engine-state issue is intentionally out of scope; Alexandria
  is not a supported showcase save.
- A fresh signed arm64 iPhoneOS build with patches 0001-0012 passed strict
  signing and the app audit, then installed in place without uninstall/reset.
  Fresh pre-install Save/Library backups were retained privately. The Sais save
  and configuration remained byte-identical after install, and QuickTime shows
  the relaunched app at the physical iPad main menu. Physical Continue remains
  the final hands-on responsiveness check.
- Private backup/readback evidence remains ignored under
  `artifacts/private/g8-legacy-temple-fix-20260820/`.

### 2026-08-20 — patch 0011 legacy-trader crash repair and iPad redeploy

- The first physical **Continue** into the private 6,374-population Sais save
  rendered the city, then Akhenaten caught signal 11. There was no iPadOS
  `.ips`; the preserved engine log identified
  `empire_city_handle::remove_trader` from
  `figure_trade_ship::on_destroy` on the first simulation tick.
- The original version-160 figure record contained stale current-engine link
  bytes. Destruction cleanup dereferenced an out-of-range empire-city handle,
  directly indexed the trader table, and trusted the saved dock ID.
- Patch `0011-legacy-trader-cleanup.patch` resolves the city through the bounded
  empire lookup, releases traders through the manager's safe lookup, and
  validates the dock ID before dereference. The same city cleanup also covers
  legacy caravans. A proprietary-free synthetic ship/caravan regression passes
  (`1 passed, 0 failed`).
- The exact private Sais save then loaded and survived 120 direct figure-update
  cycles locally without signal 11. Two pre-existing building-parameter
  diagnostics remain nonfatal and are not treated as part of this crash fix.
- A fresh signed arm64 iPhoneOS build with patches 0001-0011 passed the app
  audit and installed in place. The Sais save SHA-256 remained
  `a9d1fe49f6a41e6bf5d9586edbdf5a4ca9fa4937a2d373b33ea3dfd2d6c11a96`
  and configuration SHA-256 remained
  `7ac72d039a3873681d10f5fd7fd7462c0fef43ecf61c51c51856ba2da865c97e`
  across installation. The relaunched app was alive as PID 3251 and its fresh
  log reached `main_menu_shown` with no crash. Physical Continue remains the
  final confirmation that the repaired binary renders and plays this city on
  the iPad.
- Private crash log and preservation readbacks remain ignored under
  `artifacts/private/g8-showcase-crash-20260820/`.

### 2026-08-20 — patch 0010 physical-iPad update and private showcase setup

- Before changing the iPad, the app was stopped and its current state was
  copied to ignored private storage. The complete Documents backup is about
  1.6 GiB and the Library backup about 12 MiB; both are inspectable. The
  existing Save tree contained three families and seven files.
- Two additive private families were staged without replacing existing data:
  a 6,374-population midpoint Sais save and a large Alexandria save. Both
  transferred files plus their family markers matched CoreDevice readback
  byte-for-byte. They remain ignored/private and are not repository fixtures
  or distributable content.
- The previous physical build contained patches 0001-0009, so neither legacy
  save was opened until the temple-complex repair in patch 0010 was included.
  A fresh arm64 `iphoneos` build dated 2026-08-20 passed strict signing and the
  iOS app audit (`minos 15.0`, iOS-valid frameworks, engine-owned data only).
- The patch-0010 app installed in place as
  `com.chrissotraidis.emeraldtablet`; there was no uninstall, reset, or content
  removal. All five save families and all eleven files remained visible after
  installation, and the platform configuration matched its pre-install
  backup byte-for-byte.
- The private game settings now point **Continue** at the Sais showcase and
  enable Akhenaten's built-in `gameopt_unlock_all_campaigns` option. The
  modified settings matched device readback, and a no-intro/no-logo launch
  reached the full-screen physical-iPad main menu in QuickTime. This proves
  build/sign/install/preservation/settings/main-menu state; the user still
  needs to tap Continue and confirm the city load and interaction quality.
- Evidence remains under ignored
  `artifacts/private/g8-showcase-save-20260820/`; no proprietary save, game
  data, signing material, or QuickTime capture was added to the repository.

### 2026-08-19 — upstream and original-save compatibility pass

- A private midpoint Sais save and a very large Alexandria save both previously
  aborted in `building_temple_complex::on_post_load` because the decorative-tile
  pool allowed only two complexes. Pharaoh permits one unique complex for each
  of five gods.
- Patch `0010-temple-complex-save-capacity.patch` raises only that fixed pool to
  five and adds a synthetic test that creates all five, saves, and reloads. The
  focused test passes; both private original version-160 saves then load. The
  saves are retained only under ignored `artifacts/private/demo-saves` and are
  not committed, packaged, or used as public fixtures.
- Upstream tip `6211d4681369ecfb7aae004ab71ecb21df6dd787` was audited in a
  disposable checkout. Ordered patches `0001`-`0003` apply before `0004`
  conflicts in two migrated top-menu files. A deeper hunk probe found bounded
  later conflicts in `0007` and `0009`; upstream already makes one local
  campaign-exit hunk obsolete.
- `scripts/audit-upstream-patches.sh` now repeats that audit without changing
  the supplied Akhenaten checkout or pinned submodule. Rebase policy and known
  upstream issue ownership are recorded in `docs/UPSTREAM_SYNC.md`.
- Validation: repository safety passes; focused synthetic test `182` reports
  `1 passed, 0 failed`; both private save probes pass; and the arm64 iOS
  Simulator build succeeds and audits clean at an iOS 15.0 minimum. No
  Simulator UI or physical-device state was controlled during this pass.

### 2026-08-18 — G8 input, Pencil, mods, and onboarding follow-up

- Input: patch `0009-ios-touch-mods-and-onboarding.patch` halves patch 0008's
  physical touch translation/inertia to 12.5% of the original rate and reduces
  pinch distance from neutral by 15%. A 700 ms stationary hold is available to
  generic Back/Cancel handling, while an enabled Apple Pencil double tap or
  squeeze pushes the same SDL secondary action at the current cursor.
- Keyboard: the confirmed bar suppression remains. Because SDL2 did not emit
  `SDL_TEXTINPUT` with its iOS software-keyboard responder disabled, printable
  attached-keyboard key-down events are converted only while an engine text
  field is actively capturing input. This does not change normal game hotkeys.
- Mods/saves: the nonfunctional iOS GitHub-list action is now **Import .sgx**.
  A selected Files item is extension-validated, copied through a staging name,
  and promoted under the live `Documents/GameData/mods` directory before the
  list refreshes. No online save, third-party mod, or private game state is
  bundled; the README/install guide explains the rights, safety, compatibility,
  and preservation boundary.
- Presentation/onboarding: iOS starts with FPS and the expanded statistics
  sidebar hidden, omits Debug/Render menus, localizes the raw unemployment
  token, and includes the Nubt first-city route in native Touch Help.
- Validation: `scripts/apply-patches.sh` reconstructed patches 0001-0009
  from the pinned engine, `scripts/check-repo-safety.sh` passed, the arm64 iOS
  Simulator and device builds succeeded, both app audits passed, and the device
  app passed strict signature verification. The device app was installed in
  place without uninstall/reset; a sampled private configuration file was
  byte-identical before and after; launch succeeded and PID 829 remained live.
  These are code/build/package/install/process/preservation results, not
  physical gesture, Pencil, keyboard, mod, audio, save, lifecycle, or
  performance acceptance.
- Next: hand the interaction checklist back to the user for the installed build.

### 2026-08-16 — G8 interaction-polish follow-up

- Patch: `0008-ios-ipad-interaction-polish.patch` is a 129-line addition/
  26-line removal patch against the pinned engine plus 0001-0007. It reduces
  iOS touch translation and inertia to 25%, retains fractional deltas, consumes
  two-finger pan before construction actions, and cancels an active draggable
  preview without dropping the selected tool.
- Display/startup: iOS is now fullscreen-only at the engine boundary, so a
  mistaken resolution change cannot expose the status bar or shrink the view.
  A persistent native **Crisp scaling** toggle selects nearest-neighbor or
  smooth final-texture sampling without changing resolution. Intro playback
  falls back to wall-clock completion after the audio queue drains instead of
  remaining on a black frame waiting for a tap.
- Keyboard: GameController's attached `GCKeyboard` state controls SDL's screen-
  keyboard hint immediately before text input. A connected hardware keyboard
  keeps normal text events while suppressing the iPad software keyboard bar.
- Validation: `scripts/check-repo-safety.sh` passed. Fresh Simulator and arm64
  `iphoneos` builds succeeded; both app audits passed, and the device app passed
  strict signature verification. The signed app was installed in place as
  `com.chrissotraidis.emeraldtablet`, launched, and confirmed live as PID 4630.
- Preservation caveat: the earlier same-day 1.6 GiB ignored private backup is
  still present. Three fresh CoreDevice app-file attempts (directory copy,
  listing, and direct configuration-file copy) timed out while the iPad was
  unlocked, including with the game stopped. Installation used only
  `devicectl device install app`; no uninstall, reset, or
  `--remove-existing-content` occurred. Because current pre/post bytes could not
  be read, this iteration does not claim a new hash-based preservation proof.
- macOS regression caveat: the engine compiled, but the existing app audit
  rejected a Homebrew `libssh2` runtime link. The hermetic runner then wrote to
  the checkout/user log instead of its intended isolation and produced false
  marker failures, so that invalid run was stopped and its three generated
  untracked files were removed. The earlier recorded 194/194 baseline remains
  historical evidence, not a fresh result for patch 0008.
- Remaining: human confirmation of intro auto-advance, one- and two-finger feel,
  construction safety, Pencil behavior, hardware/software keyboard switching,
  crisp versus smooth appearance, audio, navigation, save/lifecycle, and
  sustained performance.
- Partial hands-on recheck: Crisp scaling made a large positive difference and
  is the preferred presentation. The previous keyboard/microphone-bar fight did
  not recur in File → Save Game. The 25% pan rate still felt approximately 2×
  too fast, so the next scoped iteration should evaluate roughly 12.5% of the
  original movement/inertia. Two-finger pinch zoom was only slightly too fast
  and should receive a smaller independent reduction.
- New hardware-keyboard defect: focused save/name fields accept Delete but not
  ordinary letter keys such as G or T; the tilde key still opens the engine
  console. This is recorded as an engine input-routing/text-entry defect, not a
  recurrence of the iPad software-keyboard bar. Apple Pencil proximity/hover
  and partial scrolling were useful, but the control distinction still was not
  clear enough for acceptance.
- Per the user's request, this recheck updated documentation only. No source,
  build, signing, install, or device state was changed in response.

### 2026-08-16 — G8 physical-iPad tech-debt repair build

- Input: the user's 2026-08-15/16 hardware notes and screenshots were retained as
  symptoms. The local ignored CaesarPad checkout was used only as a behavioral
  reference; no CaesarPad/Augustus patch was applied blindly.
- Patch: `0007-ios-hardware-usability.patch` adds a persistent UIKit control
  popover, repeating speed/volume actions, delayed text-field autofocus, bounded
  popup text, improved two-finger/long-press recognition, Pencil navigation-only
  fingers, deterministic main/family/campaign navigation, aspect-fill menu art,
  hidden desktop Quit on iOS, case-correct `Data/` map fallback, indirect pointer
  support, current-container data migration, and the Emerald Tablet AppIcon.
- Map diagnosis: the screenshot's `data/maps/m_005 timna.map` was not proof that
  Timna data was absent. The original folder is `Data/`; iOS treats that case
  mismatch as distinct. The loader now retries the canonical spelling before
  reporting a genuinely missing map.
- Build: clean Simulator compile initially exposed a missing keyboard include;
  it was corrected. Simulator and arm64 `iphoneos` builds then succeeded and the
  app audit found iOS 15.0, iOS-only frameworks, compiled AppIcon renditions, and
  indirect-input support. The signed device bundle passed strict verification.
- Install: the repair was installed in place as
  `com.chrissotraidis.emeraldtablet`; no uninstall/reset occurred. A known config
  file read back byte-for-byte equal to its preinstall backup.
- Migration issue found during the update: iPadOS assigned a new data-container
  UUID while `akhenaten.conf` retained the previous absolute path. Data was not
  lost, but the first repair launch could not find it. iOS startup now derives
  the current container's `Documents/GameData` and uses it when valid.
- Hardware result: the corrected build loaded the current GameData, campaign
  metadata, and audio codecs, requested `Setup.mp3` at the configured volume,
  and reached `main_menu_shown`. A near-live QuickTime frame showed the repaired
  main menu filling the iPad display. QuickTime volume was set nonzero, but
  mirroring changes the route and does not establish physical-speaker audibility.
- Remaining human recheck: rapid speed presses, actual volume-arrow feel and
  audible output, File → Load Game keyboard behavior, family/main/campaign Back,
  Timna selection, two-finger/long-press accuracy, Apple Pencil behavior,
  save/lifecycle, and sustained play. Code/build/launch evidence is not counted
  as hands-on acceptance.
- App icon: generated in image-generation mode as a square, opaque 1024×1024
  emerald-stone tablet with restrained gold Hermetic geometry, then integrated
  into the iOS asset catalog. Source: `assets/ios/AppIcon.png`.
- Popover follow-up: a physical screenshot exposed clipped Pause / Resume text
  and unused vertical space in the first persistent layout. The rebuilt layout
  separates Speed −/+ into two columns, gives Pause / Resume a full-width row,
  pairs Touch help with an emphasized Done action, uses 48-point targets, and
  reduces the popover from 290×292 to 340×236 points. The arm64 build, signing,
  audit, and in-place install passed; physical open-state inspection remains.
- Evidence: `docs/validation/g8-physical-ipad.md`.

### 2026-08-15 — physical iPad deployment and main-menu render

- Device: iPad Pro 12.9-inch (6th generation), iPadOS 26.6, wired, paired,
  Developer Mode enabled.
- Build: arm64 `iphoneos`, minimum iOS 15.0; local development profile and
  certificate; strict signature verification and app audit passed.
- Install: `com.chrissotraidis.emeraldtablet` installed in place and launched;
  the launch-reported PID was verified live. A staged private marker survived
  the in-place reinstall byte-for-byte.
- Runtime: QuickTime hardware mirror showed the Configuration screen, the
  Impressions Games intro, the authentic Pharaoh/Cleopatra main menu, and a
  live city reached by the user's touch navigation. The full-screen city map,
  animated walkers, sidebar, pause banner, and build cursor rendered; the
  launch-reported process remained live.
- Data: locally validated original data was staged non-destructively in the
  app container for this test only. It remains ignored/local and was not put in
  the app bundle, repository, or distributable artifacts; no proprietary
  inventory or content hashes are recorded here.
- Evidence: `docs/validation/g8-physical-ipad.md`.
- Proves: device build/sign/install/PID/data-readability/intro/menu/live-city
  render and basic touch navigation. Does not prove gesture quality, audio,
  Pencil, save/lifecycle, or sustained performance; those remain hands-on
  acceptance.
- User-reported tech debt captured in this run (subsequently addressed by the
  2026-08-16 repair build): no audible audio or usable
  volume adjustment; three-dot speed action dismisses its sheet; Pencil cursor
  movement is decent but controls are unclear; the iPad keyboard/microphone bar
  repeatedly appears and fights dismissal, especially in File → Load Game;
  in-game quit was not cleanly confirmed; the fixed-size main menu is awkward;
  and the app has a generic placeholder icon. Desired future icon direction:
  an emerald tablet inspired by Hermeticism. The upstream Dalerank Patreon link
  was noted and accepted for now.
- Physical testing stopped at the user's request after capturing these notes.

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

### 2026-08-15 — G6 developer-preview matrix measured

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Method: temporary JS integral-test probes (removed after the run) loaded
  each target map / save through the real Pharaoh + Cleopatra data dir on the
  pinned macOS app; logs in `artifacts/private/g6/` (gitignored).
- Result:
  1. Map matrix: 22/22 load (m_000..m_052 Pharaoh early/mid/late + Cleopatra,
     Maps/ custom scenarios Alexandria/Bridges/Chariot Blitz/Cataract/Enkomi/
     Henen-nesw, data/default.map sandbox).
  2. Behavioral coverage: floodplain/farming, monument build + mid-build
     save/reload, trade/empire, land combat, naval, audio init, intro video,
     original-format save load (VERSION 189) on macOS/iOS/iPad — all covered
     by passing engine tests plus G1/G3/G5 evidence.
  3. Save directionality: macOS → iOS proven in G3/G5; iOS → macOS measured
     (iPhone lifecycle.svx loads on macOS, VERSION 189, 114 sections).
  4. Three engine tests fail on this host (109/126/137 — kingdom favour /
     monument carry). Clean-engine bisection showed 137 fails on the
     unpatched pin and 109/126 are timing-flaky (`pump_frames often yields 0
     sim ticks` per the test's own comment); every Apple patch diff is
     iOS-guarded with identical data/cfg/binary layout. Not Apple regressions.
- Evidence: `docs/validation/g6-compatibility-matrix.md`,
  `artifacts/private/g6/matrix-probe.log` (+ save proof files).
- Proves: mission reachability across the matrix, save directionality both
  ways, honest upstream flake documentation.
- Next: re-run hermetic suite to record flake range; G9 release engineering.
- Fact vs inference: map loads, save loads, and flake patterns measured;
  "upstream" attribution is from clean-engine reproduction.

### 2026-08-15 — G9 release artifacts and docs

- Host/OS: Chris-Macbook-Air-M1.local / macOS 26.5.2
- Artifacts (ignored `build/release/`, wrapper `45765dd`):
  - `EmeraldTablet-macOS-45765dd.dmg` (16.3 MB) — self-contained arm64 app,
    audited (minos 11.7, system frameworks only), mounted and scanned
    data-free.
  - `EmeraldTablet-iOS-45765dd.ipa` (11.2 MB) — unsigned, `Payload/` layout,
    audited, unzipped and scanned data-free (no campaign.txt/saves/packs/
    signing material).
  - `SOURCE-MANIFEST.txt` — wrapper commit, engine pin
    `38cb947ead3895408ea32f74fda6e37921a42bd3`, patch queue with per-patch
    SHA-256, pinned dependency versions (SDL2 2.32.10, SDL2_mixer 2.8.0,
    zlib v1.3.1, libpng v1.6.50, FreeType VER-2-13-3, HarfBuzz 7.3.0,
    stb 5736b15, ImGui v1.92.2), artifact SHA-256.
- New scripts: `package-macos-dmg.sh`, `package-ios-ipa.sh`,
  `generate-source-manifest.sh`, `verify-release-candidate.sh`.
- New docs: `INSTALL_MACOS.md`, `INSTALL_IPA.md`, `COMPATIBILITY.md`,
  `RELEASE_CHECKLIST.md`; `THIRD_PARTY_NOTICES.md` completed; README links.
- Verified: `scripts/verify-release-candidate.sh` passes (triple SHA match,
  release dir data-free); both artifacts scanned after "download-back".
- Open: naming/trademark review, AGPL/legal review before any hosted or store
  distribution (not authorized yet), physical G7/G8.
- Fact vs inference: builds, audits, mounts, scans, and SHA matches measured.

### 2026-08-15 — developer-preview DoD audit (final)

Requirement-by-requirement against the goal's developer-preview DoD:

| DoD item | Status | Evidence |
|---|---|---|
| G0-G5 pass | PASS/CORE PASS | `docs/validation/g0-workspace.md`, `g1/*`, `g2-ios-seam.md`, `g3-iphone-simulator.md`, `g4-iphone-lifecycle.md`, `g5-ipad-pencil-shell.md` |
| G6 subset measured + documented | CORE DONE | `docs/validation/g6-compatibility-matrix.md` |
| G9 local data-free artifacts | CORE DONE | `build/release/*.dmg`, `*.ipa`, `SOURCE-MANIFEST.txt`, `docs/RELEASE_CHECKLIST.md` |
| Order macOS → iPhone Sim → iPad Sim | Met | G1 → G3 → G5 |
| Evidence classes separate | Met | build (G1/G2), package (G9), install/PID (G3/G4/G5), gameplay (G1/G3/G5/G6), input (G1/G3/G5), audio (G1/G3), save/reload (G1/G3/G4/G5/G6), lifecycle (G4) |
| Data-free + reproducible artifacts | Met | data-free scans of dmg/ipa; patch queue clean-applies from pin |
| Compatibility wording = measured | Met | `docs/COMPATIBILITY.md` (22 maps, flakes, unmeasured items explicit) |
| Physical G7/G8 | G7 HUMAN; G8 SECOND REPAIR DEPLOYED / PARTIAL HANDS-ON RECHECK | G8 deployment evidence plus physical acceptance of Crisp scaling and keyboard-bar suppression; pan/zoom sensitivity, hardware-keyboard letters, Pencil distinction, audio, save/lifecycle, and performance remain open |

Remaining (all human/external gates, not automated work):
- Physical iPhone acceptance (G7) and repaired-iPad gesture quality/audible
  output/Pencil/save/lifecycle/performance acceptance (G8).
- Interrupted-import runtime simulation on low storage (destructive host-disk
  test; preflight implemented and build-verified).
- Broad original 1999-game save compatibility beyond the two private samples
  measured on 2026-08-19.
- Hosted release publication, naming/trademark/AGPL legal review (require
  user authorization and a qualified reviewer).

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
