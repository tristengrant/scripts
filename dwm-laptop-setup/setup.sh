#!/usr/bin/env bash
set -euo pipefail

# Root-level tasks
sudo ./root/install_packages.sh
sudo ./root/create_groups.sh
sudo ./root/enable_services.sh

# User-level tasks (hardcoded user)
./user/dotfiles.sh
./user/apps.sh
./user/suckless.sh
./user/theme.sh

# Starting services
#sudo ./root/start_services.sh || echo "Some services failed to start, but continuing..."

echo "Setup complete! Log out and select 'DWM' from your display manager."
