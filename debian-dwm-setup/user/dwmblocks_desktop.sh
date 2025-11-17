#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"
REPO_DIR="$HOME_DIR/Projects/suckless"

cd "$REPO_DIR/dwmblocks-async-desktop"
make
sudo make install
make clean

echo "Successfully built dwmblocks-async."
