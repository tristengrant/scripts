#!/bin/bash

options="Shutdown\nReboot\nLogout\nSuspend\nCancel"
chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu:")

confirm() {
  echo -e "No\nYes" | rofi -dmenu -p "Are you sure?"
}

case "$chosen" in
Shutdown)
  [ "$(confirm)" == "Yes" ] && systemctl poweroff
  ;;
Reboot)
  [ "$(confirm)" == "Yes" ] && systemctl reboot
  ;;
Logout)
  [ "$(confirm)" == "Yes" ] && bspc quit
  ;;
Suspend)
  [ "$(confirm)" == "Yes" ] && systemctl suspend
  ;;
esac
