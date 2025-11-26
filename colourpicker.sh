#!/bin/sh
# colourpicker.sh — click-anywhere color picker (X11, works with older xdotool)

# Requirements: xdotool imagemagick xclip notify-send

# Let the user know to click
notify-send "Colour Picker" "Click the pixel you want to pick"

# Wait for the user to click a window (blocks until you click)
# returns a window id string — DO NOT eval it
win=$(xdotool selectwindow) || exit 1

# Now read the mouse location at that moment (outputs X= Y= SCREEN=)
eval "$(xdotool getmouselocation --shell)"

# Use ImageMagick to grab the 1x1 pixel at X,Y from the root window
color=$(import -silent -window root -crop 1x1+${X}+${Y} txt:- \
        | grep -oE '#[A-Fa-f0-9]{6}' | tr '[:upper:]' '[:lower:]')

# If no color found, exit with a message
if [ -z "$color" ]; then
  notify-send "Colour Picker" "Failed to pick color at ${X},${Y}"
  printf "Error: no color captured at %s,%s\n" "$X" "$Y" >&2
  exit 2
fi

# Copy to clipboard and notify
printf "%s" "$color" | xclip -selection clipboard
notify-send "Color Picked" "${color} copied to clipboard"
printf "%s\n" "$color"

