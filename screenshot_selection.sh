#!/bin/bash

# Destination folder
DIR="$HOME/pictures/screenshots"
FILENAME="screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"

# Take screenshot of selection
if scrot -s "$DIR/$FILENAME"; then
    notify-send "Screenshot Taken" "Saved selection as $FILENAME"
else
    notify-send "Screenshot Failed" "Could not save selection"
fi
