# Install Emerald Tablet on iOS or iPadOS

The published unsigned IPA is an arm64 **developer-preview sideloading
artifact** for physical iPhone and iPad. It is not an App Store, TestFlight, or
AltStore PAL release. A sideloading tool must re-sign it with your Apple ID.

## What you need

- [The preview 0.1.0 build 1 IPA](https://github.com/chrissotraidis/emeraldtablet/releases/tag/v0.1.0-preview.1)
- A Mac or Windows PC running AltServer and AltStore Classic, or another
  compatible personal re-signing workflow
- Your own legally obtained Pharaoh + Cleopatra folder for the in-app import
- Optional trusted Akhenaten `.sgx` mods stored in Files
- Developer Mode enabled on the device when iOS requests it

With a free Apple ID, AltStore Classic normally requires the app to be
refreshed every seven days and applies Apple's limit on active sideloaded apps.
Paid Apple Developer accounts have longer signing periods.

## Install the published IPA

1. Install AltServer on a Mac or Windows PC and use it to install **AltStore
   Classic** on the device.
2. Download the Emerald Tablet IPA from the GitHub Release to the device.
3. Open AltStore Classic, choose **My Apps → +**, and select the IPA.
4. Sign in with the Apple ID used by AltServer and wait for installation to
   finish.
5. Enable Developer Mode if iOS asks, then launch Emerald Tablet.

AltStore PAL cannot install this arbitrary unsigned IPA and does not replace
AltServer for this release.

## Build and install directly with Xcode

A local development build can instead be produced with an installed
development profile and matching certificate:

```sh
export IOS_PROVISIONING_PROFILE="$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/<uuid>.mobileprovision"
export IOS_CODE_SIGN_IDENTITY="<certificate SHA-1 from security find-identity -v -p codesigning>"
scripts/build-ios-device.sh
```

The script builds against `iphoneos`, adds only engine-owned data, enables the
app's Documents folder in Files, embeds the supplied profile, signs the complete
bundle, verifies the signature, compiles the Emerald Tablet icon, and audits the
result. It never copies original game data into the app.

Install and launch in place so an existing data container is preserved:

```sh
xcrun devicectl list devices
xcrun devicectl device install app --device "<device ID>" \
  build/ios-device/RelWithDebInfo-iphoneos/akhenaten.app
xcrun devicectl device process launch --device "<device ID>" \
  --terminate-existing com.chrissotraidis.emeraldtablet
```

If the bundle ID is changed with `IOS_BUNDLE_ID`, use the same value when
launching. Before replacing an existing installation, back up and verify its
`Documents` and `Library` directories. Do not uninstall for a routine update.
The current iOS startup also repairs a stale absolute GameData path when an
in-place installation receives a new app-container UUID.

### Device-build troubleshooting

- Use the Team ID contained in the selected provisioning profile. The value in
  parentheses in a certificate's display name may be different and caused
  automatic signing to report a missing account/profile during G8.
- If CoreDevice times out or `codesign` cannot establish trust from a restricted
  shell, repeat the unchanged command from a normal Xcode-enabled terminal
  before changing source or signing settings.
- The device script applies the ordered patch queue. Running the repository
  safety check against the pristine engine pin before applying that queue can
  report the expected patched files as missing.
- An unchanged repeat patch application is fingerprinted under ignored
  `build/`; subsequent builds skip the reverse/reapply cycle unless the engine
  pin, patch bytes, or engine diff changed.
- iPadOS can retain an absolute path containing an obsolete data-container UUID
  after an update. Patch 0007 derives the current `Documents/GameData` location
  when it contains valid game data, so do not "fix" this by uninstalling and
  losing the container.
- CoreDevice's app-file service can time out even when install, launch, and
  process queries work. Keep an inspected backup before updating; retry the
  unchanged read operation with the game stopped and the device unlocked. Do
  not substitute uninstall/reinstall when file readback is unavailable.
- iOS/iPadOS now owns fullscreen sizing. Do not change the engine resolution to
  fit the tablet; use the native display size. **Crisp scaling** in the native
  `⋮` menu changes texture filtering only and is safe to toggle at runtime.
- With a hardware keyboard attached, text input remains active but the software
  keyboard is not requested. Tap a filename field normally when you intend to
  type; printable physical-key events are routed only to the focused field.
  Disconnecting the hardware keyboard restores the on-screen keyboard.

## First launch

On first launch with no data, the app shows the native "Pharaoh data
required" flow and a folder picker. Select your Pharaoh + Cleopatra folder;
the app copies it into its sandbox, merges the engine's own `Data/`, and
promotes it atomically. See the [G3 validation](validation/g3-iphone-simulator.md)
for the measured flow.

If no valid data was imported, the engine may first show its Configuration
screen. Tap the `...` button beside the path to open the native folder picker.
The app's Documents folder is also visible in Files so data can be staged there
before selecting it. The publisher intro should now advance automatically when
its audio buffer drains; a black screen that still requires a tap is a bug to
record. Subsequent diagnostic launches can use `--nointro --no-logo`.

For the shortest playable route, choose **Play Pharaoh/Cleopatra → Create
Family → Begin Family History → Predynastic → Nubt**. The native **⋮ → Touch
help** sheet includes this route and the current touch/Pencil controls.

The iOS Mods screen does not use Akhenaten's network download list. Put a
trusted `.sgx` file in Files, choose **Mods → Import .sgx**, and select it. The
file is validated by extension, copied through a staging name, and promoted
into `Documents/GameData/mods`; canceling the picker changes nothing. Double
tap the imported item to toggle it. No third-party mods are bundled or endorsed.

No starter save is installed. Use your own saves only: they can contain
original-game state and personal progress, and arbitrary downloads are outside
the repository's rights, safety, and compatibility guarantees.

For scripted testing, note that `devicectl device copy to` copies a source
directory's *contents* to the destination. Create and verify the exact target
directory before copying a configuration file, and never use
`--remove-existing-content` against a live app container without an inspected
backup and tested restore.

## Boundaries

- The IPA contains no game data, saves, or signing material (verified by the
  release audit).
- The app contains no third-party mods or prebuilt save collection. Files-based
  `.sgx` import and user-owned save transfer are local developer-preview tools.
- An unsigned IPA is not a store release and carries no Apple endorsement.
- A physical iPad build/install/launch, live-city render, touch and Pencil
  navigation, construction cancellation, representative one- and multi-tile
  placement, Save Game flow, preservation-safe updates, current-container
  migration, and full-screen repaired menu are measured in
  [the G8 deployment log](validation/g8-physical-ipad.md). Audible output on the
  intended route, lifecycle interruption, and extended performance remain
  hands-on gates.
