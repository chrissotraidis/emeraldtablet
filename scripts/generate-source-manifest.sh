#!/usr/bin/env bash
# Generate the exact source/dependency manifest for a release candidate:
# wrapper commit, engine pin, patch list, dependency versions/hashes, build
# commands, artifact SHA-256. Output goes to build/release/SOURCE-MANIFEST.txt.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="${MANIFEST_OUT_DIR:-$ROOT_DIR/build/release}"
mkdir -p "$RELEASE_DIR"
OUT="$RELEASE_DIR/SOURCE-MANIFEST.txt"

{
    echo "Emerald Tablet — source and dependency manifest"
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "== Wrapper =="
    echo "commit: $(git -C "$ROOT_DIR" rev-parse HEAD)"
    echo "branch: $(git -C "$ROOT_DIR" rev-parse --abbrev-ref HEAD)"
    echo "origin/main: $(git -C "$ROOT_DIR" ls-remote origin refs/heads/main | awk '{print $1}')"
    echo
    echo "== Engine (pinned submodule) =="
    echo "path: engines/akhenaten"
    echo "pin: $(git -C "$ROOT_DIR/engines/akhenaten" rev-parse HEAD)"
    echo
    echo "== Patch queue (ordered) =="
    for p in "$ROOT_DIR"/patches/akhenaten/*.patch; do
        echo "  $(basename "$p")  sha256=$(shasum -a 256 "$p" | awk '{print $1}')"
    done
    echo
    echo "== Dependency versions (pinned in engines/akhenaten/CMakeLists.txt) =="
    grep -oE '^set\([A-Z0-9_]+_VERSION "[^"]+"' \
        "$ROOT_DIR/engines/akhenaten/CMakeLists.txt" 2>/dev/null \
        | sed 's/set(//; s/")/"/; s/)/)/' || true
    echo
    echo "== Artifacts (SHA-256) =="
    for f in "$RELEASE_DIR"/*.dmg "$RELEASE_DIR"/*.ipa; do
        [[ -f "$f" ]] || continue
        echo "  $(basename "$f")  sha256=$(shasum -a 256 "$f" | awk '{print $1}')"
    done
    echo
    echo "== Build commands =="
    echo "  scripts/apply-patches.sh"
    echo "  scripts/build-macos.sh"
    echo "  scripts/audit-macos-app.sh build/macos/akhenaten.app"
    echo "  scripts/package-macos-dmg.sh"
    echo "  scripts/build-ios-sim.sh"
    echo "  scripts/audit-ios-app.sh build/ios-sim/.../akhenaten.app"
    echo "  scripts/package-ios-ipa.sh"
} > "$OUT"

echo "Wrote $OUT"
