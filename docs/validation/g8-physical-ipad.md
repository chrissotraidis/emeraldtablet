# G8 — physical iPad deployment

Status: PATCH 0017 PHYSICALLY ACCEPTED; REMAINING HARDWARE GATES OPEN

Measured 2026-08-15 on a connected iPad Pro 12.9-inch (6th generation),
iPadOS 26.6, wired, paired, and in Developer Mode. Wrapper changes were tested
against engine pin `38cb947ead3895408ea32f74fda6e37921a42bd3` with patches
0001-0006 applied. The first 2026-08-16 repair used the same pin plus patch
0007; the interaction-polish follow-up adds patch 0008; the 2026-08-18
input/mods follow-up adds patch 0009.

## Proven on hardware

- `scripts/build-ios-device.sh` configured and built an arm64 `iphoneos`
  application with minimum iOS 15.0. The executable's build metadata reports
  platform `IOS`, and the app audit passed.
- A local Apple Development certificate and matching development profile were
  supplied only through environment variables. The profile, entitlements,
  certificate details, and signed app remain local and ignored.
- The complete bundle passed `codesign --verify --deep --strict`, installed in
  place as `com.chrissotraidis.emeraldtablet`, launched, and was confirmed as a
  live process.
- A QuickTime hardware mirror showed the engine Configuration screen, the
  Impressions Games intro, and then the authentic Pharaoh/Cleopatra main menu.
  Relaunching with `--nointro --no-logo` reached the main menu directly. The
  user then navigated by touch into a live city; the full-screen map, animated
  walkers, sidebar, pause banner, and active build cursor rendered on hardware.
  The launch-reported process was still live after city entry.
- The app's Documents folder is exposed in Files. A small private marker was
  read back byte-for-byte after an in-place reinstall, proving the update did
  not replace the data container.
- For this development run only, the user's locally validated original-data
  folder was staged non-destructively under the app's Documents directory.
  It was not added to the app bundle, repository, or distributable artifacts;
  no proprietary inventory or content hashes are recorded in this repository.
  Engine-owned data was merged separately.

These original facts prove build, signing, install, live-process, data
readability, intro/main-menu/city rendering, and basic touch navigation on this
iPad. They do **not** prove gesture quality, audible audio, Pencil behavior,
extended gameplay, saves, lifecycle, or performance.

## 2026-08-16 repair build evidence

- Patch `0007-ios-hardware-usability.patch` reverse-checks cleanly against the
  currently patched engine. A Simulator build and an arm64 `iphoneos` build
  both succeeded after the patch; the application audit reports minimum iOS
  15.0, only iOS-valid frameworks, indirect pointer support, `Assets.car`, and
  iPhone/iPad AppIcon renditions.
- The physical build was signed with the existing local profile/certificate,
  passed strict signature verification, and installed **in place** as
  `com.chrissotraidis.emeraldtablet`. The app was not uninstalled or reset.
- Before installation, `Documents` and `Library` were copied to ignored private
  evidence. After installation, a known configuration file was read back from
  the iPad and compared byte-for-byte equal with its preinstall backup. No
  private content or hashes are recorded here.
- That update exposed a real installation bug: iPadOS assigned a new app data
  container UUID while `akhenaten.conf` retained an absolute path containing
  the old UUID. The original data remained intact, but startup could not find
  it. The repair now derives the current `Documents/GameData` directory from
  the live iOS container and uses it when `campaign.txt` is present.
- A second signed in-place update with that migration loaded the current
  GameData path, settings, campaign metadata, and audio assets. The live console
  reported FLAC/MP3/OGG/MIDI initialization, requested playback of
  `AUDIO/Music/Setup.mp3` at the configured volume, and reached
  `main_menu_shown`.
- QuickTime was connected to the iPad's **Screen** source with playback volume
  set to 0.55. A near-live frame showed the repaired Emerald Tablet main menu
  aspect-filling the iPad display instead of the small centered presentation.
  Mirroring changes audio routing, so this is not a physical-speaker audio pass.
- A 1024×1024 opaque icon was generated in image-generation mode from the
  direction “an emerald tablet from Hermeticism”: deep emerald stone, restrained
  gold sun/moon and circle/triangle geometry, no text, square AppIcon
  composition. Production source: `assets/ios/AppIcon.png`.

