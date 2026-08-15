# Install and run Emerald Tablet on macOS

Emerald Tablet for macOS is a self-contained Apple Silicon app. It contains
no Pharaoh or Cleopatra game data — you supply your own legally obtained
installation folder.

## Requirements

- Apple Silicon Mac (arm64)
- macOS 11.7 or newer
- A legally purchased Pharaoh + Cleopatra install folder (from
  [Steam](https://store.steampowered.com/app/564530/Pharaoh__Cleopatra/) or
  [GOG](https://www.gog.com/en/game/pharaoh_cleopatra))

## Install

1. Open `EmeraldTablet-macOS-<commit>.dmg`.
2. Drag `akhenaten.app` into Applications.
3. Launch it. The first run shows the configuration window; point
   "Folder with original game data" at your Pharaoh + Cleopatra folder (the
   one containing `campaign.txt` and `Data/`).

Alternatively, run from the command line with the data directory:

```sh
/Applications/akhenaten.app/Contents/MacOS/akhenaten \
  --data-directory "/path/to/Pharaoh + Cleopatra"
```

The configuration is stored in `~/Library/Application Support/Akhenaten/`
(`akhenaten.cfg`). Saves are written under the game data directory's
`Save/<player>/` folder.

## First launch notes

- The engine validates the folder for `campaign.txt` and the Pharaoh/Cleopatra
  packs. A folder without them is rejected with a clear message.
- If you only have an installer `.exe`, see the engine's GOG/Inno Setup
  extraction notes; the wrapper itself ships no installer-extraction helper on
  Apple platforms.
- The app is unsigned (developer-preview). On first launch, Control-click the
  app and choose Open if Gatekeeper complains.

## What is verified

See [STATE.md](../STATE.md) and the [validation docs](validation/) for the
measured gates: clean build, self-contained package, authentic play
(G1), and the compatibility matrix (G6).
