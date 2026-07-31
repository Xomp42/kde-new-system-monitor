#!/usr/bin/env bash
set -euo pipefail

ID="Beautiful.SystemMonitor"

rm -rf "$HOME/.local/share/plasma/plasmoids/$ID"

rm -f "$HOME/.local/share/icons/hicolor/scalable/apps/$ID.svg"
rm -f "$HOME/.local/share/icons/hicolor/256x256/apps/$ID.png"

kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

echo "Removed $ID"