#!/bin/sh
feh --bg-fill --randomize ~/Pictures/wallpapers/* &
slstatus &
dunst &
nm-applet &
udiskie &
syncthing --no-browser &

# XFCE helpers
/usr/libexec/xfce4/xfconfd &
/usr/libexec/xfce4/xfsettingsd &
thunar --daemon &

# Keyring
eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)"
export SSH_AUTH_SOCK
