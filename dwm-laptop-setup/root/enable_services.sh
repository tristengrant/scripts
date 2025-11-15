#!/usr/bin/env bash
set -euo pipefail

echo "Enabling services..."
systemctl enable NetworkManager cups avahi-daemon acpid rtkit lightdm
