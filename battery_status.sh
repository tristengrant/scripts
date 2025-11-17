#!/bin/bash
# Outputs combined battery percentage and status for my ThinkPad's dual batteries

bats=(BAT0 BAT1)
total_capacity=0
total_percent=0
charging=0

for bat in "${bats[@]}"; do
    if [ -d "/sys/class/power_supply/$bat" ]; then
        cap=$(cat "/sys/class/power_supply/$bat/capacity")
        state=$(cat "/sys/class/power_supply/$bat/status")
        total_percent=$((total_percent + cap))
        total_capacity=$((total_capacity + 100))
        if [ "$state" = "Charging" ]; then
            charging=1
        fi
    fi
done

if [ $total_capacity -gt 0 ]; then
    percent=$((total_percent / (${#bats[@]})))
    if [ $charging -eq 1 ]; then
        echo "+BAT $percent%"
    else
        echo "-BAT $percent%"
    fi
else
    echo "BAT n/a"
fi
