# Compatibility

Emerald Tablet is a **developer preview** of the open-source
[Akhenaten](https://github.com/dalerank/Akhenaten) engine on Apple platforms.
Compatibility is validated mission by mission and is **not** universal. See
[RIGHTS_AND_LICENSES.md](../RIGHTS_AND_LICENSES.md) for the data and licensing
boundary.

## Measured (developer-preview subset, 2026-08-15)

### Maps that load and start a city

22/22 tested maps load with authentic Pharaoh + Cleopatra data:

- **Pharaoh campaign (early/mid/late):** Nubt, Thinis, Perwadjyt, Nekhen,
  Men-nefer, Timna, Selima, Iwnw, Kush, Raamses, Kadesh, Migdol
- **Cleopatra campaign:** Alexandria 1/2, Actium
- **Cleopatra custom scenarios:** Alexandria, Bridges, Chariot Blitz,
  Cataract, Enkomi, Henen-nesw
- **Sandbox:** `default.map`

### Behaviors covered by the engine test suite

- Floodplain / farming seasons
- Monument construction and save/reload mid-build
- Trade and empire map
- Land combat
- Naval / transport
- Audio initialization (FLAC/MP3/OGG/MIDI) and intro video (G3)
- Original-format save loading (format 189)
- Cross-device saves: macOS → iOS and iOS → macOS (both measured)

## Known issues (measured)

- Three engine tests are flaky or data-sensitive on this host
  (`109_kingdome_favour_smoke`, `126_kingdome_favour_waves`,
  `137_monument_carry`). Clean-engine bisection shows these are upstream
  timing/data behaviors (`pump_frames often yields 0 sim ticks`), not Apple
  wrapper regressions. The G1 record (`194 passed, 0 failed`) caught them
  green on 2026-08-13.
- Akhenaten's own README states development is in progress; full campaign
  coverage and Cleopatra compatibility are not claimed.
- Simulator synthetic taps can drop; held/repeated taps work (G3).

## Not yet measured

- Complete base-campaign and Cleopatra mission completion (long sessions,
  victory conditions per mission).
- Long-session performance, thermals, and battery on physical hardware.
- Physical-device touch, audio routes, and Apple Pencil (G7/G8 human gates).
- Original-game save files produced by the 1999 release load; the reverse
  (Akhenaten save → original game) is not supported or tested.
