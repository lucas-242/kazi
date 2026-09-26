#!/usr/bin/env bash
# Builds the signed prod App Bundle for Google Play. See android/README.md.
# Extra arguments are forwarded to `flutter build appbundle`
# (e.g. --build-name=2.0.0 --build-number=16).
set -euo pipefail

ANDROID_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$(dirname "$ANDROID_DIR")"
KEY_PROPERTIES="$ANDROID_DIR/key.properties"
AAB="$APP_DIR/build/app/outputs/bundle/prodRelease/app-prod-release.aab"

fail() {
  echo "✗ $1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "Missing $1 — $2"
}

property() {
  grep -E "^$1=" "$KEY_PROPERTIES" | head -1 | cut -d= -f2- | tr -d '\r'
}

sha256_of() {
  grep -E '^[[:space:]]*SHA256:' | head -1 | awk '{print $2}'
}

echo "▸ Preflight"

require_file "$KEY_PROPERTIES" 'signing config, see android/README.md'
for key in storeFile.release storePassword.release keyAlias.release keyPassword.release adMobAppId.release; do
  [[ -n "$(property "$key")" ]] || fail "$key is empty in key.properties"
done

KEYSTORE="$ANDROID_DIR/app/$(property storeFile.release)"
require_file "$KEYSTORE" 'the upload keystore'
# All three are declared as Flutter assets, so the build fails without any of them.
for flavor in prod staging prod_test; do
  require_file "$APP_DIR/.env.$flavor" 'env file, see packages/kazi/README.md'
done
require_file "$ANDROID_DIR/app/src/prod/google-services.json" 'prod Firebase config'

UPLOAD_CERT_SHA256="$(
  keytool -list -v \
    -keystore "$KEYSTORE" \
    -storepass "$(property storePassword.release)" \
    -alias "$(property keyAlias.release)" 2>/dev/null | sha256_of
)" || true
[[ -n "$UPLOAD_CERT_SHA256" ]] ||
  fail 'Could not open the upload keystore with the password/alias in key.properties'

VERSION="$(grep -E '^version:' "$APP_DIR/pubspec.yaml" | awk '{print $2}')"
echo "  pubspec version $VERSION (extra args: ${*:-none})"

echo "▸ flutter build appbundle (flavor prod, APP_ENV=prod)"
cd "$APP_DIR"
flutter build appbundle \
  --release \
  --flavor prod \
  --dart-define=APP_ENV=prod \
  "$@"

echo "▸ Verifying signature"
require_file "$AAB" 'the build reported success but produced no bundle'
BUNDLE_CERT_SHA256="$(keytool -printcert -jarfile "$AAB" 2>/dev/null | sha256_of || true)"
[[ "$BUNDLE_CERT_SHA256" == "$UPLOAD_CERT_SHA256" ]] ||
  fail "Bundle is not signed with the upload key (got '${BUNDLE_CERT_SHA256:-unsigned}')"

echo "✓ $AAB"
echo "  $(du -h "$AAB" | cut -f1), signed with upload key $UPLOAD_CERT_SHA256"
