#!/usr/bin/env bash
# Package the audited macOS app into a self-contained, data-free .dmg.
# Evidence: clean build -> audit -> dmg -> download-back-style audit.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${1:-$ROOT_DIR/build/macos/akhenaten.app}"
OUT_DIR="${DMG_OUT_DIR:-$ROOT_DIR/build/release}"
DMG_NAME="${DMG_NAME:-EmeraldTablet-macOS-$(git -C "$ROOT_DIR" rev-parse --short HEAD).dmg}"

if [[ ! -d "$APP_PATH" ]]; then
    echo "macOS app not found: $APP_PATH (run scripts/build-macos.sh first)" >&2
    exit 1
fi

"$ROOT_DIR/scripts/audit-macos-app.sh" "$APP_PATH"

mkdir -p "$OUT_DIR"
STAGING="$(mktemp -d -t emeraldtablet-dmg)"
trap 'rm -rf "$STAGING"' EXIT

cp -R "$APP_PATH" "$STAGING/"

# Self-contained check before packaging: no absolute dylib references.
BIN="$STAGING/akhenaten.app/Contents/MacOS/akhenaten"
if otool -L "$BIN" | grep -E "/usr/local|opt/homebrew|libssl|libcrypto|nghttp2|libssh"; then
    echo "DMG packaging failed: non-self-contained linkage detected" >&2
    exit 1
fi

if command -v hdiutil >/dev/null; then
    rm -f "$OUT_DIR/$DMG_NAME"
    hdiutil create -volname "Emerald Tablet" -srcfolder "$STAGING" \
        -ov -format UDZO "$OUT_DIR/$DMG_NAME" >/dev/null
else
    echo "hdiutil not found; dmg creation unavailable" >&2
    exit 1
fi

echo "Built $OUT_DIR/$DMG_NAME"
ls -la "$OUT_DIR/$DMG_NAME"
