#!/bin/bash

# Class name for identifying the kitty window
WIN_CLASS="music_scratchpad"

# Find window by class
WIN_ID=$(xdotool search --class "$WIN_CLASS" 2>/dev/null | head -n 1)

if [ -z "$WIN_ID" ]; then
  # If it's not running, start kitty with mocp
  kitty --class "$WIN_CLASS" --title "MOC Scratchpad" mocp &
  exit 0
fi

# Get currently focused window
FOCUSED_WIN=$(xdotool getwindowfocus)

# Is the mocp scratchpad currently focused?
if [ "$FOCUSED_WIN" = "$WIN_ID" ]; then
  # If focused, hide it
  bspc node "$WIN_ID" --flag hidden=on
else
  # If hidden or unfocused, show and focus it
  bspc node "$WIN_ID" --flag hidden=off
  bspc node "$WIN_ID" --to-monitor focused
  bspc node "$WIN_ID" --focus
fi
