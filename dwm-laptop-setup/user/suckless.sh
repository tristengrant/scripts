#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"
REPO_DIR="$HOME_DIR/Projects/suckless"

echo "Preparing Suckless build environment…"

mkdir -p "$HOME_DIR/Projects"

# Clone or update repo
if [ ! -d "$REPO_DIR" ]; then
    echo "Cloning Suckless software repo..."
    git clone https://github.com/tristengrant/suckless.git "$REPO_DIR"
else
    echo "Suckless repo exists, pulling latest changes..."
    cd "$REPO_DIR"
    git pull --rebase
fi

build_component() {
    local COMP_NAME=$1
    local COMP_DIR="$REPO_DIR/laptop/$COMP_NAME"

    echo "Building $COMP_NAME…"

    cd "$COMP_DIR"

    # Always remove old config.h so changes in config.def.h apply
    [ -f config.h ] && rm config.h

    make
    sudo make install
    make clean

    echo "$COMP_NAME built and installed."
}

build_component "dwm"
build_component "st"
build_component "dmenu"
build_component "slock"
build_component "slstatus"

echo "All suckless software built and installed successfully."
