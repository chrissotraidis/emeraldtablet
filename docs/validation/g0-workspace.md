# G0 workspace and source safety

Date: 2026-08-13
Host: Chris-Macbook-Air-M1.local, macOS 26.5.2 (25F84), Darwin 25.5.0 arm64
Xcode: 26.6 (17F113)
CMake: 4.4.0
Git: 2.36.1
Ninja: present
Physical devices: none attached
Simulators available: iPhone 16/16e/17 families and iPad mini/11-inch/13-inch on iOS 18.5 and 26.5
Free space: about 57 GiB

## Recorded pins

- Wrapper starting commit: `e979df7` (`Add files via upload`)
- Akhenaten submodule: `38cb947ead3895408ea32f74fda6e37921a42bd3`
- CaesarPad local reference: `07a8d38a4eae77d01c6d980ecbc36de8fad97ef6`
- Patch queue: empty

## Commands

```sh
git submodule status
git -C engines/akhenaten rev-parse HEAD
git -C engines/akhenaten status --porcelain
scripts/apply-patches.sh
scripts/check-repo-safety.sh
scripts/validate-ref-markers.sh
git ls-files ref
```

## Results

- `engines/akhenaten` is a tracked submodule at the research pin.
- The engine worktree is clean.
- The empty patch queue applies as a no-op.
- `scripts/check-repo-safety.sh` passed.
- `git ls-files ref` is empty.
- Local Pharaoh + Cleopatra markers exist under ignored `ref/` (`campaign.txt`, `Data/`, and a Cleopatra pack). No hashes or file listings are recorded.

## What this proves

- Workspace inventory
- Source pin reconstruction
- Private-data ignore and safety scan

It does not prove a Mac build, gameplay, install, or package.

## Fact vs inference

Fact.
