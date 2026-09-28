# Agent instructions

This is a thin Apple wrapper around a pinned Akhenaten engine.

Before changing anything, read:

- `docs/AKHENATEN-APPLE-FEASIBILITY-AND-IMPLEMENTATION-PLAN.md`
- `STATE.md`
- `RIGHTS_AND_LICENSES.md`

Work one red gate at a time in this order: G0, G1, G2, G3, G4, G5, then the
developer-preview subset of G6 and G9. Physical G7/G8 remain human/device gates.

Rules:

- Treat `ref/` as read-only, local-only input.
- Never commit, package, or log original Pharaoh/Cleopatra data, saves, signing
  material, or generated apps.
- Keep Apple changes as a small ordered patch queue against `engines/akhenaten`.
- Do not apply CaesarPad's Augustus patches blindly.
- Never weaken tests to make a gate look green.
- Compilation, installation, PID, render, gameplay, input, audio, save, and
  lifecycle evidence are separate.
- Preserve unrelated worktree changes and all user data.

## Release gate

Every public release artifact (IPA, APK, macOS or desktop build, and any source archive attached to a release) must pass `python3 ~/.codex/release-gate/release_gate.py <artifact>` on the maintainer's machine before it is published. A failure is a stop, not a note. Never commit original game data, ROMs, discs, keys, or translated or decompiled game code.
