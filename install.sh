#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

PACKAGE_DIR="$HERE/package"
METADATA="$PACKAGE_DIR/metadata.json"

PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids"

ICON_NAME="Beautiful.SystemMonitor"
ICON_DIR="$HOME/.local/share/icons/hicolor"

echo "Installing Beautiful System Monitor..."

# Extract ID from metadata
ID=$(grep -oE '"Id":[[:space:]]*"[^"]+"' "$METADATA" \
    | head -1 \
    | sed -E 's/.*"([^"]+)"/\1/')

if [ -z "$ID" ]; then
    echo "Could not determine plasmoid ID."
    exit 1
fi

echo "Plasmoid ID: $ID"

#
# Install plasmoid
#
mkdir -p "$PLASMOID_DIR"

rm -rf "$PLASMOID_DIR/$ID"

cp -r "$PACKAGE_DIR" "$PLASMOID_DIR/$ID"

echo "Installed plasmoid."

#
# Install icon
#
if [ -f "$PACKAGE_DIR/icon.svg" ]; then
    mkdir -p "$ICON_DIR/scalable/apps"
    cp "$PACKAGE_DIR/icon.svg" \
       "$ICON_DIR/scalable/apps/$ICON_NAME.svg"

    echo "Installed SVG icon."
elif [ -f "$PACKAGE_DIR/icon.png" ]; then
    mkdir -p "$ICON_DIR/256x256/apps"
    cp "$PACKAGE_DIR/icon.png" \
       "$ICON_DIR/256x256/apps/$ICON_NAME.png"

    echo "Installed PNG icon."
else
    echo "Warning: No icon.svg or icon.png found."
fi

#
# Refresh KDE caches
#
echo "Refreshing KDE caches..."

kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache \
        "$ICON_DIR" \
        >/dev/null 2>&1 || true
fi

echo ""
echo "Installation complete."
echo ""
echo "Restart Plasma if the icon does not appear:"
echo "  kquitapp6 plasmashell && kstart6 plasmashell"