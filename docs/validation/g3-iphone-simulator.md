# G3 — iPhone Simulator

Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 (25F84) arm64.
Device: iPhone 16 (UDID `212F13B4-01EE-453E-8B30-EFD7198D6C42`), iOS 18.5,
landscape. Wrapper `e979df7` plus uncommitted G0-G3 tree. Engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001-0003 applied.

## 1. Build, install, launch (separate from gameplay)

- App: `build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app`
  (arm64, `IOSSIMULATOR`, minos 15.0, sdk 26.5 — see G2).
- Install: `xcrun simctl install ... build/ios-sim/.../akhenaten.app` — OK.
- Launch: `xcrun simctl launch ... mt.dalerank.akhenaten` — PID captured
  (e.g. 84905) and process stays alive (`launchctl list`).

## 2. Game Data Required flow (no data)

With no data directory the app shows the engine's Configuration window
(“Folder with original game data” + folder picker). On iOS the folder
button opens a native `UIDocumentPickerViewController` (folder mode,
security-scoped URL). A boot with an unresolvable data path shows the
engine's native “Pharaoh data required” message box with an OK button.

## 3. UIDocumentPicker importer (real picker)

Driven through the actual picker UI in the Simulator:

1. Folder button → `UIDocumentPickerViewController` (Browse → On My iPhone).
2. Selected a game-data folder (`PharaohFixture` test folder containing
   `campaign.txt` + `Data/`).
3. Import copied the folder into the app Documents staging directory,
   merged the bundle's engine `Data/` (fonts, packs, `default.map`,
   `maps/`), then atomically promoted it to `Documents/GameData`.
4. The game's config persisted `data_directory=.../Documents/GameData`
   in `akhenaten.cfg`.

Verified in the app container:
`Documents/GameData/{campaign.txt, Data/{neucha.ttf, pharaoh_*.sgx, maps/…}}`.

## 4. Authentic data and the same mission as Mac

The user's original data (777 MB) was injected into
`Documents/GameData` (scripted path for local iteration) with the engine
data union. The app then:

- booted with the data and played the intro video (audio session active),
- showed the logo screen and main menu (Continue / Play Pharaoh/Cleopatra
  / Greatest Families / Options / Mods / Editor / Quit),
- Play → Family Registry → Create Family (career dialog with the Egyptian
  name list) → dynasty menu → Begin Family History → campaign chronology
  (Predynastic Period selected) → Nubt briefing (“A village is born”,
  5500 BC) — the full UI path to the mission proven on Mac,
- **Continue loaded the macOS-session save**: the game log records
  `File read successful: .../Save/EmeraldG1/quicksave.svx 0@ --- CONTAINER
  rev 1, VERSION 189, 114 sections (0 missing) ---`, and the Nubt city
  rendered on the phone (Db 3730, Pop 0, minimap, sidebar) — the same city
  state as the Mac session,
- wrote monthly autosaves on the device
  (`Save game: OK Save/EmeraldG1/autosave_month.svx`).

In-city input: a tap on the terrain opened the “Empty land” inspector
popup, confirming the game reacts to touch input.

Screenshots: `artifacts/private/g3-sim/` (gitignored) — boot, menu,
registry, career, chronology, briefing, city, in-city tap.

## 5. Known issues (measured)

- Simulator tap delivery is lossy: short synthetic taps are sometimes
  dropped before `SDL_FINGERDOWN`; the engine's native touch path also
  delays start registration 150 ms, so some UI buttons need a held or
  repeated tap. This is a simulator-automation artifact to revisit in the
  input work; it does not affect the reachability evidence above.
- The on-phone UI is the desktop layout scaled to the screen; the
  phone-specific touch scale, safe areas, and virtual-keyboard behavior
  are next (G3 remainder).

## Next

Finish the phone touch scale / safe-area / virtual-keyboard pass, then G4
lifecycle (background pause, lifecycle autosave, 20 bg/fg cycles,
terminate/relaunch).