These facts prove the repair compiles, signs, preserves the existing config,
migrates the data path, starts on the physical iPad, asks the mixer to play
music, renders the full-screen menu, and packages the icon. They do not prove
that a human can hear the intended physical route or that every repaired touch
path feels correct.

## 2026-08-16 interaction-polish deployment

Patch `0008-ios-ipad-interaction-polish.patch` addresses the second hardware
report without redesigning the engine:

- iOS touch-map translation and inertia are 25% of the previous values, with
  fractional deltas retained so slow drags remain smooth;
- a recognized two-finger pan is consumed before city actions, and an active
  draggable construction preview is cancelled without deselecting its tool;
- an attached `GCKeyboard` suppresses the software keyboard request while SDL
  text input and physical-key events remain active;
- intro video timing stops trusting the audio clock after its queue drains, so
  playback can reach EOF and advance without an extra tap;
- iOS is fullscreen-only at the renderer boundary, preventing runtime
  resolution changes from exposing system chrome or shrinking the view; and
- the native `⋮` menu has a persistent **Crisp scaling** switch that toggles
  final-texture sampling without changing game resolution.

The clean patch reconstruction and repository safety scan passed. Fresh
Simulator and arm64 `iphoneos` builds both succeeded and passed the iOS app
audit. The physical bundle passed strict signature verification, installed in
place as `com.chrissotraidis.emeraldtablet`, launched, and remained live as PID
4630.

Preservation evidence is qualified for this install. The complete 1.6 GiB
private backup taken earlier the same day is still present under ignored
`artifacts/private/`. A fresh directory copy, directory listing, and direct
configuration-file copy all timed out in CoreDevice's app-file service while
the iPad was unlocked, including after the game was stopped. The update used
only `devicectl device install app`; it did not uninstall, reset, or use
`--remove-existing-content`. Because current pre/post files could not be read,
this iteration does not claim a fresh byte-for-byte preservation proof.

The macOS engine compile completed, but its existing bundle audit rejected a
Homebrew `libssh2` runtime dependency. The hermetic runner also failed to keep
its log/save files isolated and consequently reported missing markers that were
visible in its own console output. That invalid run was stopped and only its
three generated untracked files were removed. The earlier 194/194 result remains
historical evidence; it is not presented as a fresh patch-0008 pass.

## 2026-08-16 hands-on recheck after patch 0008

The user launched the installed build and exercised Continue, city navigation,
the native controls, and File → Save Game. This was an observational pass only;
no follow-up build or installation was requested.

Confirmed improvements:

- **Crisp scaling is physically accepted.** It made a large positive visual
  difference and is the preferred presentation.
- **The keyboard/microphone bar did not recur** during the tested save-game
  flow with the hardware keyboard attached.

Outstanding interaction debt:

- **Panning remains about twice too fast.** Patch 0008 reduced touch movement
  and inertia to 25% of the original rate; the next iteration should evaluate
  approximately 12.5% while retaining fractional accumulation.
- **Hardware-keyboard text entry is broken in engine text fields.** In Save
  Game and other naming fields, ordinary letters such as G and T do not enter
  text. Delete works, and tilde still opens the engine console. This separates
  the defect from the now-suppressed iPad software-keyboard bar and points to
  the engine's key/text routing as the next investigation area; no root cause
  is claimed yet.
- **Two-finger pinch zoom is slightly too fast.** It needs a smaller,
  independent sensitivity reduction than panning.
- **Apple Pencil remains partial.** Proximity/hover gets close to targets and
  some scrolling is possible, but the Pencil-versus-finger navigation model is
  still not distinct or predictable enough for acceptance.

Intro auto-advance, audio, construction-safe two-finger pan, navigation
destinations, save/reload, lifecycle, and sustained performance were not
accepted or rejected in this short pass.

## 2026-08-18 input, Pencil, and mods follow-up

Patch `0009-ios-touch-mods-and-onboarding.patch` is a deliberately scoped
iOS/iPadOS pass based on the hardware recheck and the later Mods/city screenshot:

