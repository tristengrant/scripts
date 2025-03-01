#!/bin/sh

# set monitor settings
xrandr --output DisplayPort-1 --mode 2560x1440 --pos 1200x480 --rotate normal --output DisplayPort-2 --mode 1920x1200 --pos 0x0 --rotate left

feh --bg-fill --randomize ~/Pictures/wallpapers/* &
dwmblocks &
dunst &
udiskie &
syncthing --no-browser &
picom --experimental-backends -b
#/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
clipster -d 2>/dev/null &

while true; do
	# Log stderror to a file
	dwm 2> ~/.dwm.log
done
