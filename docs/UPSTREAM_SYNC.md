# Akhenaten upstream sync

Emerald Tablet builds a fixed Akhenaten commit plus an ordered patch queue. A
release must never float on Akhenaten `master`, but the queue should be audited
regularly so upstream fixes can be adopted without accumulating a private fork.

## Current baseline and audit

- Release pin: `38cb947ead3895408ea32f74fda6e37921a42bd3`.
- Audited upstream tip on 2026-08-19:
  `6211d4681369ecfb7aae004ab71ecb21df6dd787`.
- The GitHub comparison reported 133 upstream commits after the release pin.
- Ordered application reaches patch `0004` before stopping. Its conflicts are
  limited to `ui_top_menu_actions.js` and `ui_top_menu_widget.js`, where
  upstream moved menu behavior to event-system handlers.
- An exploratory reject-based pass found later conflicts in five `0007` files
  (`boilerplate.cpp`, dynasty/main/campaign menus, and sound options) and one
  `0009` file (`ui_sidebar_window.js`). Patches `0001`-`0003`, `0005`, `0006`,
  `0008`, and `0010` otherwise apply cleanly when probed independently.

This is bounded rebase work, not evidence that Emerald Tablet needs to fork the
engine. Upstream already fixed the campaign screen's exit destination, so that
local hunk should be dropped during the rebase. Other conflicts are mostly API
migrations: re-express the Apple behavior through the new handlers, then rerun
the same tests rather than preserving obsolete code mechanically.

## Patch ownership

| Patch | Ownership | Sync treatment |
|---|---|---|
| `0001`-`0002` | Generic Apple/macOS build fixes | Prefer upstream; drop locally once the pin contains equivalent fixes |
| `0003` | iOS platform/build seam | Upstream candidate; keep isolated from UI policy |
| `0004`-`0009` | iOS/iPadOS product behavior | Rebase narrowly; delete hunks made redundant upstream |
| `0010` | Generic temple-complex save-loader correctness | Submit upstream with its synthetic regression test |
| `0011` | Generic legacy trader cleanup correctness | Submit upstream with its synthetic ship/caravan regression test |

Gameplay fixes must not be hidden inside Apple patches. If a defect reproduces
on unmodified Akhenaten, give it a separate patch and platform-neutral test.

## Safe audit workflow

Clone or fetch Akhenaten separately, then run:

```sh
scripts/audit-upstream-patches.sh /path/to/Akhenaten origin/master
```

The script resolves the requested commit, clones it into a disposable directory,
and applies Emerald Tablet's patches in order. It never changes the supplied
checkout or `engines/akhenaten`. On conflict it stops, prints the failing files,
and retains the disposable checkout for inspection.

For an actual pin update:

1. Record the exact candidate SHA and upstream comparison; never use a moving
   branch in a release.
2. Rebase one patch at a time. Drop redundant hunks and keep generic engine
   fixes separate from iOS behavior.
3. Reconstruct the pinned tree and run `scripts/check-repo-safety.sh`.
4. Run the focused regression for each conflict, the complete hermetic suite,
   macOS build/audit, and iOS Simulator build/audit.
5. Treat physical touch, Pencil, audio, lifecycle, save preservation, and
   performance as separate human/device gates before changing the release pin.

## Current engine limitations

Akhenaten remains work in progress; Emerald Tablet does not claim universal
Pharaoh + Cleopatra compatibility. The 2026-08-19 upstream issue pass includes
open reports around immigration, hunting/carrying meat, shrine behavior and
road access, debt timing/display, small-map boundaries, tutorial messages,
music selection, textures/localization, birds, and iOS support. These are engine
issues to reproduce and test upstream-first, not reasons to duplicate gameplay
systems in the wrapper.

The iOS GitHub mod-list action is a different boundary: Emerald Tablet excludes
libcurl from the mobile build, so iOS imports a trusted local `.sgx` through
Files instead. The upstream repository currently offers only a small sample
mod set; Emerald Tablet does not maintain a separate catalog.

Original 1999 saves are also sample-dependent. Two private `.sav` files now load
with patch `0010` (a 6,374-population Sais city and a very large Alexandria
city). They remain under ignored local storage and are not fixtures or release
content. The public regression creates five legal temple complexes and performs
an Akhenaten save/reload without proprietary data.
