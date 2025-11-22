#!/bin/bash

SINK="@DEFAULT_AUDIO_SINK@"
NOTIFY_ID=4242   # constant notification ID
STEP=0.05        # volume step (5%)

# Get current volume (float, e.g., 0.147)
CUR_VOLUME=$(wpctl get-volume "$SINK" | grep -o '[0-9]\+\.[0-9]\+')

case "$1" in
    up)
        NEW_VOLUME=$(awk "BEGIN{v=$CUR_VOLUME+$STEP; if(v>1.0) v=1.0; print v}")
        wpctl set-volume "$SINK" "$NEW_VOLUME" >/dev/null
        ;;
    down)
        NEW_VOLUME=$(awk "BEGIN{v=$CUR_VOLUME-$STEP; if(v<0) v=0; print v}")
        wpctl set-volume "$SINK" "$NEW_VOLUME" >/dev/null
        ;;
    mute)
        wpctl set-mute "$SINK" toggle >/dev/null
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac

STATUS="$(wpctl get-volume "$SINK")"

# Detect mute
if echo "$STATUS" | grep -qi "muted"; then
    notify-send -r "$NOTIFY_ID" "Volume: muted"
    exit 0
fi

# Convert to integer percentage
RAW_VOLUME=$(echo "$STATUS" | grep -o '[0-9]\+\.[0-9]\+')
VOLUME=$(awk "BEGIN {v=$RAW_VOLUME*100; if(v>100) v=100; printf \"%d\", v}")

notify-send -r "$NOTIFY_ID" "Volume: ${VOLUME}%"
