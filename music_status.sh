#!/bin/bash

status=$(mocp -Q %state 2>/dev/null)

if [ "$status" = "STOP" ] || [ -z "$status" ]; then
  echo ""
  exit 0
fi

artist=$(mocp -Q %artist 2>/dev/null)
song=$(mocp -Q %song 2>/dev/null)

# Set different output for playing vs paused
if [ "$status" = "PAUSE" ]; then
  echo "%{F#f9c74f}⏸ $artist - $song%{F-}"
else
  echo "%{F#90be6d}▶ $artist - $song%{F-}"
fi