- reduces touch translation and release inertia from 25% to 12.5% of the
  original rate while retaining the existing fractional accumulation;
- independently reduces pinch distance from its neutral point by 15%;
- makes a 700 ms stationary Pencil/finger hold available to generic engine
  Back/Cancel handling, and maps the Pencil's enabled double-tap/squeeze action
  to the same SDL secondary action at the current cursor;
- preserves the suppressed software keyboard bar while translating printable
  hardware key-down events only when an engine text field is capturing input;
- replaces iOS's unavailable GitHub mod-list action with a Files picker for one
  user-supplied `.sgx`, copied through a staging file and promoted into the
  sandbox before the list refreshes;
- starts iOS with the FPS readout and expanded statistics sidebar off, hides
  Debug/Render menus, and replaces the visible `[68,135]` unemployment token
  with the existing localized label; and
- expands Touch Help with a Nubt quick-start route. No save game or third-party
  mod was added to the repository, app bundle, or device container.

The ordered patch queue reconstructs cleanly and the repository safety scan
passes. Fresh arm64 Simulator and `iphoneos` builds pass their app audits; the
device app passes strict signature verification. It was installed in place as
`com.chrissotraidis.emeraldtablet` without an uninstall or reset. The same
private configuration file was read before and after installation and compared
byte-for-byte identical. Launch succeeded and the process remained live as PID
829. These results prove compilation, signing, install, launch, patch
reproducibility, bundle hygiene, and the sampled configuration preservation
only. Physical pan/zoom feel, Pencil side gestures, attached-keyboard text
entry, Files import, and the cleaner in-city presentation remain hands-on
checks for the user.

## 2026-08-20 patch 0010 device update and showcase-save staging

Before this update, the installed physical build contained patches 0001-0009.
The two locally validated original-game showcase saves require the generic
temple-complex capacity repair in patch 0010, so neither was opened on the old
binary.

The app was stopped and its current Documents and Library directories were
copied to ignored private storage. The inspectable backups are approximately
1.6 GiB and 12 MiB respectively. The existing Save tree contained three
families and seven files. Two new, uniquely named private families were then
added: the documented 6,374-population midpoint Sais city and the documented
large Alexandria city. All four staged files (two family markers and two
legacy saves) matched CoreDevice readback byte-for-byte; no existing family or
save was replaced.

A fresh arm64 `iphoneos` build containing patches 0001-0010 completed on
2026-08-20. The bundle passed strict signature verification and the iOS audit:
minimum iOS 15.0, iOS-valid system linkage, compiled AppIcon resources, and
engine-owned data only. It was installed in place as
`com.chrissotraidis.emeraldtablet` without uninstalling, resetting, or removing
container content. After installation, all five families and eleven save files
remained visible, and the platform configuration matched its pre-install
backup byte-for-byte.

The private `akhenaten.conf` was then changed locally to select the Sais family,
point **Continue** at the staged midpoint save, and enable Akhenaten's existing
`gameopt_unlock_all_campaigns` option. The exact modified file matched device
readback. A launch with the documented no-intro/no-logo arguments reached the
full-screen main menu in the QuickTime iPad mirror.

This proves the new binary, signed in-place update, preservation checks,
private save/config transfer, campaign-unlock configuration, process launch,
and main-menu render. It does not yet prove that either legacy city loads on
the physical device or that its gameplay, audio, Pencil, lifecycle, or
performance is accepted. Those remain hands-on checks, beginning with one tap
on **Continue** for the Sais city. All backup/save evidence remains ignored
under `artifacts/private/g8-showcase-save-20260820/`.

## 2026-08-20 Sais first-tick crash and patch 0011 redeploy

The first physical **Continue** loaded and rendered the staged Sais city, then
Akhenaten's own crash handler caught signal 11. No matching iPadOS crash report
was produced. The engine log was preserved before relaunch and its symbolized
stack ended at `empire_city_handle::remove_trader`, called by
`figure_trade_ship::on_destroy` during `city_figures_t::update`.

