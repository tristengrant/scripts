#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"

echo "Symlinking scriptss..."
mkdir -p ~/.local/bin

ln -sf "$HOME_DIR/Projects/scripts/reaper.sh" "$HOME_DIR/.local/bin/reaper"
ln -sf "$HOME_DIR/Projects/scripts/vcv-rack.sh" "$HOME_DIR/.local/bin/vcv-rack"

chmod +x /home/tristen/.local/bin/reaper
chmod +x /home/tristen/.local/bin/vcv-rack
