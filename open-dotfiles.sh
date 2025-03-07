#!/bin/sh

TERMINAL="${TERMINAL:-kitty}" # Uses $TERMINAL, defaults to 'kitty'

selection="$(ls -1 ~/Github/dotfiles | dmenu -i -p "Select a dotfile to open:")"

[ -z "$selection" ] && exit 1 # Exit if no selection

if [ -d "$HOME/Github/dotfiles/$selection" ]; then
  thunar "$HOME/Github/dotfiles/$selection"
else
  "$TERMINAL" -e nvim "$HOME/Github/dotfiles/$selection"
fi
