#!/usr/bin/env bash
# Configure and build a pinned arm64 macOS Akhenaten app.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/akhenaten"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/macos}"
DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET:-11.7}"
LOG_PATH="${BUILD_LOG:-$BUILD_DIR/build.log}"

if [[ ! -f "$ENGINE_DIR/CMakeLists.txt" ]]; then
    echo "Akhenaten submodule is missing. Run: git submodule update --init engines/akhenaten" >&2
    exit 1
fi

"$ROOT_DIR/scripts/apply-patches.sh"

mkdir -p "$BUILD_DIR"
: > "$LOG_PATH"

{
    cmake -S "$ENGINE_DIR" -B "$BUILD_DIR" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=RelWithDebInfo \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
        -DOPTION_ENABLE_TRACY=OFF \
        -DOPTION_ENABLE_VIDEO_RECORDING=OFF \
        -DOPTION_ENABLE_INNOEXTRACT=OFF

    cmake --build "$BUILD_DIR" --parallel
} 2>&1 | tee -a "$LOG_PATH"

APP_PATH="$BUILD_DIR/akhenaten.app"
if [[ ! -d "$APP_PATH" ]]; then
    echo "Expected app bundle was not produced: $APP_PATH" >&2
    exit 1
fi

if grep -E "was built for newer 'macOS' version|built for newer macOS version" "$LOG_PATH" >/dev/null; then
    echo "macOS build failed: dependency objects were built for a newer macOS than $DEPLOYMENT_TARGET" >&2
    exit 1
fi

echo "Built $APP_PATH"
"$ROOT_DIR/scripts/audit-macos-app.sh" "$APP_PATH"
