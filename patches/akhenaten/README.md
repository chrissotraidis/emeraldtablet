# Akhenaten patch queue

Patches in this directory are applied in filename order to the pinned
`engines/akhenaten` submodule.

Each patch must include:

- purpose
- affected platforms
- upstream status
- tests
- a reason if it cannot be upstreamed

Keep platform enablement, importer, lifecycle, touch, Pencil, identity, and
release work in separate patches. Gameplay fixes must not be hidden inside
Apple product patches.

An empty queue is valid. G0 is satisfied when a clean submodule checkout plus
this directory reconstructs the pinned engine with no leftover diffs.
