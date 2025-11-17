#!/usr/bin/env bash
set -euo pipefail

# Root-level tasks
sudo ./root/install_packages_desktop.sh
sudo ./root/create_groups.sh
sudo ./root/enable_services.sh

# User-level tasks
./user/dotfiles.sh
./user/scripts.sh
./user/apps_desktop.sh
./user/suckless.sh
./user/dwmblocks_desktop.sh
./user/theme.sh

sudo chown -R tristen:tristen /home/tristen/*

sudo sensors-detect

echo "Setup complete! Reboot the computer."
