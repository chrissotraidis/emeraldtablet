# Release checklist (developer preview)

Run in order. Every step writes evidence; nothing is a "green build" shortcut
for the next step.

## 1. Source state

- [ ] `git status` clean except the intended patch queue in the engine
      submodule (working tree = pin + `patches/akhenaten/*.patch`)
- [ ] Engine submodule at `38cb947ead3895408ea32f74fda6e37921a42bd3`
- [ ] `scripts/check-repo-safety.sh` passes

## 2. Builds

- [ ] `scripts/apply-patches.sh` applies 0001-0006 cleanly
- [ ] `scripts/build-macos.sh` succeeds
- [ ] `scripts/audit-macos-app.sh build/macos/akhenaten.app` passes
      (arm64, minos 11.7, system frameworks only)
- [ ] `scripts/build-ios-sim.sh` succeeds
- [ ] `scripts/audit-ios-app.sh .../akhenaten.app` passes
      (arm64, iOS 15.0 Simulator, iOS-valid frameworks only)

## 3. Evidence gates

- [ ] Hermetic suite: `scripts/run-macos-hermetic.sh` reports the expected
      pass count (upstream flaky tests are documented, not hidden)
- [ ] G0-G6 evidence present in `docs/validation/` (summary in docs, raw in
      ignored `artifacts/private/`)
- [ ] G7/G8 physical gates explicitly marked HUMAN (not claimed)

## 4. Packaging

- [ ] `scripts/package-macos-dmg.sh` produces a data-free `.dmg`
- [ ] `scripts/package-ios-ipa.sh` produces an unsigned data-free `.ipa`
- [ ] `scripts/generate-source-manifest.sh` writes `SOURCE-MANIFEST.txt`
      (wrapper commit, engine pin, patch hashes, dependency versions,
      artifact SHA-256)
- [ ] Download-back-style audit: mount the dmg and scan the ipa — no
      `campaign.txt`, saves, `*.sg2/3`, `*.555`, `*.bik`, `*.smk`, signing
      material

## 5. Verification

- [ ] `scripts/verify-release-candidate.sh` passes (local == origin/main ==
      GitHub API main; release dir data-free)
- [ ] README + docs updated (`INSTALL_MACOS.md`, `INSTALL_IPA.md`,
      `COMPATIBILITY.md`, `RIGHTS_AND_LICENSES.md`)
- [ ] AGPL + third-party notices present; corresponding-source link accurate

## 6. Publication (only when authorized)

- [ ] `git push origin main` and confirm the SHA triple-match
- [ ] If a hosted release is later authorized, re-run the verifier against
      the downloaded bytes