The original version-160 figure data left stale current-engine city, trader,
and dock links. Patch `0011-legacy-trader-cleanup.patch` makes destruction
cleanup discard out-of-range links through the existing bounded engine APIs.
Its proprietary-free ship/caravan regression passes, and the exact private
Sais save subsequently loaded and completed 120 figure-update cycles locally
without signal 11. This is a generic Akhenaten save-compatibility patch, not an
iOS-only workaround.

The signed 0001-0011 device app passed the iOS audit and was installed in place.
CoreDevice readbacks proved the Sais save and `akhenaten.conf` byte-identical
before and after installation. A no-intro/no-logo relaunch reached
`main_menu_shown`; PID 3251 was alive at the follow-up process check. The app is
left at the reopened menu for the user's physical **Continue** retest. This
proves build/sign/install/preservation/startup, while city rendering and
ongoing gameplay on the repaired physical binary remain hands-on acceptance.
Ignored evidence is under
`artifacts/private/g8-showcase-crash-20260820/`.

## 2026-08-20 Sais legacy-image freeze and patch 0012 redeploy

The next physical **Continue** reached Sais but displayed large black gaps and
became unresponsive. The exact private save reproduced on macOS. Its original
three-record Seth temple complex retained obsolete map image `15804` because
Akhenaten's current typed altar/oracle post-load path refreshed only the first
record. Animation rendering then dereferenced the unresolved image.

Patch `0012-legacy-temple-complex-remap.patch` is deliberately local to Emerald
Tablet. It recognizes only an exact legacy three-part same-type complex,
refreshes all three map footprints with current images without rewriting the
source save, and safely returns from animation if an image cannot be resolved.
It is not proposed upstream. The synthetic regression passes both hermetically
and with authentic image packs. The untouched Sais save rendered 120 normal
frames and 120 Flat View frames, wrote/reloaded a format-189 save, and rendered
60 more frames without fault.

The private Alexandria stress save independently reaches 58,822 population and
then faults in `city_buildings_t::update_religion_supply_houses`; that unrelated
engine-state issue is out of scope and the save is not supported for showcase
use.

The signed 0001-0012 device build passed strict verification and the iOS audit,
then installed in place without uninstall, reset, or content removal. The Save
tree and Library were backed up first under ignored private storage. CoreDevice
readbacks proved the Sais save and configuration byte-identical before and
after installation. The relaunched app is visible at the full-screen physical
iPad main menu in QuickTime. A physical **Continue** tap and responsiveness
check remain hands-on acceptance; the mirror is view-only.

## Installation issues found

1. The repository had only a Simulator build path. The unsigned release IPA
   cannot run on hardware. `scripts/build-ios-device.sh` now provides a
   repeatable local device build/sign/audit path.
2. The pristine engine pin made `scripts/check-repo-safety.sh` fail until the
   wrapper patch queue was applied. Run `scripts/apply-patches.sh` (the new
   device script does this) before interpreting that check.
3. CoreDevice timed out, and a later signature check could not establish the
   certificate trust chain, from the restricted command context. Repeating the
   unchanged operations with normal host Xcode/keychain access succeeded; these
   were not source, device, or signature defects.
4. The identifier in parentheses in an Apple Development certificate's display
   name was not this profile's Team ID. Automatic signing therefore reported
   a missing account/profile. Reading the Team ID from the selected profile and
   signing the finished app bundle locally worked.
5. The first hardware build did not expose Documents in Files. The iOS plist
   now sets `UIFileSharingEnabled` and
   `LSSupportsOpeningDocumentsInPlace`.
6. First launch can look stalled: the Configuration path initially points at
   the app bundle, its native-picker `...` button is small, and the successful
   publisher intro is long. These are startup UX concerns, not crashes.
7. `devicectl device copy to` copies directory contents rather than the source
   directory node. An imprecise destination can turn an expected directory
   into a file. The test configuration was repaired and verified without
   deleting or resetting the live container.
8. A `devicectl info processes` predicate using `CONTAINS` on an executable URL
   crashed inside the tool. Querying the launch-reported numeric PID worked.
9. `scripts/apply-patches.sh` reversed and reapplied the ordered queue even when
   already current, touching engine sources and making repeat device builds
   unnecessarily large. It now fingerprints the engine pin, patch bytes, and
   complete engine diff under ignored `build/`, and skips an unchanged repeat.
