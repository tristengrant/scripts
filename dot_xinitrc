#!/bin/sh
# ~/.xinitrc

HOSTNAME=$(hostname)

# Keyring
eval "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)"
export SSH_AUTH_SOCK

# Compositor
picom &

# Wallpapers and extras per host
case "$HOSTNAME" in
laptop)
  feh --randomize --bg-fill ~/Pictures/wallpapers/* &
  nm-applet &
  pasystray &
  #setxkbmap -option ctrl:nocaps
  ;;
office)
  feh --randomize --bg-fill ~/Pictures/wallpapers/* &
  pasystray &
  #setxkbmap -option caps:escape
  ;;
*)
  pasystray &
  ;;
esac

# Notifications
dunst &

# Status bar
slstatus &

# Merge Xresources if present
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# Finally, start dwm
exec dwm
