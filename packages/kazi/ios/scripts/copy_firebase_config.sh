#!/bin/sh
set -e

# Firebase's iOS config is per flavor and gitignored, exactly like the Android
# google-services.json, so it is picked at build time instead of sitting in the
# Runner group. See ios/README.md.
SOURCE="${SRCROOT}/config/${FLAVOR_CONFIG_DIR}/GoogleService-Info.plist"
BUNDLE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

if [ ! -f "${SOURCE}" ]; then
  echo "error: missing ${SOURCE} — see ios/README.md"
  exit 1
fi

cp "${SOURCE}" "${BUNDLE}/GoogleService-Info.plist"

# Google Sign-In comes back through a URL scheme that is the client id with its
# components reversed. Reading it out of the file that already holds it keeps
# the two flavors from ever pointing at each other's Firebase project.
REVERSED_CLIENT_ID=$(/usr/libexec/PlistBuddy -c 'Print :REVERSED_CLIENT_ID' "${SOURCE}")
/usr/libexec/PlistBuddy \
  -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 ${REVERSED_CLIENT_ID}" \
  "${BUILT_PRODUCTS_DIR}/${INFOPLIST_PATH}"