10. An in-place update may change the app data-container UUID while preserving
    an absolute old GameData path in user configuration. Patch 0007 detects a
    valid current `Documents/GameData` and migrates startup without deleting or
    resetting user data.

## Remaining hands-on gate

On the physical iPad, confirm the repaired paths:

- repeated Speed +/− presses while one popover stays open, Pause/Resume, Help,
  and Done;
- File → Load Game stays free of the keyboard/microphone bar until the filename
  field is intentionally tapped;
- Sound Options volume arrows repeat in visible ten-point steps, and music/
  effects are audible from the intended route;
- Return to Family Registry, Return to Main Menu, campaign Back, and Timna map
  selection reach their explicit destinations without a missing-map dialog;
- one-finger selection, two-finger tap, long press, pan, and pinch behavior;
- one-finger pan at the new 12.5% rate and two-finger pan while a road or other draggable construction
  tool is active, with no placement on release;
- physical Apple Pencil identity and Pencil-mode behavior;
- automatic transition from the intro to the start/main-menu flow without a
  black frame that requires tapping;
- attached-keyboard alphanumeric entry in save/name fields, on-screen keyboard
  restoration after disconnect, and no regression of the now-confirmed bar
  suppression;
- Crisp scaling persistence after relaunch and native fullscreen sizing with no
  editable iOS resolution path; visual quality itself is accepted;
- save/reload plus background/foreground recovery;
- sustained play and a dense-city performance/thermal pass.

Until those checks are performed by the user, G8 remains a partial hardware
gate rather than a gameplay or usability pass.

## Original hands-on tech debt report

Physical testing stopped at the user's request after the following notes. These
were recorded without attempting a fix during that first session.

1. **No usable audio or volume adjustment.** The user could not move the
   volume control up or down and heard no audio during the physical run. Root
   cause and audio-route state are unmeasured.
2. **Speed sheet dismisses after every action.** Speed + and Speed − in the
   three-dot menu both reach the game, but selecting either closes the sheet.
   Repeated speed changes require repeatedly reopening the menu.
3. **Pencil is partly successful but controls are unclear.** Apple Pencil moved
   the game cursor reasonably well. The broader control model still felt odd
   and insufficiently explained.
4. **iPad input UI repeatedly fights the game.** The system keyboard/microphone
   bar intermittently popped up, stuttered, and was pushed back down by the app.
   File → Load Game was a reproducible trigger: iPadOS appeared to request text
   input while the game immediately dismissed it. Treat this as a functional
   input/focus bug, not cosmetic behavior.
5. **Quit behavior was not cleanly confirmed.** The user believed Exit/Quit did
   not terminate cleanly. The process was absent after testing stopped, but that
   does not prove the in-game quit path behaved correctly.
6. **Main menu is disproportionately small on iPad.** It is the engine's fixed
   centered menu art rather than the earlier full-screen city defect, but it is
   still an awkward tablet presentation and should be evaluated as UX debt.
7. **No Emerald Tablet app icon.** The installed app shows a generic placeholder.
   The requested future direction is an emerald tablet inspired by Hermeticism.
   This is a design/asset task, not part of the current deployment fix.
8. **Patreon destination noted, not rejected.** The Patreon option links to the
   upstream developer, Dalerank. The user considered this acceptable in the
   current build; retain it unless later branding/release review decides
   otherwise.

The 2026-08-16 follow-up added: some History entries reported “Map file
missing”; two-finger right-click was inconsistent; popup text could fall out of
its panel; Back/Return to Family Registry/Return to Main Menu could land on the
wrong screen or do nothing; and an in-game Quit model remained inappropriate
for iPadOS.

## 2026-08-24 acceptance-control repair

The user reported that normal launch unexpectedly entered Akhenaten's
desktop-oriented Configuration window, that the native three-dot popover could
not reach useful game options, that Crisp scaling was off, and that Road or
Housing could remain selected after placement even when a cancel gesture ended
the pending drag preview.

