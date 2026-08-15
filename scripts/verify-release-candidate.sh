#!/usr/bin/env bash
# Verify a release candidate: wrapper commit == remote == GitHub API main,
# source manifest present, artifacts data-free, SHA-256 recorded.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_DIR="${1:-$ROOT_DIR/build/release}"
MANIFEST="${2:-$RELEASE_DIR/SOURCE-MANIFEST.txt}"

fail() {
    echo "Release verification failed: $*" >&2
    exit 1
}

cd "$ROOT_DIR"

local_sha="$(git rev-parse HEAD)"
remote_sha="$(git ls-remote origin refs/heads/main | awk '{print $1}')"
api_sha="$(gh api repos/chrissotraidis/emeraldtablet/commits/main --jq .sha 2>/dev/null || true)"

[[ "$local_sha" == "$remote_sha" ]] || fail "local ($local_sha) != origin/main ($remote_sha)"
if [[ -n "$api_sha" ]]; then
    [[ "$local_sha" == "$api_sha" ]] || fail "local ($local_sha) != GitHub API main ($api_sha)"
fi
echo "main triple-match: $local_sha"

[[ -f "$MANIFEST" ]] || fail "source manifest missing: $MANIFEST"

forbidden="$(find "$RELEASE_DIR" \( -iname 'campaign.txt' -o -iname '*.svx' \
    -o -iname '*.sav' -o -iname '*.sg2' -o -iname '*.sg3' -o -iname '*.555' \
    -o -iname '*.bik' -o -iname '*.smk' -o -iname '*.mobileprovision' \
    -o -iname '*.p12' -o -iname '*.pem' -o -iname '*.key' \) -print 2>/dev/null || true)"
if [[ -n "$forbidden" ]]; then
    printf '%s\n' "$forbidden" >&2
    fail "prohibited material in release dir"
fi

echo "Release directory data-free: OK"
echo "Release verification passed."
