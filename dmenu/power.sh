#!/bin/bash

# First menu
action=$(echo -e "Reboot\nShutdown\nExit" | dmenu -i -p "What would you like to do?")

# Function for confirmation
confirm() {
    response=$(echo -e "Yes\nNo" | dmenu -i -p "Are you sure?")
    [[ "$response" == "Yes" ]]
}

# Handle actions
case "$action" in
    "Reboot")
        if confirm; then
            systemctl reboot
        fi
        ;;
    "Shutdown")
        if confirm; then
            systemctl poweroff
        fi
        ;;
    "Exit")
        exit 0
        ;;
    *)
        exit 0
        ;;
esac