Patch `0015-ios-acceptance-controls.patch` keeps the data-validation fallback
but no longer treats a missing standalone `akhenaten.cfg` as a reason to show
the prelaunch Configuration window on iOS. The native popover adds a direct
complete construction cancel and routes **Game options** to Akhenaten's
in-engine feature window. It also turns Crisp scaling on once for this preview,
after which the user's toggle persists normally.

Construction cancellation on iOS now clears both stages when necessary: the
pending draggable preview and the selected build tool. This complete operation
is used by the visible cancel button, long press, two-finger tap, and a tap on
the already-active tool. The repeated-tool behavior is no longer dependent on
Pencil mode being enabled.

All 15 ordered patches apply cleanly to the pin. The repository safety check,
iOS Simulator build/audit, signed arm64 device build, strict signature check,
and device bundle audit pass. Before installation, the complete Save folder,
`akhenaten.conf`, campaign state, and app preferences were copied into ignored
private evidence. The build was installed in place without uninstalling or
resetting the app. Post-install readbacks are byte-identical for all seven save
files and all three state files.

The app relaunched as PID 11132. Its fresh engine log reaches campaign and
audio loading, render-window creation, and intro playback; it does not stop in
the Configuration window. This proves source, build, signing, preservation,
launch, and engine-startup behavior. Opening the revised popover and confirming
Road/Housing cancellation with touch and Apple Pencil remain human acceptance
checks.

## 2026-08-24 two-finger pan and speed-indicator follow-up

Physical acceptance confirms that patch 0015's Pencil movement and long-press
construction cancellation behave correctly. The remaining control feedback is
narrower: two-finger panning is too sensitive and carries too much inertia,
while the persistent Speed −/+ controls do not show their current value.

Patch `0016-ios-pan-speed-indicator.patch` identifies two-finger panning as its
own drag source. Its iOS movement multiplier is half the accepted Pencil and
one-contact multiplier, and its inertia decay lasts half as long. No Pencil
movement constant changes. The native popover also reads Akhenaten's
authoritative `gameopt_game_speed` value and displays **Game speed: N%**,
refreshing after each Speed −/+ event.

All 16 ordered patches reconstruct cleanly. The iOS Simulator build/audit and
signed arm64 device build/audit pass. A fresh backup was taken after the user's
acceptance session, then the update was installed in place without uninstalling
or resetting the app. Pre/post readbacks prove all seven save files,
`akhenaten.conf`, campaign state, and app preferences byte-identical. The app
relaunched and remained live as PID 11223. Two-finger feel and the visible speed
label remain hands-on acceptance checks.

## 2026-08-24 multi-tile construction confirmation repair

The next physical recheck accepted the native controls and speed information,
but green Granary and Bazaar previews did not place on the confirming tap. The
same session could place smaller buildings, so this was investigated as a
footprint-dependent confirmation defect rather than a gameplay prerequisite.

Akhenaten's shared `has_confirmed_construction()` helper transforms the stored
first-click tile for the camera orientation before comparing it with the second
click. Its `switch` cases lacked exits, so some orientations applied two or
three transforms in sequence. A one-tile footprint masks the error because its
transform offset is zero; a multi-tile footprint does not. Patch
`0017-multitile-touch-confirmation.patch` adds one `break` after each transform,
matching the Augustus reference's one-orientation behavior. It does not change
gesture timing, Pencil navigation, two-finger panning, cancellation, or building
validity rules.

All 17 ordered patches reconstruct cleanly. The iOS Simulator build/audit and
signed arm64 device build/audit pass, including strict signature verification.
Before installation, all seven saves, `akhenaten.conf`, campaign state, and app
preferences were copied from the device. The signed app was installed in place
without uninstalling or resetting it, and every post-install readback compared
byte-for-byte equal. Emerald Tablet relaunched and remained live as PID 729.
This proves the narrow source repair, build, signing, installation, preservation,
and launch. The user then physically confirmed Hunting Lodge, Road, Granary, and
Bazaar placement, long-press cancellation, and the Save Game flow. Patch 0017's
multi-tile placement defect is accepted. Audible output, lifecycle interruption,
sustained performance, and broader campaign play remain separate hands-on gates.

## Tech-debt resolution ledger

