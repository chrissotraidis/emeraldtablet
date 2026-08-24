#!/usr/bin/env bash
# Test Emerald Tablet's ordered patch queue against another Akhenaten checkout
# without changing that checkout or the pinned submodule.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="${1:-}"
REF="${2:-HEAD}"

if [[ -z "$SOURCE" || ! -d "$SOURCE" ]]; then
    echo "Usage: $0 /path/to/clean/Akhenaten [git-ref]" >&2
    exit 2
fi

SOURCE="$(cd "$SOURCE" && pwd)"
if ! git -C "$SOURCE" rev-parse --git-dir >/dev/null 2>&1; then
    echo "Not an Akhenaten git checkout: $SOURCE" >&2
    exit 2
fi

TARGET="$(git -C "$SOURCE" rev-parse "${REF}^{commit}")"
TEMP_BASE="${TMPDIR:-/tmp}"
AUDIT_ROOT="$(mktemp -d "${TEMP_BASE%/}/emerald-upstream-audit.XXXXXX")"
AUDIT_ENGINE="$AUDIT_ROOT/akhenaten"

git -c init.defaultBranch=main -c advice.detachedHead=false \
    clone --quiet --no-hardlinks "$SOURCE" "$AUDIT_ENGINE"
git -c advice.detachedHead=false -C "$AUDIT_ENGINE" \
    checkout --quiet --detach "$TARGET"

echo "Akhenaten target: $TARGET"
echo "Disposable audit: $AUDIT_ENGINE"

shopt -s nullglob
PATCHES=("$ROOT"/patches/akhenaten/*.patch)
shopt -u nullglob

for patch in "${PATCHES[@]}"; do
    name="$(basename "$patch")"
    if git -C "$AUDIT_ENGINE" apply --check "$patch"; then
        git -C "$AUDIT_ENGINE" apply "$patch"
        echo "PASS $name"
        continue
    fi

    echo "CONFLICT $name" >&2
    git -C "$AUDIT_ENGINE" apply --check "$patch" 2>&1 || true
    echo "Stopped at the first ordered conflict." >&2
    echo "Inspection checkout retained at: $AUDIT_ENGINE" >&2
    exit 1
done

echo "PASS all ${#PATCHES[@]} patches"
rm -rf -- "$AUDIT_ROOT"
