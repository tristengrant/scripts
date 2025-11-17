#!/bin/bash
# Shows current MPD song in the format "Artist - Title"
# Truncates to 30 characters
# Shows "(paused) Artist - Title" if paused
# Shows nothing if MPD is not running

# Exit if MPD is not running
if ! pgrep mpd >/dev/null 2>&1; then
    echo ""
    exit 0
fi

# Get current song info
song=$(mpc current)
status=$(mpc status 2>/dev/null | head -n2 | tail -n1)

# Exit if nothing is playing
if [ -z "$song" ]; then
    echo ""
    exit 0
fi

# Prepend "(paused)" if song is paused
if echo "$status" | grep -q '\[paused\]'; then
    song="(paused) $song"
fi

# Truncate long titles
maxlen=30
if [ ${#song} -gt $maxlen ]; then
    song="${song:0:$maxlen}…"
fi

echo "$song"
