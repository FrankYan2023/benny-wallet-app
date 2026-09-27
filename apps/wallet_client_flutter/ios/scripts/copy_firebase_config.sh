#!/bin/sh
set -eu

firebase_source="$SRCROOT/Runner/GoogleService-Info.plist"
firebase_destination="$TARGET_BUILD_DIR/$UNLOCALIZED_RESOURCES_FOLDER_PATH/GoogleService-Info.plist"

if [ -f "$firebase_source" ]; then
  /usr/bin/plutil -lint "$firebase_source" >/dev/null
  /bin/mkdir -p "$(dirname "$firebase_destination")"
  /bin/cp "$firebase_source" "$firebase_destination"
elif [ "${CONFIGURATION#Debug}" != "$CONFIGURATION" ]; then
  # Remove only a stale copy in the generated app bundle, never a source config.
  /bin/rm -f "$firebase_destination"
  echo "note: Debug build without Firebase plist. Push requires configured Firebase runtime options."
else
  echo "error: Add the real Runner/GoogleService-Info.plist for this release configuration."
  exit 1
fi
