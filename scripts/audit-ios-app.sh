#!/usr/bin/env bash
# Audit an Akhenaten iOS .app bundle: architecture, SDK, deployment target,
# frameworks, resources, and absence of desktop-only artifacts.
set -euo pipefail

APP_DIR="${1:-}"
if [[ -z "$APP_DIR" || ! -d "$APP_DIR" ]]; then
    echo "usage: audit-ios-app.sh <path-to.app>" >&2
    exit 1
fi

BIN="$APP_DIR/akhenaten"
PLIST="$APP_DIR/Info.plist"
fail=0

echo "== Bundle =="
ls -la "$APP_DIR"

if [[ ! -x "$BIN" ]]; then
    echo "FAIL: executable missing at $BIN" >&2
    exit 1
fi

echo "== Architecture =="
lipo -info "$BIN"
if ! lipo -info "$BIN" | grep -q "arm64"; then
    echo "FAIL: binary is not arm64" >&2
    fail=1
fi

echo "== Deployment target =="
vtool -show-build "$BIN" | grep -E "platform|minos|sdk" || true

echo "== Frameworks / linkage (must be iOS-valid only) =="
otool -L "$BIN" || true
if otool -L "$BIN" 2>/dev/null | grep -E "Cocoa|Carbon|ForceFeedback|AppKit"; then
    echo "FAIL: desktop-only framework linked" >&2
    fail=1
fi
if otool -L "$BIN" 2>/dev/null | grep -E "/usr/local|opt/homebrew|libssl|libcrypto|nghttp2"; then
    echo "FAIL: Homebrew/non-system dylib linked" >&2
    fail=1
fi

echo "== Info.plist =="
plutil -p "$PLIST" | head -40
CFID=$(plutil -extract CFBundleIdentifier raw "$PLIST" 2>/dev/null || echo "")
if [[ "$CFID" != "mt.dalerank.akhenaten" ]]; then
    echo "FAIL: unexpected bundle identifier '$CFID'" >&2
    fail=1
fi

echo "== No desktop-only artifacts =="
if [[ -e "$APP_DIR/Contents" ]]; then
    echo "FAIL: macOS Contents/ layout present" >&2
    fail=1
fi
if ls "$APP_DIR" | grep -qE "launch.sh|akhenaten-updater"; then
    echo "FAIL: desktop launch script or updater shipped" >&2
    fail=1
fi

echo "== Engine data in bundle =="
if [[ ! -d "$APP_DIR/Data" ]]; then
    echo "WARN: no Data/ in bundle (engine data deploy did not run)" >&2
fi
ls "$APP_DIR/Data" 2>/dev/null | head || true

if [[ "$fail" -ne 0 ]]; then
    echo "AUDIT FAILED" >&2
    exit 1
fi
echo "AUDIT OK"
