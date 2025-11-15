#!/bin/bash
cd "$HOME/.opt/REAPER" || exit
# Launch REAPER with pw-jack
exec pw-jack ./reaper "$@"
