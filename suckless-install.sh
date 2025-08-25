#!/usr/bin/env bash
set -euo pipefail

# Base directory for your suckless source repos
BASE_DIR="$HOME/Github/dotfiles"

# Make sure the base dir exists
mkdir -p "$BASE_DIR"

echo "==> Installing suckless tools into $BASE_DIR"

# Function to clone, build, and install a suckless program
install_suckless() {
  local repo="$1"
  local name="$2"

  echo "==> Cloning $name..."
  git clone "https://git.suckless.org/$repo" "$BASE_DIR/$repo"

  echo "==> Building and installing $name..."
  cd "$BASE_DIR/$repo"
  sudo make clean install
}

install_suckless "dwm" "dwm (window manager)"
install_suckless "dmenu" "dmenu (launcher)"
install_suckless "slstatus" "slstatus (status bar)"

echo "==> All suckless tools installed successfully!"
