#!/usr/bin/env bash
# Archives the prod app and exports an App Store Connect IPA. See ios/README.md.
# --upload also sends the archive to App Store Connect (TestFlight), signed in
# through the Xcode account. Every other argument is forwarded to
# `flutter build ipa` (e.g. --build-name=2.1.0 --build-number=20).
set -euo pipefail

IOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$(dirname "$IOS_DIR")"
ARCHIVE="$APP_DIR/build/ios/archive/Runner.xcarchive"
IPA_DIR="$APP_DIR/build/ios/ipa"

fail() {
  echo "✗ $1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing $1 — $2"
}

upload=false
flutter_args=()
for arg in "$@"; do
  if [[ "$arg" == '--upload' ]]; then
    upload=true
  else
    flutter_args+=("$arg")
  fi
done

echo "▸ Preflight"

# All three are declared as Flutter assets, so the build fails without any of them.
for flavor in prod staging prod_test; do
  require_file "$APP_DIR/.env.$flavor" 'env file, see packages/kazi/README.md'
done
require_file "$IOS_DIR/config/prod/GoogleService-Info.plist" 'prod Firebase config, see ios/README.md'
# Without a local identity the export falls back to cloud signing, whose
# requirement breaks on the "ã" in the certificate name. See ios/README.md.
security find-identity -v -p codesigning | grep -q 'Apple Distribution:' ||
  fail 'No local Apple Distribution certificate — create one in Xcode › Settings › Accounts › Manage Certificates'

VERSION="$(grep -E '^version:' "$APP_DIR/pubspec.yaml" | awk '{print $2}')"
echo "  pubspec version $VERSION (extra args: ${flutter_args[*]:-none})"

echo "▸ flutter build ipa (flavor prod, APP_ENV=prod)"
cd "$APP_DIR"
flutter build ipa \
  --release \
  --flavor prod \
  --dart-define=APP_ENV=prod \
  ${flutter_args[@]+"${flutter_args[@]}"}

[[ -d "$ARCHIVE" ]] || fail 'the build reported success but produced no archive'
APP_PLIST="$ARCHIVE/Products/Applications/Runner.app/Info.plist"
BUNDLE_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP_PLIST")"
BUILT_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PLIST")"
BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$APP_PLIST")"
[[ "$BUNDLE_ID" == 'com.myservices.kazi' ]] || fail "Archive is $BUNDLE_ID, not the prod bundle"

echo "▸ Verifying signature"
IPA_PAYLOAD="$(mktemp -d)"
trap 'rm -rf "$IPA_PAYLOAD"' EXIT
unzip -q "$IPA_DIR"/*.ipa -d "$IPA_PAYLOAD"
for bundle in "$IPA_PAYLOAD"/Payload/Runner.app "$IPA_PAYLOAD"/Payload/Runner.app/Frameworks/*.framework; do
  # --verbose=4 is what makes codesign check the designated requirement at all.
  codesign --verify --strict --verbose=4 "$bundle" 2>/dev/null ||
    fail "$(basename "$bundle") does not satisfy its designated requirement — App Store Connect would reject it"
done
codesign -dvv "$IPA_PAYLOAD/Payload/Runner.app" 2>&1 | grep -q 'Authority=Apple Distribution' ||
  fail 'The IPA is not signed with an Apple Distribution certificate'

echo "✓ $(ls "$IPA_DIR"/*.ipa)"
echo "  $BUNDLE_ID $BUILT_VERSION ($BUILD_NUMBER)"

if [[ "$upload" == true ]]; then
  echo "▸ Uploading to App Store Connect"
  xcodebuild -exportArchive \
    -archivePath "$ARCHIVE" \
    -exportOptionsPlist "$IOS_DIR/scripts/upload_export_options.plist" \
    -exportPath "$APP_DIR/build/ios/upload" \
    -allowProvisioningUpdates
  echo "✓ Uploaded $BUILT_VERSION ($BUILD_NUMBER); TestFlight lists it once processing ends"
fi
