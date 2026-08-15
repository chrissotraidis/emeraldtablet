#!/usr/bin/env bash
# Fail if a macOS Akhenaten app is not self-contained or misses the
# requested deployment target. This is packaging evidence, not gameplay.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${1:-${ROOT_DIR}/build/macos/akhenaten.app}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.7}"
BINARY="${APP_PATH}/Contents/MacOS/akhenaten"

fail() {
    echo "macOS app audit failed: $*" >&2
    exit 1
}

if [[ ! -x "$BINARY" ]]; then
    fail "expected executable is missing: $BINARY"
fi

file_info="$(file "$BINARY")"
printf '%s\n' "$file_info"
[[ "$file_info" == *"Mach-O 64-bit executable arm64"* ]] ||
    fail "binary is not a Mach-O arm64 executable"

otool_out="$(otool -L "$BINARY")"
printf '%s\n' "$otool_out"

# Skip the Mach-O header line (`<binary>:`) so an absolute app path in the
# workspace is not treated as runtime linkage.
forbidden="$(
    printf '%s\n' "$otool_out" \
        | awk 'NR > 1 {print}' \
        | grep -E '/opt/homebrew/|/usr/local/|/Users/|/tmp/|@rpath' || true
)"
if [[ -n "$forbidden" ]]; then
    printf '%s\n' "$forbidden" >&2
    fail "binary has Homebrew, workspace, temporary, or rpath runtime linkage"
fi

# System libraries and weak/absolute system frameworks are allowed.
while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" == *":" ]] && continue
    path="$(printf '%s\n' "$line" | awk '{print $1}')"
    case "$path" in
        /System/Library/*|/usr/lib/*) ;;
        *)
            fail "unexpected non-system linkage: $path"
            ;;
    esac
done <<< "$otool_out"

vtool_out="$(vtool -show-build "$BINARY" 2>/dev/null || true)"
printf '%s\n' "$vtool_out"
printf '%s\n' "$vtool_out" | grep -q "minos ${DEPLOYMENT_TARGET}" ||
    fail "main executable minos is not ${DEPLOYMENT_TARGET}"

# Dependency static archives produced by the same build must not target a
# newer OS than the app. Missing archives are ignored so the audit can run
# against a copied .app alone.
BUILD_DIR="$(cd "$(dirname "$APP_PATH")" && pwd)"
newer_objects=""
for archive in \
    "$BUILD_DIR/libs/SDL2/libSDL2-static.a" \
    "$BUILD_DIR/libs/SDL2_mixer/libSDL2_mixer-static.a" \
    "$BUILD_DIR/libs/freetype/libfreetype.a" \
    "$BUILD_DIR/libs/harfbuzz/libharfbuzz.a"
do
    [[ -f "$archive" ]] || continue
    hits="$(otool -l "$archive" | awk '/minos/ {print $2}' | grep -v "^${DEPLOYMENT_TARGET}$" | sort -u || true)"
    if [[ -n "$hits" ]]; then
        newer_objects+="${archive}: ${hits}"$'\n'
    fi
done
if [[ -n "$newer_objects" ]]; then
    printf '%s' "$newer_objects" >&2
    fail "dependency objects were built for a newer macOS than ${DEPLOYMENT_TARGET}"
fi

echo "macOS app audit passed: $APP_PATH"
