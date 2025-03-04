#!/bin/bash

# Define tablet name
TABLET_NAME="Wacom Intuos Pro M"

# Define full device names
STYLUS="$TABLET_NAME Pen stylus"
PAD="$TABLET_NAME Pad pad"
TOUCH="$TABLET_NAME Finger touch"
ERASER="$TABLET_NAME Pen eraser"
CURSOR="$TABLET_NAME Pen cursor"

# Set mapping to a specific monitor
xsetwacom set "$STYLUS" MapToOutput DisplayPort-1
xsetwacom set "$ERASER" MapToOutput DisplayPort-1
xsetwacom set "$CURSOR" MapToOutput DisplayPort-1
xsetwacom set "$TOUCH" MapToOutput DisplayPort-1
xsetwacom set "$PAD" MapToOutput DisplayPort-1

# Turn tablet's touch settings off
xsetwacom set "$TOUCH" Touch "off"

# Rotate tablet for left-handed use
xsetwacom set "$STYLUS" Rotate "half"

# Pen Buttons
xsetwacom set "$STYLUS" Button 1 "" # Pen tip LEAVE ALONE
xsetwacom set "$STYLUS" Button 2 "button 3"
xsetwacom set "$STYLUS" Button 3 "button 3" # Color/Brush Selector

# Tablet Buttons
xsetwacom set "$PAD" Button 1 "button 3" #

# Adjust pressure curve
xsetwacom set "$STYLUS" PressureCurve 0 50 100 100

# Print confirmation
echo "Tablet settings applied for $TABLET_NAME"
