#!/usr/bin/env bash
# Build and development-sign the pinned Akhenaten engine for physical iPhone/iPad hardware.
# Produces a data-free .app under build/ios-device/RelWithDebInfo-iphoneos/.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE_DIR="$ROOT_DIR/engines/akhenaten"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/build/ios-device}"
BUILD_CONFIG="${IOS_BUILD_CONFIG:-RelWithDebInfo}"
DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET:-15.0}"
ARCHS="${IOS_ARCHS:-arm64}"
BUNDLE_ID="${IOS_BUNDLE_ID:-com.chrissotraidis.emeraldtablet}"
DISPLAY_NAME="${IOS_DISPLAY_NAME:-Emerald Tablet}"
PROFILE_PATH="${IOS_PROVISIONING_PROFILE:-}"
SIGN_IDENTITY="${IOS_CODE_SIGN_IDENTITY:-}"
LOG_PATH="${BUILD_LOG:-$BUILD_DIR/build.log}"
ICON_SOURCE="$ROOT_DIR/assets/ios/AppIcon.png"
ICON_DEST="$ENGINE_DIR/res/ios/Assets.xcassets/AppIcon.appiconset/AppIcon.png"

if [[ ! -f "$ENGINE_DIR/CMakeLists.txt" ]]; then
    echo "Akhenaten submodule is missing. Run: git submodule update --init engines/akhenaten" >&2
    exit 1
fi
if [[ -z "$PROFILE_PATH" || ! -f "$PROFILE_PATH" ]]; then
    echo "Set IOS_PROVISIONING_PROFILE to an iOS development .mobileprovision file." >&2
    exit 1
fi
if [[ -z "$SIGN_IDENTITY" ]]; then
    echo "Set IOS_CODE_SIGN_IDENTITY to a certificate name or SHA-1 from:" >&2
    echo "  security find-identity -v -p codesigning" >&2
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

if ! xcrun --sdk iphoneos --show-sdk-path >/dev/null 2>&1; then
    echo "iPhoneOS SDK is not available. Install Xcode and its iOS platform." >&2
    exit 1
fi

mkdir -p "$BUILD_DIR"
: > "$LOG_PATH"

{
    cmake -S "$ENGINE_DIR" -B "$BUILD_DIR" \
        -G Xcode \
        -DCMAKE_SYSTEM_NAME=iOS \
        -DCMAKE_OSX_SYSROOT=iphoneos \
        -DCMAKE_OSX_ARCHITECTURES="$ARCHS" \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$DEPLOYMENT_TARGET" \
        -DCMAKE_BUILD_TYPE="$BUILD_CONFIG" \
        -DOPTION_ENABLE_TRACY=OFF \
        -DOPTION_ENABLE_VIDEO_RECORDING=OFF \
        -DOPTION_ENABLE_INNOEXTRACT=OFF

    # The generated target deliberately disables Xcode signing so dependency
    # targets are never provisioned. Assemble the complete bundle first, then
    # sign it once below.
    cmake --build "$BUILD_DIR" --config "$BUILD_CONFIG" \
        --target akhenaten --parallel
} 2>&1 | tee -a "$LOG_PATH"

APP_DIR="$BUILD_DIR/${BUILD_CONFIG}-iphoneos/akhenaten.app"
if [[ ! -d "$APP_DIR" ]]; then
    echo "Expected device app bundle was not produced: $APP_DIR" >&2
    exit 1
fi

# Engine-owned data ships in the app. Original Pharaoh/Cleopatra data is never
# copied here; users import their own folder at runtime.
ENGINE_DATA_DIR="$ENGINE_DIR/data"
mkdir -p "$APP_DIR/Data/maps"
cp -f "$ENGINE_DATA_DIR"/pharaoh_custom_pack.sgx \
      "$ENGINE_DATA_DIR"/pharaoh_fonts_pack.sgx \
      "$ENGINE_DATA_DIR"/pharaoh_houses_pack.sgx \
      "$ENGINE_DATA_DIR"/neucha.ttf \
      "$ENGINE_DATA_DIR"/default.map "$APP_DIR/Data/"
cp -R "$ENGINE_DATA_DIR/maps/." "$APP_DIR/Data/maps/"

plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$APP_DIR/Info.plist"
plutil -replace CFBundleDisplayName -string "$DISPLAY_NAME" "$APP_DIR/Info.plist"
plutil -replace UIFileSharingEnabled -bool true "$APP_DIR/Info.plist"
plutil -replace LSSupportsOpeningDocumentsInPlace -bool true "$APP_DIR/Info.plist"

PROFILE_PLIST="$BUILD_DIR/profile.plist"
ENTITLEMENTS="$BUILD_DIR/device-entitlements.plist"
security cms -D -i "$PROFILE_PATH" -o "$PROFILE_PLIST"
PROFILE_APP_ID="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$PROFILE_PLIST")"
PROFILE_TEAM_ID="$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:com.apple.developer.team-identifier' "$PROFILE_PLIST")"

if [[ "$PROFILE_APP_ID" != "$PROFILE_TEAM_ID.*" \
   && "$PROFILE_APP_ID" != "$PROFILE_TEAM_ID.$BUNDLE_ID" ]]; then
    echo "Provisioning profile does not cover bundle ID $BUNDLE_ID." >&2
    exit 1
fi

plutil -extract Entitlements xml1 -o "$ENTITLEMENTS" "$PROFILE_PLIST"
/usr/libexec/PlistBuddy -c "Set :application-identifier $PROFILE_TEAM_ID.$BUNDLE_ID" "$ENTITLEMENTS"
/usr/libexec/PlistBuddy -c "Set :com.apple.developer.team-identifier $PROFILE_TEAM_ID" "$ENTITLEMENTS"
if /usr/libexec/PlistBuddy -c 'Print :keychain-access-groups' "$ENTITLEMENTS" >/dev/null 2>&1; then
    /usr/libexec/PlistBuddy -c 'Delete :keychain-access-groups' "$ENTITLEMENTS"
fi
/usr/libexec/PlistBuddy -c 'Add :keychain-access-groups array' "$ENTITLEMENTS"
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string $PROFILE_TEAM_ID.$BUNDLE_ID" "$ENTITLEMENTS"

cp -f "$PROFILE_PATH" "$APP_DIR/embedded.mobileprovision"
codesign --force --sign "$SIGN_IDENTITY" --entitlements "$ENTITLEMENTS" \
    --timestamp=none "$APP_DIR"
codesign --verify --deep --strict --verbose=2 "$APP_DIR"

if grep -E "was built for newer iOS version|built for newer iOS version|was built for newer 'iOS'" "$LOG_PATH" >/dev/null; then
    echo "iOS build failed: dependency objects were built for a newer iOS than $DEPLOYMENT_TARGET" >&2
    exit 1
fi
if ! vtool -show-build "$APP_DIR/akhenaten" | grep -Eq '^[[:space:]]*platform IOS$'; then
    echo "Device build failed: executable is not an iPhoneOS binary." >&2
    exit 1
fi

echo "Built and signed $APP_DIR"
IOS_EXPECTED_BUNDLE_ID="$BUNDLE_ID" "$ROOT_DIR/scripts/audit-ios-app.sh" "$APP_DIR"
