#!/bin/sh

TERMINAL="${TERMINAL:-kitty}" # Uses $TERMINAL, defaults to 'kitty'

selection="$(ls -1 ~/Scripts | dmenu -i -p "Select a script to open:")"

[ -z "$selection" ] && exit 1 # Exit if no selection

if [ -d "$HOME/Scripts/$selection" ]; then
  thunar "$HOME/Scripts/$selection"
else
  "$TERMINAL" -e nvim "$HOME/Scripts/$selection"
fi
