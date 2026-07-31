#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
METADATA="$HERE/package/metadata.json"

ID="$(grep -oE '"Id":[[:space:]]*"[^"]+"' "$METADATA" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
NAME="$(grep -oE '"Name":[[:space:]]*"[^"]+"' "$METADATA" | head -1 | sed -E 's/.*"([^"]+)"$/\1/')"
TEST_ID="${ID}Test"
TEMP_DIR="/tmp/$(basename "$HERE")-test"

rm -rf "$TEMP_DIR"
cp -r "$HERE/package" "$TEMP_DIR"

# Safely swap out the IDs and Names for testing isolation
sed -i "s/\"Id\": \"$ID\"/\"Id\": \"$TEST_ID\"/g" "$TEMP_DIR/metadata.json"
sed -i "s/\"Icon\": \"$ID\"/\"Icon\": \"$TEST_ID\"/g" "$TEMP_DIR/metadata.json"
sed -i "s/\"Name\": \"$NAME\"/\"Name\": \"$NAME (Test)\"/g" "$TEMP_DIR/metadata.json"

# 1. Map PNG graphics if they exist
ICON_DIR_PNG="$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$ICON_DIR_PNG"
if [ -f "$HERE/package/icon.png" ]; then
    cp "$HERE/package/icon.png" "$ICON_DIR_PNG/$TEST_ID.png"
fi

# 2. Map SVG graphics if they exist (Highly recommended for high-DPI displays)
ICON_DIR_SVG="$HOME/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$ICON_DIR_SVG"
if [ -f "$HERE/package/icon.svg" ]; then
    cp "$HERE/package/icon.svg" "$ICON_DIR_SVG/$TEST_ID.svg"
fi

# 3. Aggressively purge system caches to avoid stale graphic renderings
kbuildsycoca6 --noincremental &>/dev/null || true
rm -f ~/.cache/icon-cache.kcache
rm -rf ~/.cache/ksycoca6*

echo "Installing test version of the widget..."
if kpackagetool6 -t Plasma/Applet -l 2>/dev/null | grep -q -w "$TEST_ID"; then
    kpackagetool6 -t Plasma/Applet -u "$TEMP_DIR" 2>/dev/null
    echo "Updated existing test install."
else
    kpackagetool6 -t Plasma/Applet -i "$TEMP_DIR" 2>/dev/null
    echo "Installed fresh test widget."
fi

echo ""
echo "=== Test Widget Installed! ==="
echo "Add '$NAME (Test)' to your desktop or panel."
echo "To uninstall the test version later, run:"
echo "  kpackagetool6 -t Plasma/Applet -r $TEST_ID"
echo "  rm -f $ICON_DIR_PNG/$TEST_ID.png"
echo "  rm -f $ICON_DIR_SVG/$TEST_ID.svg"
