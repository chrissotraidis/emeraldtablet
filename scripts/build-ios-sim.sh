#!/usr/bin/env bash
# Configure and build the pinned Akhenaten engine for the iPhone Simulator SDK.
# Produces a data-free .app under build/ios-sim/RelWithDebInfo-iphonesimulator/.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/akhenaten"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/ios-sim}"
BUILD_CONFIG="${IOS_BUILD_CONFIG:-RelWithDebInfo}"
DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-15.0}"
ARCHS="${IOS_ARCHS:-arm64}"
LOG_PATH="${BUILD_LOG:-$BUILD_DIR/build.log}"
ICON_SOURCE="$ROOT_DIR/assets/ios/AppIcon.png"
ICON_DEST="$ENGINE_DIR/res/ios/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

if [[ ! -f "$ENGINE_DIR/CMakeLists.txt" ]]; then
    echo "Akhenaten submodule is missing. Run: git submodule update --init engines/akhenaten" >&2
    exit 1
fi

"$ROOT_DIR/scripts/apply-patches.sh"

if [[ ! -f "$ICON_SOURCE" ]]; then
    echo "Missing iOS app icon: $ICON_SOURCE" >&2
    exit 1
fi
if [[ "$(sips -g pixelWidth -g pixelHeight "$ICON_SOURCE" 2>/dev/null | awk '/pixelWidth:/{w=$2} /pixelHeight:/{h=$2} END{print w "x" h}')" != "1024x1024" ]]; then
    echo "iOS app icon must be 1024x1024." >&2
    exit 1
fi
if sips -g hasAlpha "$ICON_SOURCE" 2>/dev/null | grep -q 'yes'; then
    echo "iOS app icon must be opaque." >&2
    exit 1
fi
cp -f "$ICON_SOURCE" "$ICON_DEST"

if ! xcrun --sdk iphonesimulator --show-sdk-path >/dev/null 2>&1; then
    echo "iPhone Simulator SDK is not available. Install Xcode and its iOS platform." >&2
    exit 1
fi

mkdir -p "$BUILD_DIR"
: > "$LOG_PATH"

{
    cmake -S "$ENGINE_DIR" -B "$BUILD_DIR" \
        -G Xcode \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_SYSROOT=iphonesimulator \
        -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
        -DCMAKE_BUILD_TYPE="$BUILD_CONFIG" \
        -DOPTION_ENABLE_TRACY=OFF \
        -DOPTION_ENABLE_VIDEO_RECORDING=OFF \
        -DOPTION_ENABLE_INNOEXTRACT=OFF

    cmake --build "$BUILD_DIR" --config "$BUILD_CONFIG" --parallel
} 2>&1 | tee -a "$LOG_PATH"

APP_DIR="$BUILD_DIR/${BUILD_CONFIG}-iphonesimulator/akhenaten.app"
if [[ ! -d "$APP_DIR" ]]; then
    echo "Expected iOS app bundle was not produced: $APP_DIR" >&2
    exit 1
fi

# Engine-owned data (fonts, packs, maps) ships inside the app bundle.
# Original game data is user-supplied via the in-app importer at runtime.
ENGINE_DATA_DIR="$ENGINE_DIR/data"
mkdir -p "$APP_DIR/Data/maps"
cp -f "$ENGINE_DATA_DIR"/pharaoh_custom_pack.sgx \
      "$ENGINE_DATA_DIR"/pharaoh_fonts_pack.sgx \
      "$ENGINE_DATA_DIR"/pharaoh_houses_pack.sgx \
      "$ENGINE_DATA_DIR"/neucha.ttf \
      "$ENGINE_DATA_DIR"/default.map "$APP_DIR/Data/"
cp -R "$ENGINE_DATA_DIR/maps/." "$APP_DIR/Data/maps/"

if grep -E "was built for newer iOS version|built for newer iOS version|was built for newer 'iOS'" "$LOG_PATH" >/dev/null; then
    echo "iOS build failed: dependency objects were built for a newer iOS than $DEPLOYMENT_TARGET" >&2
    exit 1
fi

echo "Built $APP_DIR"
"$ROOT_DIR/scripts/audit-ios-app.sh" "$APP_DIR"
