#!/usr/bin/env bash
# Package an audited iPhoneOS .app into an unsigned, data-free .ipa (Payload/
# layout). This is a sideloading/self-signing artifact, not a store release.
# Evidence: device-platform audit -> signing removal -> ipa content audit.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_PATH="${1:-$ROOT_DIR/build/ios-device/RelWithDebInfo-iphoneos/akhenaten.app}"
OUT_DIR="${IPA_OUT_DIR:-$ROOT_DIR/build/release}"
IPA_NAME="${IPA_NAME:-EmeraldTablet-iOS-$(git -C "$ROOT_DIR" rev-parse --short HEAD).ipa}"
IPA_VERSION="${IPA_VERSION:-0.1.0}"
IPA_BUILD="${IPA_BUILD:-1}"

if [[ ! -d "$APP_PATH" ]]; then
    echo "iPhoneOS app not found: $APP_PATH (run scripts/build-ios-device.sh first)" >&2
    exit 1
fi

BIN="$APP_PATH/akhenaten"
if ! vtool -show-build "$BIN" | grep -q 'platform IOS$'; then
    echo "IPA packaging failed: expected an iPhoneOS app, not a Simulator app" >&2
    exit 1
fi

BUNDLE_ID="$(plutil -extract CFBundleIdentifier raw "$APP_PATH/Info.plist")"
IOS_EXPECTED_BUNDLE_ID="$BUNDLE_ID" "$ROOT_DIR/scripts/audit-ios-app.sh" "$APP_PATH"

mkdir -p "$OUT_DIR"
STAGING="$(mktemp -d -t emeraldtablet-ipa)"
trap 'rm -rf "$STAGING"' EXIT

mkdir -p "$STAGING/Payload"
cp -R "$APP_PATH" "$STAGING/Payload/"
PACKAGED_APP="$STAGING/Payload/$(basename "$APP_PATH")"

plutil -replace CFBundleShortVersionString -string "$IPA_VERSION" \
    "$PACKAGED_APP/Info.plist"
plutil -replace CFBundleVersion -string "$IPA_BUILD" \
    "$PACKAGED_APP/Info.plist"

# A public preview must not disclose the maintainer's profile or certificate.
# Sideloading tools apply the installer's own signature after download.
codesign --remove-signature "$PACKAGED_APP" 2>/dev/null || true
rm -rf "$PACKAGED_APP/_CodeSignature"
rm -f "$PACKAGED_APP/embedded.mobileprovision"

# Data-free audit: no original game markers, saves, or private files in the
# packaged tree.
forbidden="$(find "$STAGING" \( -iname 'campaign.txt' -o -iname '*.svx' \
    -o -iname '*.sav' -o -iname '*.sg2' -o -iname '*.sg3' -o -iname '*.555' \
    -o -iname '*.bik' -o -iname '*.smk' -o -iname '*.mobileprovision' \
    -o -name '_CodeSignature' \) -print 2>/dev/null || true)"
if [[ -n "$forbidden" ]]; then
    printf '%s\n' "$forbidden" >&2
    echo "IPA packaging failed: prohibited data found" >&2
    exit 1
fi

rm -f "$OUT_DIR/$IPA_NAME"
(cd "$STAGING" && COPYFILE_DISABLE=1 zip -qr "$OUT_DIR/$IPA_NAME" Payload)

echo "Built $OUT_DIR/$IPA_NAME"
unzip -l "$OUT_DIR/$IPA_NAME" | tail -3
