#!/usr/bin/env bash
# Package the audited iOS Simulator .app into an unsigned, data-free .ipa
# (Payload/ layout). This is a sideloading/self-signing artifact, not a store
# release. Evidence: audit -> ipa -> content audit.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${1:-$ROOT_DIR/build/ios-sim/RelWithDebInfo-iphonesimulator/akhenaten.app}"
OUT_DIR="${IPA_OUT_DIR:-$ROOT_DIR/build/release}"
IPA_NAME="${IPA_NAME:-EmeraldTablet-iOS-$(git -C "$ROOT_DIR" rev-parse --short HEAD).ipa}"

if [[ ! -d "$APP_PATH" ]]; then
    echo "iOS app not found: $APP_PATH (run scripts/build-ios-sim.sh first)" >&2
    exit 1
fi

"$ROOT_DIR/scripts/audit-ios-app.sh" "$APP_PATH"

mkdir -p "$OUT_DIR"
STAGING="$(mktemp -d -t emeraldtablet-ipa)"
trap 'rm -rf "$STAGING"' EXIT

mkdir -p "$STAGING/Payload"
cp -R "$APP_PATH" "$STAGING/Payload/"

# Data-free audit: no original game markers, saves, or private files in the
# packaged tree.
forbidden="$(find "$STAGING" \( -iname 'campaign.txt' -o -iname '*.svx' \
    -o -iname '*.sav' -o -iname '*.sg2' -o -iname '*.sg3' -o -iname '*.555' \
    -o -iname '*.bik' -o -iname '*.smk' \) -print 2>/dev/null || true)"
if [[ -n "$forbidden" ]]; then
    printf '%s\n' "$forbidden" >&2
    echo "IPA packaging failed: prohibited data found" >&2
    exit 1
fi

rm -f "$OUT_DIR/$IPA_NAME"
(cd "$STAGING" && zip -qr "$OUT_DIR/$IPA_NAME" Payload)

echo "Built $OUT_DIR/$IPA_NAME"
unzip -l "$OUT_DIR/$IPA_NAME" | tail -3
