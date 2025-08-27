#!/bin/bash
set -e

# Create a nice file structure
mkdir -p ~/Projects ~/Pictures/wallpapers ~/Music ~/Documents ~/Downloads \
  ~/.config/nvim ~/.local/bin

# Clone your dotfiles repo
if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/yourname/dotfiles.git ~/dotfiles
fi

# Symlink configs
ln -sf ~/dotfiles/nvim ~/.config/nvim
ln -sf ~/dotfiles/dwm ~/.config/dwm
ln -sf ~/dotfiles/.bashrc ~/.bashrc

echo "✅ User environment ready."
