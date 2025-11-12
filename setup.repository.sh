#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename "$0") <path-to-example-root>" >&2
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_SOURCE="$SCRIPT_DIR/assets/icon/ios"
TARGET_ROOT="$1/example"
TARGET_DIR="$TARGET_ROOT/ios/Runner/Assets.xcassets/AppIcon.appiconset"

if [ ! -d "$ICON_SOURCE" ]; then
  echo "Icon source not found: $ICON_SOURCE" >&2
  exit 1
fi

if [ ! -d "$TARGET_ROOT" ]; then
  echo "Example root not found: $TARGET_ROOT" >&2
  exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
  echo "Target asset catalog not found, skipping copy: $TARGET_DIR" >&2
  exit 0
fi

shopt -s nullglob
files=("$ICON_SOURCE"/*)
if [ ${#files[@]} -eq 0 ]; then
  echo "No icon files found in $ICON_SOURCE" >&2
  exit 1
fi

cp -v "$ICON_SOURCE"/* "$TARGET_DIR"/

echo "Copied ${#files[@]} icon assets to $TARGET_DIR"
