#!/usr/bin/env bash
set -euo pipefail

# Root-level tasks
sudo ./root/install_packages_laptop.sh
sudo ./root/create_groups.sh
sudo ./root/enable_services.sh

# User-level tasks
./user/dotfiles.sh
./user/apps_laptop.sh
./user/suckless.sh
./user/dwmblocks_laptop.sh
./user/theme.sh

sudo chown -R tristen:tristen /home/tristen/*

echo "Setup complete! Reboot the computer."
