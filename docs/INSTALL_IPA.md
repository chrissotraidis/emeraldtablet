# Install the Emerald Tablet iOS build (unsigned IPA)

The unsigned IPA is a **developer-preview, sideloading artifact**. It is not
an App Store or TestFlight release. Installing it requires a Mac with Xcode
and a free Apple ID for a 7-day local signing session (or your development
team for longer sessions).

## What you need

- macOS with Xcode (the IPA targets the iOS Simulator SDK build; a device
  build is produced separately with a development team)
- Your own legally obtained Pharaoh + Cleopatra folder for the in-app import
- The IPA plus a way to install it (see below)

## Install on a Simulator

```sh
xcrun simctl install "<UDID>" path/to/EmeraldTablet-iOS-<commit>.ipa
```

The IPA uses the `Payload/` layout, so you can also unzip it and install the
contained `.app` directly.

## Install on a physical device

The unsigned IPA cannot be installed on a physical iPhone/iPad as-is. Build a
device version with your development team, or use a sideloading tool that
re-signs it with your Apple ID. Physical-device acceptance (G7/G8) is not
claimed — the developer-preview evidence is Simulator-based.

## First launch

On first launch with no data, the app shows the native "Pharaoh data
required" flow and a folder picker. Select your Pharaoh + Cleopatra folder;
the app copies it into its sandbox, merges the engine's own `Data/`, and
promotes it atomically. See the [G3 validation](validation/g3-iphone-simulator.md)
for the measured flow.

## Boundaries

- The IPA contains no game data, saves, or signing material (verified by the
  release audit).
- An unsigned IPA is not a store release and carries no Apple endorsement.
- Physical-device behavior (touch, Pencil, audio routes, lifecycle on
  hardware) remains a human gate.
