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
xsetwacom set "$STYLUS" Button 2 "key control" #Sample colour
xsetwacom set "$STYLUS" Button 3 "button +2" #Middle click

# Tablet Buttons
xsetwacom set "$PAD" Button 13 "key e" #Eraser Tool
xsetwacom set "$PAD" Button 12 "key b" #Brush Tool
xsetwacom set "$PAD" Button 11 "key ctrl alt shift s" #Freehand Selection
xsetwacom set "$PAD" Button 10 "key ctrl alt shift r" #Reload Brush Preset
xsetwacom set "$PAD" Button 1 "key shift o" #Color Popup (Circle button)
xsetwacom set "$PAD" Button 9 "key shift" #Shift
xsetwacom set "$PAD" Button 8 "key ctrl alt shift v" #Toggle layer visibility
xsetwacom set "$PAD" Button 3 "key ctrl t" #Transform
xsetwacom set "$PAD" Button 2 "key ctrl shift a" #Deselect

# Set mode to relative (like a mouse) or absolute (like a pen)
xsetwacom set "$STYLUS" Mode "Absolute"
xsetwacom set "$CURSOR" Mode "Relative"

# Sets if the stylus needs to touch the tablet for the pen's buttons to work
xsetwacom set "$STYLUS" TabletPCButton "off"

# Sets direction of the touch wheel
xsetwacom set "$PAD" AbsWheelUp "key minus"
xsetwacom set "$PAD" AbsWheelDown "key plus"

# Print confirmation
echo "Tablet settings applied for $TABLET_NAME"
