#!/bin/bash
set -e

./01-system.sh
./02-user.sh
./03-suckless.sh
./04-apps.sh

echo "✅ Setup complete! Reboot or startx into DWM."
