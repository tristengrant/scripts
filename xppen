#!/bin/bash

# Define tablet name
TABLET_NAME="UGTABLET Deco Pro LW (Gen 2)"

# Define full device names
STYLUS="$TABLET_NAME Pen stylus"
ERASER="$TABLET_NAME Pen eraser"

# Set mapping to a specific monitor
xsetwacom set "$STYLUS" MapToOutput DisplayPort-1
xsetwacom set "$ERASER" MapToOutput DisplayPort-1

# Pen Buttons
#xsetwacom set "$STYLUS" Button 2 "key control" #Sample colour
#xsetwacom set "$STYLUS" Button 3 "button +2" #Middle click

# Set mode to relative (like a mouse) or absolute (like a pen)
#xsetwacom set "$STYLUS" Mode "Absolute"

# Sets if the stylus needs to touch the tablet for the pen's buttons to work
xsetwacom set "$STYLUS" TabletPCButton "off"

# Print confirmation
echo "Tablet settings applied for $TABLET_NAME"
