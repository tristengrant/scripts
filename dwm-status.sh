#!/bin/sh

while true; do
    weather=$(~/Github/scripts/weather) # Run your weather script
    date=$(date '+%a %b %d %I:%M%p') # Get the current date
    xsetroot -name " $weather ¦ $date " # Update the DWM status bar
    sleep 60 # Update every minute
done