| Report | Repair | Current evidence |
|---|---|---|
| Volume hard to change; no audio heard | Volume arrows now repeat and move by 10; no codec substitution | Build + physical mixer initialization/playback request; audible route still human |
| Speed sheet closes after one press | Persistent popover now shows the authoritative **Game speed: N%** above Speed −/+ | Physically accepted in the patch 0016 recheck |
| Controls/Pencil unclear | Help text updated; complete build-tool cancel added to the popover, two-finger tap, long press, and repeated active-tool selection | Long-press cancellation and Pencil movement physically accepted on patch 0015 |
| Keyboard/microphone bar fights Load Game | File-dialog filename inputs opt out of automatic focus; attached keyboard suppresses the software keyboard request | No recurrence during physical Save Game recheck; Load Game and disconnect path remain open |
| Quit uncertain | Desktop-style Quit is hidden on iOS; leave with the Home gesture and lifecycle path | Live iPad launch; lifecycle acceptance still human |
| Main/family screens too small | Background scale `-1` now aspect-fills main/player/dynasty/new-career views | QuickTime physical main-menu frame passes; other views human |
| Generic icon | Added generated opaque 1024×1024 Hermetic emerald tablet and compiled asset catalog | App audit passes; home-screen aesthetic review human |
| Timna says map missing | Retry lowercase `data/` mission paths as canonical `Data/` on case-sensitive iOS | Code/build evidence; physical Timna selection human |
| Return/Back destinations wrong | Main, player, dynasty, and campaign exits now target explicit windows instead of circular history | Code/build evidence; physical navigation human |
| Two-finger right-click inaccurate | Track completed two-finger tap and long-press intent; do not leak a left click into city actions | Code/build evidence; physical feel human |
| Popup text falls outside panel | Constrain the popup tip label to the dialog body | Code/build evidence; physical screenshot human |
| Trackpad/indirect pointer oddities | Declare `UIApplicationSupportsIndirectInputEvents` | Plist/app audit passes |
| Touch pan is far too fast | Keep accepted Pencil/one-contact movement at 12.5%; use 6.25% movement and half-duration inertia for two-finger pan | Patch 0016 device build deployed; two-finger feel remains hands-on |
| Green multi-tile preview will not place | Stop the confirmation coordinate transform after the active camera orientation | Physically accepted with Granary and Bazaar placement on patch 0017 |
| Two-finger pan can select/build | Consume two-finger pan and cancel only an active draggable preview | Code/build evidence; construction test human |
| Intro ends on black until tapped | Resume wall-clock video completion when the audio queue drains | Code/build evidence; physical intro human |
| Attached keyboard still triggers system keyboard bar | Detect `GCKeyboard` before SDL text input and suppress only the software keyboard request | Bar suppression physically confirmed during Save Game; disconnect path open |
| Hardware keyboard letters do not enter text | Convert printable physical key-down events only while an iOS text field captures input | Simulator compile; physical field entry and keyboard-bar regression pending |
| Pinch zoom is slightly too fast | Reduce iOS pinch distance from neutral by 15% | Simulator compile; physical feel pending |
| Mods GitHub action fails on iOS | Replace it with atomic Files-based import of a user-supplied `.sgx` | Simulator compile; picker/import/toggle pending |
| FPS/debug text and raw `[68,135]` appear in the city UI | Hide developer menus/FPS/expanded sidebar by default and use the localized unemployment label | Simulator compile; physical presentation pending |
| No obvious first city | Add the Nubt route to native Touch Help and README/install docs | Documentation + Simulator compile; physical readability pending |
| Requested starter saves | Keep candidate saves private and ignored; do not broaden legacy migration downstream | Both measured original saves are rejected for play; use a fresh/current Akhenaten city |
| Resolution change exposes system chrome | Make iOS fullscreen-only and leave sizing to the native display | Simulator/device build; physical settings path human |
| Requested global sharpening | Add persistent nearest-neighbor **Crisp scaling** toggle to the native controls | Physically accepted as a major visual improvement; persistence still open |
| Patreon destination | Intentionally unchanged | Accepted by user for now |

G8 therefore remains a partial hardware gate: the reported debt has an
implemented and deployed repair, while the interaction and audible-output rows
above still require the user's hands-on recheck.

