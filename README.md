# Emerald Tablet

<p align="center">
  <strong>Pharaoh + Cleopatra on Apple Silicon Mac, iPhone, and iPad, powered by Akhenaten.</strong><br>
  Developer preview · bring-your-own-data · Apple Pencil mode on iPad
</p>

<p align="center">
  <img alt="Apple Silicon macOS developer preview" src="https://img.shields.io/badge/macOS-developer%20preview-0A84FF?logo=apple">
  <img alt="iOS developer preview" src="https://img.shields.io/badge/iOS-developer%20preview-FF3B30?logo=apple">
  <img alt="Powered by Akhenaten" src="https://img.shields.io/badge/engine-Akhenaten-8B5A2B">
  <img alt="Pharaoh data not included" src="https://img.shields.io/badge/game%20data-not%20included-FF453A">
</p>

Emerald Tablet packages the open-source [Akhenaten](https://github.com/dalerank/Akhenaten)
engine as a native Apple product: a self-contained Apple Silicon Mac app and one iOS app
target for iPhone and iPad. It adds native game-data importing through the iOS document
picker, background lifecycle autosave, touch-first controls, a per-device display scale,
and an Apple Pencil mode modeled on CaesarPad's proven design.

This repository contains the Apple integration, the patch queue, and the build scripts. It
does **not** contain Pharaoh, Cleopatra, or any of their game data; you supply your own
legally obtained files locally.

> [!IMPORTANT]
> Emerald Tablet is currently a **developer preview**. The Mac app plays authentic
> Pharaoh + Cleopatra content and the iOS Simulator gates below are proven. On a physical
> iPad, the current signed build has passed hands-on construction, cancellation, Apple
> Pencil movement, native game-speed controls, and save-flow checks. In-place updates also
> preserve saves and preferences byte-for-byte. Physical iPhone, audible-speaker,
> lifecycle, sustained-performance, and broader campaign acceptance remain open, and no
> GitHub Release or App Store listing has been published.

[What works](#what-works-today) · [Screenshots](#screenshots) · [Touch controls](#touch-controls) · [Supported platforms](#supported-platforms) ·
[Get the game data](#game-data-requirements) · [Build and run on macOS](#build-and-run-on-macos) ·
[Run in an iOS Simulator](#run-in-an-ios-simulator) · [How it works](#how-it-works) ·
[Compatibility](docs/COMPATIBILITY.md) · [Project status](STATE.md)

## Supported platforms

| Platform | Status | What to do |
|---|---|---|
| Apple Silicon macOS | **Verified** | Build locally with the automated scripts and point the app at your own Pharaoh + Cleopatra folder. |
| iPhone Simulator | **Core verified** | Install from the local build; the native picker imports data; the same city plays from the Mac save. |
| iPad Simulator | **Core verified** | mini/11"/13" render at native size; city-from-save proven on 11"/13"; Pencil mode option toggles. |
| Physical iPhone / iPad + Apple Pencil | **iPad partial / iPhone open** | Current iPad construction, cancellation, Pencil movement, game-speed controls, and save flow are hands-on accepted. Audible output, lifecycle, long-session performance, and all physical-iPhone checks remain human gates. |
| App Store / TestFlight / public release | **Not announced** | Requires legal review and release engineering first. |

## What works today

- A self-contained arm64 macOS app (system frameworks only, `minos 11.7`) that loads
  authentic Pharaoh + Cleopatra data, reaches the main menu, and plays the Nubt city with
  render, input, audio, and format-189 saves confirmed and user-accepted.
- The current 197-test hermetic suite reports `195 passed, 2 failed`; both
  failures are the documented upstream timing-sensitive kingdom-favour tests.
  The earlier 194-test baseline passed `194/194` on this pin.
- One iOS app target (families 1+2, arm64, iOS 15.0, UIKit/Metal only) that builds clean
  and audits against desktop-only frameworks.
- A native "Game Data Required" flow on iPhone: the engine's config window opens the real
  `UIDocumentPickerViewController`, and a selected game-data folder is copied, merged with
  the engine's own `Data/` (fonts, packs, maps), and promoted atomically.
- The same Mac-created save loads on the phone and iPad (format 189) and monthly autosaves
  are written on-device.
- Backgrounding an iPhone city pauses the sim and writes a dedicated `lifecycle.svx`
  autosave that survives a terminate-while-backgrounded relaunch.
- iPad renders at the native landscape size (1210x834 on 11", 1376x1032 on 13"), and the
  city fills the framebuffer; a per-device display-scale default is applied.
- A persistent native "⋮" control popover on iPad with pause/resume, repeatable speed
  controls and a live percentage, complete build-tool cancellation, game options, touch
  help, persistent crisp scaling, and Done.
- iPad one-contact/Pencil map movement is reduced to one eighth of the original distance
  and inertia. Two-finger pan uses half that movement and shorter inertia, and is consumed
  as navigation before it can place a building.
- iOS stays in native fullscreen sizing, and the optional **Crisp scaling** control switches
  the final texture between smooth and nearest-neighbor sampling without changing resolution.
- Attached hardware keyboards are detected before SDL text input, preventing the software
  keyboard bar from being requested. A focused filename field also translates physical
  printable key events into text without exposing normal gameplay hotkeys.
- Apple Pencil has a distinct SDL touch identity, and the Options menu exposes a
  persistent "Pencil mode: OFF/ON" toggle (fingers pan/zoom but never click while on).
  Tapping the already-selected construction tool again with the Pencil cancels it;
  a deliberate two-finger tap remains available as a fallback. The Pencil's configured
  side double-tap or squeeze performs the same secondary action when iPadOS has not
  set it to Ignore.
- The iOS Mods screen imports a user-supplied `.sgx` through Files instead of opening the
  unavailable network listing. Imports are staged and atomically promoted into the app's
  sandbox; no third-party mods are bundled.
- Developer/debug menus, the FPS counter, and the expanded statistics sidebar start hidden
  on iOS, and the unemployment label uses its readable localized text.
- iOS menu backgrounds aspect-fill the screen, desktop Quit is hidden in favor of the
  normal Home gesture, and family/campaign Back actions use explicit destinations.
- Load/Delete filename fields do not summon the iPad keyboard until tapped, sound
  volume arrows change in useful repeating steps, and the campaign loader retries the
  canonical `Data/` spelling required by iOS's case-sensitive filesystem.
- A Hermetic emerald-tablet AppIcon is compiled into the iPhone/iPad asset catalog.
- Multi-tile construction confirmation correctly places green Granary and Bazaar
  footprints at every camera orientation; the physical iPad recheck also accepted a
  Hunting Lodge, roads, long-press cancellation, and the Save Game flow.

Simulator evidence proves install, PID, render, menu reachability, save reload, in-city
input, and lifecycle. Physical iPad evidence additionally proves signed in-place updates,
current-container data discovery, full-screen rendering, Apple Pencil movement, build-tool
cancellation, representative one- and multi-tile construction, and the Save Game flow.
Audible output from the intended route, lifecycle under physical-device interruption,
performance, thermals, and battery behavior still need hands-on acceptance.

## Screenshots

Approved gameplay and campaign screenshots will be added in a later documentation pass.
No original-game screenshot is included in this source-release preparation.

## Touch controls

| Gesture | Action |
|---|---|
| Tap | Select, place, or press an engine UI control |
| One-finger/Pencil drag | Pan the city map at one eighth of the original iPad speed |
| Two-finger drag | Pan at half that movement with shorter inertia, including while a construction tool is selected |
| Pinch | Zoom at a slightly reduced iPad sensitivity |
| Finger long press / two-finger tap | Inspect or cancel |
| Pencil tap on the active build tool | Cancel the tool and return to navigation |
| Pencil side double tap / squeeze | Perform the secondary action when enabled in iPadOS |
| Native "⋮" overlay | Pause/resume, repeatedly adjust game speed, toggle crisp scaling, open touch help, or Done |
| Options → Pencil mode ON | Pencil selects and places; fingers only pan and pinch |

Traditional touch remains the default. Pencil mode distinguishes Apple Pencil at the UIKit
input boundary, prevents finger taps from changing the city, and keeps one-finger panning
and pinch zoom available.

## Quick start, saves, and mods

For a first city, choose **Play Pharaoh/Cleopatra → Create Family → Begin Family
History → Predynastic → Nubt**. The native **⋮ → Touch help** sheet repeats this route
alongside the current touch and Pencil controls.

Emerald Tablet does not download or bundle saved games. Saves can contain original-game
state and personal progress, and their redistribution rights remain the owner's concern.
A private original-1999 Sais `.sav` can be parsed, rendered, and round-tripped locally
after patches `0010`-`0012`, but physical testing still showed black map gaps, stalled
walkers, and broken routing. It and a much larger Alexandria stress save are therefore
unsupported and should not be used as showcase saves. Your original
`.sav` and Akhenaten format-189 saves live in the app's Files-visible Documents container;
preserve that container during in-place updates.

To add a mod, place a trusted Akhenaten `.sgx` file in Files, open **Mods**, and choose
**Import .sgx**. The imported item appears in the list and can be toggled with a double
tap. Emerald Tablet does not curate, download, or endorse third-party mods, and the mod
author remains responsible for compatibility and rights.

## Game data requirements

Emerald Tablet needs the **1999 Pharaoh + Cleopatra** install (not *Pharaoh: A New Era*).
Buy it from [Steam](https://store.steampowered.com/app/564530/Pharaoh__Cleopatra/) or
[GOG](https://www.gog.com/en/game/pharaoh_cleopatra) and point the app at that folder.

The folder must contain at least:

```text
campaign.txt
Data/            (original game assets; the engine also merges its own Data/ on import)
```

Keep a local copy under ignored `ref/`:

```text
ref/Pharaoh + Cleopatra/   # your own legally obtained original game
ref/Akhenaten/             # optional local engine checkout
ref/caesarpad/             # optional Apple reference checkout
```

Nothing in this repository is a substitute for the original files, and the wrapper never
contains, bundles, or distributes them.

## Build and run on macOS

You need macOS on Apple Silicon, Xcode with its command-line tools, CMake 3.25+, Ninja,
and your own Pharaoh + Cleopatra files. Then:

```sh
git clone --recurse-submodules https://github.com/chrissotraidis/emeraldtablet.git
cd emeraldtablet
scripts/apply-patches.sh
scripts/build-macos.sh
scripts/audit-macos-app.sh build/macos/akhenaten.app
```

Launch the app and point the configuration window at your game folder (or pass
`--data-directory` / the cfg's `data_directory`), then start a family and mission from the
menu. To run the hermetic engine suite:

```sh
scripts/run-macos-hermetic.sh    # expects 194 passed, 0 failed
```

## Run in an iOS Simulator

The iOS target builds with the same pinned engine plus the patch queue:

```sh
scripts/build-ios-sim.sh         # produces build/ios-sim/.../akhenaten.app
scripts/audit-ios-app.sh build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app
```

Then boot exactly one Simulator (shut down any others first), install, and launch:

```sh
xcrun simctl boot "<UDID>"
xcrun simctl install "<UDID>" build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app
xcrun simctl launch "<UDID>" mt.dalerank.akhenaten
```

On the first run the app shows its native game-data flow; use the document picker to import
your game folder, or inject a private copy into the app container's `Documents/GameData`
and re-point `akhenaten.cfg` (see the validation docs for the exact flow). The Simulator's
Home/relaunch cycle exercises the background autosave path.

For a development-signed physical-device build, set
`IOS_PROVISIONING_PROFILE` and `IOS_CODE_SIGN_IDENTITY`, then run
`scripts/build-ios-device.sh`. Install the resulting `iphoneos` app in place
with `xcrun devicectl`; see [the IPA installation guide](docs/INSTALL_IPA.md).

<details>
<summary><strong>Prerequisites and troubleshooting</strong></summary>

<br>

- macOS with full Xcode; Xcode 26.6 and iOS 18.5/26.5 Simulator runtimes are verified.
- Full iOS Simulator rebuilds take 30-45 min; use
  `cmake --build build/ios-sim --config RelWithDebInfo` for source-only changes.
- If a dependency archive download fails, check network access and retry; versions are
  pinned, so a mismatched archive is rejected.
- To reset the engine checkout to the pinned SHA plus the patch queue:
  `git submodule update --init --force engines/akhenaten && scripts/apply-patches.sh`.
- Keep exactly one Simulator booted per session; the hard rule is documented in
  `docs/GOAL_LOOP.md`.

</details>

## How it works

Akhenaten is pinned as a Git submodule at
`38cb947ead3895408ea32f74fda6e37921a42bd3`. The engine is never vendor-copied; all Apple
work lives in a small ordered patch queue in `patches/akhenaten`:

1. `0001` — propagate the macOS deployment target (11.7) to dependency sub-builds.
2. `0002` — build in-tree curl against Secure Transport (no Homebrew linkage).
3. `0003` — iOS build seam: `GAME_PLATFORM_IOS` split, iOS backend, picker, lifecycle,
   landscape-only presentation, and the iOS app target.
4. `0004` — Apple Pencil identity (`is_stylus`, `STYLUS_TOUCH_ID`), `gameui_pencil_mode`,
   and the Options toggle.
5. `0005` — per-device iOS display-scale default so the fixed logical view fills each iPad.
6. `0006` — the native "⋮" control overlay (pause, speed +/−, touch help).
7. `0007` — physical-iPad usability: persistent controls, touch/Pencil gesture repair,
   keyboard focus, audio steps, explicit menu navigation, case-correct map loading,
   full-screen menu art, safe iOS exit behavior, current-container migration, and AppIcon.
8. `0008` — iPad interaction polish: quarter-speed touch panning, construction-safe
   two-finger pan, attached-keyboard suppression of the software keyboard, automatic
   intro completion, fullscreen-only iOS sizing, and persistent crisp scaling.
9. `0009` — slower touch/pinch tuning, Pencil secondary actions, focused hardware-keyboard
   text entry, local `.sgx` import, quick-start help, and cleaner iOS presentation.
10. `0010` — platform-neutral save fix for cities containing all five legal temple
    complexes, with a synthetic save/reload regression suitable for upstream.
11. `0011` — validates stale trader, city, and dock links encountered while cleaning up
    original-game figure records.
12. `0012` — Emerald Tablet-only compatibility for the exact legacy three-record temple
    complex representation, plus an unresolved-animation-image guard.
13. `0013` — keeps the deliberate two-finger cancel gesture available while Pencil mode
    continues to block ordinary finger clicks and construction placement.
14. `0014` — lets a second Pencil tap on the active construction tool toggle it off,
    without changing Pencil placement taps or traditional touch/desktop controls.
15. `0015` — starts iOS directly in the game, adds complete build-tool cancellation and
    in-engine game options to the native controls, and enables crisp scaling by default.
16. `0016` — halves two-finger pan movement and inertia independently of the accepted
    Pencil path, and shows the authoritative game-speed percentage.
17. `0017` — fixes multi-tile touch/Pencil confirmation by applying exactly one active
    camera-orientation transform.

Use `scripts/audit-upstream-patches.sh /path/to/Akhenaten <ref>` to test the full ordered
queue against a disposable clone of another upstream revision. The measured 2026-08-19
audit and rebase policy are in [the upstream-sync guide](docs/UPSTREAM_SYNC.md).

`scripts/check-repo-safety.sh` blocks original game data, generated packages, signing
material, and any engine edits outside the patch queue. Build, audit, and validation
scripts are in `scripts/`; evidence summaries live in `docs/validation/`.

<details>
<summary><strong>What the validation suite proves</strong></summary>

<br>

Each gate has separate evidence — compilation, install, PID, render, gameplay, input,
audio, save/reload, and lifecycle are never substituted for one another:

- [G0 workspace safety](docs/validation/g0-workspace.md) — clean pin, ignored `ref/`.
- [G1 macOS](docs/validation/g1/play-macos.md) — authentic Nubt play, format-189 saves,
  user-confirmed; hermetic suite green.
- [G2 iOS seam](docs/validation/g2-ios-seam.md) — iOS target, audit clean.
- [G3 iPhone Simulator](docs/validation/g3-iphone-simulator.md) — importer, menu, save.
- [G4 iPhone lifecycle](docs/validation/g4-iphone-lifecycle.md) — background autosave.
- [G5 iPad + Pencil](docs/validation/g5-ipad-pencil-shell.md) — screen fill, overlay,
  Pencil option.
- [G8 physical iPad](docs/validation/g8-physical-ipad.md) — signed in-place deployment,
  original hands-on reports, repair status, and remaining human checks.

Raw logs and screenshots stay in ignored `artifacts/private/`; they are never committed.

</details>

## Not shipped yet

- Physical iPhone acceptance and the remaining iPad audible-speaker, lifecycle, and
  sustained-performance pass.
- Interrupted-import behavior under genuine low storage (the preflight is implemented,
  but deliberately filling a host/device volume was not performed).
- Playable original-1999 save compatibility; both measured private samples are
  unsupported, while native Akhenaten format-189 saves remain the supported path.
- A polished first-run importer with progress and recovery UI.
- Hosted release publication and naming/trademark/AGPL legal review.

These are described as future work rather than implied by the source preview.

<details>
<summary><strong>Engineering and reference documents</strong></summary>

<br>

- [Feasibility and implementation plan](docs/AKHENATEN-APPLE-FEASIBILITY-AND-IMPLEMENTATION-PLAN.md)
- [Goal loop and gate queue](docs/GOAL_LOOP.md)
- [Akhenaten upstream-sync guide](docs/UPSTREAM_SYNC.md)
- [Implementation plan index](docs/IMPLEMENTATION_PLAN.md)
- [Install on macOS](docs/INSTALL_MACOS.md)
- [Install the iOS build (unsigned IPA)](docs/INSTALL_IPA.md)
- [Compatibility](docs/COMPATIBILITY.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Validation evidence](docs/validation/g0-workspace.md)
- [Project state](STATE.md)
- [Rights and licensing boundary](RIGHTS_AND_LICENSES.md)
- [Third-party notices](THIRD_PARTY_NOTICES.md)

</details>

## Legal

Emerald Tablet contains no Pharaoh or Cleopatra game data. You must supply your own legally
obtained copy from a source such as [Steam](https://store.steampowered.com/app/564530/Pharaoh__Cleopatra/)
or [GOG](https://www.gog.com/en/game/pharaoh_cleopatra).

This is an unofficial community project based on the open-source Akhenaten engine. It is
not affiliated with or endorsed by Activision, Impressions Games, or the Akhenaten, Julius,
or Augustus projects. "Emerald Tablet" is an unofficial working name; public branding is
subject to a later naming and trademark review.

Engine and project code are available under the
[GNU Affero General Public License v3.0](LICENSE). Akhenaten retains its own copyright and
license notices. See the complete [rights boundary](RIGHTS_AND_LICENSES.md) and
[third-party notices](THIRD_PARTY_NOTICES.md).
