#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"

echo "Symlinking scripts..."
mkdir -p "$HOME_DIR/.local/bin"

ln -sf "$HOME_DIR/projects/scripts/reaper.sh" "$HOME_DIR/.local/bin/reaper"
ln -sf "$HOME_DIR/projects/scripts/vcv-rack.sh" "$HOME_DIR/.local/bin/vcv-rack"

chmod +x /home/tristen/.local/bin/reaper
chmod +x /home/tristen/.local/bin/vcv-rack
