#!/bin/sh

while true; do
  if pgrep -x mpv >/dev/null || pgrep -x firefox >/dev/null || pgrep -x chromium >/dev/null; then
    xset s reset # Reset inactivity timer
  fi
  sleep 30 # Check every 30 seconds
done
