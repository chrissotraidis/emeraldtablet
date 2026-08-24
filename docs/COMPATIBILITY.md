# Compatibility

Emerald Tablet is a **developer preview** of the open-source
[Akhenaten](https://github.com/dalerank/Akhenaten) engine on Apple platforms.
Compatibility is validated mission by mission and is **not** universal. See
[RIGHTS_AND_LICENSES.md](../RIGHTS_AND_LICENSES.md) for the data and licensing
boundary.

## Measured (developer-preview subset, updated 2026-08-20)

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
- Akhenaten save loading (format 189)
- Cross-device saves: macOS → iOS and iOS → macOS (both measured)
- One sampled original-1999 `.sav` file (version header 160) can be parsed and
  converted: the private 6,374-population Sais city. Patches `0010`-`0012`
  address three concrete load/render faults, and the untouched source save can
  write and reload a format-189 copy. This is conversion evidence only; the
  physical result is not a playable compatibility pass.

## Known issues (measured)

- Three engine tests are flaky or data-sensitive on this host
  (`109_kingdome_favour_smoke`, `126_kingdome_favour_waves`,
  `137_monument_carry`). Clean-engine bisection shows these are upstream
  timing/data behaviors (`pump_frames often yields 0 sim ticks`), not Apple
  wrapper regressions. The G1 record (`194 passed, 0 failed`) caught them
  green on 2026-08-13.
- Akhenaten's own README states development is in progress; full campaign
  coverage and Cleopatra compatibility are not claimed.
- Open upstream reports include immigration, hunting/carrying meat, shrine
  behavior and access, debt timing/display, small-map boundaries, tutorial
  messages, music selection, textures/localization, birds, and iOS support.
  See [the upstream-sync record](UPSTREAM_SYNC.md) before implementing a local
  gameplay workaround.
- Simulator synthetic taps can drop; held/repeated taps work (G3).
- A private original-1999 Alexandria stress save loads to 58,822 population,
  then crashes in legacy religion-supply state. This is independent of the Sais
  image-remap repair and remains unsupported; it should not be used as a
  showcase save.
- The private Sais save is also unsupported as a playable save. On the physical
  iPad it retained large black map gaps, stalled/looping walkers, and repeated
  isolated-sector/stagnation warnings after conversion. Those symptoms show
  that its legacy map/routing state did not migrate coherently; they are not
  fog of war and are not addressed by another Emerald Tablet wrapper patch.

## Not yet measured

- Complete base-campaign and Cleopatra mission completion (long sessions,
  victory conditions per mission).
- Long-session performance, thermals, and battery on physical hardware.
- All physical-iPhone behavior, physical-device audio routes, iPad lifecycle
  interruption, and sustained hardware performance. Representative iPad touch,
  Pencil movement, construction/cancellation, and Save Game flow are accepted.
- Broad original-save compatibility. The two measured original-save samples are
  both unsupported for play. Loading
  Akhenaten format-189 saves in the original 1999 game is not supported or
  tested.
