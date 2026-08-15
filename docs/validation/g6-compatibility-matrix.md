# G6 — Compatibility matrix (developer-preview subset)

Host: Chris-Macbook-Air-M1.local / macOS 26.5.2 (25F84) arm64.
Wrapper `e979df7` + G0-G5/G6-prep tree; engine pin
`38cb947ead3895408ea32f74fda6e37921a42bd3` + patches 0001-0006.
Date: 2026-08-15.

## Method

A temporary JS integral-test probe (`zz_g6_matrix_probe.js`, removed after the
run) loaded each target map through the real Pharaoh + Cleopatra data folder
via the engine's own `__test_start_city_session` / `__game_load_map` harness,
recorded a per-map pass marker, and was run with the pinned macOS app binary
(`--integraltests --integraltest-only zz_g6_matrix_probe`, dummy SDL drivers,
real data directory). Raw log: `artifacts/private/g6/matrix-probe.log`.

## Map load matrix (measured)

| Map | Campaign | Result |
|---|---|---|
| `m_000_nubt.map` | Pharaoh early | loaded |
| `m_001_thinis.map` | Pharaoh early | loaded |
| `m_002_perwadjyt.map` | Pharaoh early | loaded |
| `m_003_nekhen.map` | Pharaoh early | loaded |
| `m_004_mennefer.map` | Pharaoh early/mid | loaded |
| `m_005_timna.map` | Pharaoh mid | loaded |
| `m_008_selima.map` | Pharaoh mid | loaded |
| `m_020_iwnw.map` | Pharaoh mid | loaded |
| `m_030_kush.map` | Pharaoh late | loaded |
| `m_040_raamses.map` | Pharaoh late | loaded |
| `m_044_kadesh.map` | Pharaoh late | loaded |
| `m_046_migdol.map` | Pharaoh late | loaded |
| `m_048_alexandria_1.map` | Cleopatra | loaded |
| `m_049_alexandria_2.map` | Cleopatra | loaded |
| `m_052_actium.map` | Cleopatra | loaded |
| `Alexandria.map` | Cleopatra custom | loaded |
| `Bridges.map` | Cleopatra custom | loaded |
| `Chariot Blitz.map` | Cleopatra custom | loaded |
| `Cataract.map` | Cleopatra custom | loaded |
| `Enkomi.map` | Cleopatra custom | loaded |
| `Henen-nesw.map` | Cleopatra custom | loaded |
| `data/default.map` | sandbox | loaded |

22/22 maps load and start a city session with authentic data. Zero failures.

## Behavioral categories (developer-preview subset)

The engine's own hermetic suite covers each category; the resource-backed full
run on this host reported `193 passed, 2 failed` (109, 137) and the second
run `192 passed, 3 failed` (109, 126, 137). The three failures are measured
upstream timing/data behaviors, not Apple-patch regressions (see below).

| Category | Covered by engine tests (all otherwise pass) |
|---|---|
| Floodplain / farming | `35_floodplain_farm_placement`, `107/111/98/99_flood_basin_*`, `147_farm_info_flood_irrigation` |
| Monument build + save/reload mid-build | `106_meidum_complex_rating_saveload`, `130_stepped_sm_midphase_saveload`, `105/108/109/110/112_true_pyramid_*`, `45/128/141/143/145/146_*mastaba/tomb*` |
| Trade / empire | `64_trader_capacity`, `167_trader_per_good`, `21_dock_placement`, `93_dock_orders`, `149/159_bazaar_*`, `158_caravan_*` |
| Land combat | `104_kingdome_army`, `127_egyptian_spearman_missile`, `136_troop_carry`, `142_invasion_bribe`, `169_invasion_warnings_saveload`, `179_troops_distant_battle` |
| Naval | `139_naval_mission_sea`, `19/20/22/23_*wharf*`, `53_enemy_warship_registered`, `100/101_*transport*`, `103_transport_embark_js_api` |
| Audio | G1 Mac play: FLAC/MP3/OGG/MIDI initialized (57) during authentic Nubt play |
| Videos | G3: intro video played with active audio session on iPhone Simulator |
| Original save load | G1/G3/G5: original-format saves (VERSION 189, 114 sections, 0 missing) load on macOS, iPhone, iPad |
| macOS → iOS save | G3/G5: macOS quicksave loaded on iPhone/iPad via Continue |
| iOS → macOS save | **Measured**: iPhone-created `lifecycle.svx` (format 189) copied into the macOS data dir and loaded via `__game_load_savegame` — `File read successful: ...iphone.svx 0@ --- CONTAINER rev 1, VERSION 189, 114 sections (0 missing) ---`, marker `g6_ios_save_loaded`. Evidence: `artifacts/private/g6/iphone-lifecycle-proof.svx`, `iphone-save-on-mac.svx` (gitignored) |
| Sandbox / custom map | `data/default.map` + `Maps/*.map` load (probe) |

## Flaky / upstream findings (measured, not Apple defects)

Bisection on identical data, cfg, and app-bundle layout:

- Test `137_monument_carry` fails on the **clean pinned engine** (no patches)
  with `CO1b expected relocated tile, got 1,1` — upstream/data behavior.
- Tests `109_kingdome_favour_smoke` and `126_kingdome_favour_waves` are
  timing-flaky: `figures.update: pump_frames often yields 0 sim ticks under
  integraltests` (comment in 109). They pass on some runs and fail on others
  with the same binary (109: 2/2 pass then 5/5 fail across build dirs; 126:
  1/3, 2/3, 2/2 pass across runs). The G1 record (`194 passed, 0 failed`,
  2026-08-13) caught them green.
- Apple patches 0001-0006 change no macOS gameplay path: every relevant diff
  is guarded by `GAME_PLATFORM_IOS` / `TARGET_OS_IOS` / `MATCHES "iOS"` or is
  iOS-only source; the macOS binary, data directory, cfg, and app bundle
  layout are identical between passing and failing runs.

## Next

- Re-run the hermetic suite and record the flake count/range.
- G9 release engineering after G6 subset closes.
