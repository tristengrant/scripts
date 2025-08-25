#!/usr/bin/env bash
set -e

# Install xmobar build dependencies
sudo apt update
sudo apt install -y curl git libxft-dev libxinerama-dev libxrandr-dev libiw-dev

# Install stack (official binary installer)
if ! command -v stack >/dev/null 2>&1; then
  echo "Installing Haskell Stack..."
  curl -sSL https://get.haskellstack.org/ | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# Clone xmobar source
if [ ! -d xmobar ]; then
  git clone https://github.com/jaor/xmobar
fi

cd xmobar

# Initialize stack project if needed
if [ ! -f stack.yaml ]; then
  stack init
fi

# Build and install xmobar with full feature set
stack install \
  --flag xmobar:with_xft \
  --flag xmobar:with_inotify \
  --flag xmobar:all_extensions

echo
echo "✅ Xmobar build complete!"
echo "Binary installed at: $HOME/.local/bin/xmobar"
echo "Make sure ~/.local/bin is in your PATH."
