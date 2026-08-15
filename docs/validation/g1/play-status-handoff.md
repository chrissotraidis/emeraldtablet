# G1 authentic Mac play — completed, handoff to G2

Latest: 2026-08-14. Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 arm64.
Wrapper `e979df7` + uncommitted G0/G1 tree. Engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` with patches 0001 and 0002
applied in the submodule worktree.

## Goal (do not shrink)

Continue the active developer-preview goal: native Apple product from pinned
Akhenaten for user-supplied Pharaoh + Cleopatra data on macOS, iPhone, iPad
(+ Pencil). Complete G0-G5 and G9 plus the agreed G6 developer-preview subset.
Stop only at developer-preview DoD or a genuine human-only gate (G7/G8).

## Gate table (source of truth)

| Gate | Status |
|---|---|
| G0 workspace/source safety | PASS |
| G1 macOS baseline | PASS — build+package+hermetic+authentic play (user-confirmed 2026-08-14) |
| G2 iOS build seam | PASS — platform split, iOS app target, mobile-off options, static iOS deps, audit OK (`docs/validation/g2-ios-seam.md`) |
| G3 iPhone Simulator | IN PROGRESS — install/launch/PID, data-required flow, UIDocumentPicker importer, authentic menu → Nubt briefing, macOS save loaded on phone (format 189, city live with autosaves), in-city tap works. Remainder: phone touch scale/safe areas/keyboard, drag-pan/pinch/cancel/pause proofs. `docs/validation/g3-iphone-simulator.md` |
| G4 iPhone lifecycle | NOT STARTED |
| G5 iPad Simulator + Pencil shell | NOT STARTED |
| G6 compatibility subset | NOT STARTED |
| G7 physical iPhone | HUMAN GATE (no device) |
| G8 physical iPad + Pencil | HUMAN GATE (no device) |
| G9 release engineering | NOT STARTED |

## G1 record (do not redo)

- `docs/validation/g1/play-macos.md` — authentic Nubt play record, data
  union, measured evidence table, stuck-dialog incident, open items.
- `docs/validation/g1/patched-macos.md` — self-contained arm64 app
  (minos 11.7, system frameworks only).
- `docs/validation/g1/hermetic-full.md` — 194 passed, 0 failed.
- Overlay `artifacts/private/g1-play/` holds the private union + saves
  (`Save/EmeraldG1/quicksave.svx`, `autosave_month.svx`, format 189).

Open G1 sub-items (folded into G6 desktop pass): clean process exit,
save reload via Continue/Resume, Cleopatra scenario entry, dedicated
build+inspect click evidence.

## Next action — finish G3, then G4 lifecycle

### G3 remainder (current session's evidence in `docs/validation/g3-iphone-simulator.md`)

- Phone touch scale / safe-area layout / virtual-keyboard behavior for the
  game UI (the engine's native touch path exists; the desktop layout is
  scaled to the phone).
- Prove drag-pan, pinch, cancel/right-click (two-finger), and pause in the
  city. Simulator tap delivery is lossy: short synthetic taps are dropped,
  and the engine delays touch-start registration 150 ms — use held/repeated
  taps, and consider an input-hardening patch (e.g. reduce the delay or
  accept fast taps) for the phone pass.
- The running app (iPhone 16 sim, UDID 212F13B4-…) has the full authentic
  data in `Documents/GameData` and the macOS quicksave loaded — Continue
  drops straight into the Nubt city for input testing.

### G4 iPhone lifecycle (after G3)

- Add SDL app-lifecycle handling on iOS (`SDL_APP_WILLENTERBACKGROUND`,
  `SDL_APP_DIDENTERFOREGROUND`) in `platform_ios.cpp`: pause the sim on
  background, write a dedicated lifecycle autosave, flush saves/config,
  suspend audio/render; resume paused and revalidate audio on foreground.
- Test 20 background/foreground cycles via `simctl`; terminate while
  backgrounded, relaunch, load the lifecycle save; preserve manual saves.

## After G4

G5 iPad Simulator + Pencil shell compared to CaesarPad (iPad mini/11/13
sizes, long-press right-click, two-finger tap, pan vs pinch, precision
cursor, Help/Pencil bar, Pencil touch identity), then G6 subset + G9.
