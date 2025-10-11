#!/bin/bash

# Destination folder
DIR="$HOME/pictures/screenshots"
FILENAME="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

# Take screenshot of currently focused window
if scrot -u "$DIR/$FILENAME"; then
    notify-send "Screenshot Taken" "Saved window as $FILENAME"
else
    notify-send "Screenshot Failed" "Could not save window"
fi