## 2026-08-20 final legacy-save verdict and Pencil cancel repair

- Physical testing rejects both private original-game showcase saves. Sais no
  longer hits its first two load/render faults, but still shows large black map
  gaps, stalled or looping walkers, and repeated isolated-sector/stagnation
  warnings. Alexandria reproduces the separate 58,822-population religion-
  supply crash. Neither save is considered playable or suitable for capture.
- The black regions are not fog of war: the accompanying route-access warnings
  and stalled simulation show incoherent legacy map/routing state after load.
  No broader Akhenaten save migration is attempted downstream.
- A fresh Nubt device log instead records normal placement, population growth,
  monthly autosaves, and format-189 writes. It contains no crash signature.
- That fresh session exposed one small Apple-only input defect: Pencil mode's
  navigation-only filter also rejected the documented two-finger secondary
  gesture. Patch `0013-pencil-two-finger-cancel.patch` permits only that
  deliberate cancel gesture; ordinary finger taps remain unable to select or
  place buildings while Pencil mode is enabled.
- All 13 ordered patches apply cleanly to the pin. The iOS Simulator build and
  audit pass, as do the signed arm64 device build, strict signature check, and
  bundle audit. The update was installed in place and relaunched as PID 3346.
  Complete Save-tree and configuration readbacks are byte-identical across the
  install. The live mirror shows the app running; physical two-finger cancel
  behavior is the remaining acceptance step.

## 2026-08-20 Pencil-only construction toggle and showcase removal

The user confirmed that the deliberate two-finger tap now cancels construction,
but fresh-game Pencil play still became trapped in Housing or Road mode. Pencil
hold was not reliable, and tapping another tool merely switched tools.

Patch `0014-pencil-tool-toggle.patch` uses the existing construction selection
seam. On iOS, and only while Pencil mode is active, selecting the already-active
non-empty construction type calls the existing cancel path and returns to map
navigation. It does not reinterpret map placement taps and does not alter
traditional touch or desktop input. The native Touch Help copy now documents
the active-tool re-tap and keeps two-finger tap as the fallback instead of
claiming that Pencil hold is reliable.

All 14 ordered patches apply cleanly to the pinned engine. The signed arm64
device build passed strict signature and bundle audits and installed in place.
The first post-install mirror exposed that the current container retained Save
but lacked the imported Pharaoh data. The data-only payload was restored from
the newest complete ignored backup, explicitly excluding its `Save/` and
`akhenaten.conf`, before the app was handed back for testing.

At the user's direction, only the `Showcase Alexandria` and `Showcase Sais`
families were removed. A complete pre-removal Save backup is retained in ignored
private storage. Device readback proves the three retained families—Amenemhet
III, Amenemhet IV, and Ramses V—byte-identical to the sanitized source tree.
The prior configuration was restored from its exact backup and also read back
byte-identical. The imported-data marker matches the complete backup
byte-for-byte. A direct game relaunch now visibly reaches the full main menu and
remains live as PID 3374.

This proves build, package, completed data recovery, targeted save removal,
preservation readbacks, main-menu render, and process liveness. It does not
claim that the install alone preserved imported data. Whether one Pencil tap on
an already-active Housing or Road button feels correct remains a hands-on
acceptance check.

## 2026-08-16 control-popover polish follow-up

A physical screenshot of the first persistent popover showed that its three
equal-width top buttons forced “Pause / Resume” into an ellipsis and that the
fixed height left a large empty tail. The follow-up layout uses:

- a 340×236-point compact popover instead of 290×292;
- two equal-width Speed − / Speed + buttons;
- a full-width Pause / Resume button;
- a final equal-width Touch help / Done row, with Done visually emphasized;
- 48-point touch targets, horizontal title padding, and guarded font scaling.

The Objective-C++ change compiled in the arm64 device target, the rebuilt app
passed strict signing and the iOS bundle audit, and it was installed in place.
Patch 0008 subsequently expands the compact popover to 340×296 points only to
add the full-width Crisp scaling row; the unclipped Speed and Pause layout is
otherwise retained. Final visual and interaction acceptance still requires
opening the rebuilt popover on the physical iPad.
