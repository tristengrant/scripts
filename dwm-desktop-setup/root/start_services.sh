#!/usr/bin/env bash
set -euo pipefail

echo "Starting services..."
systemctl start NetworkManager cups avahi-daemon acpid rtkit lightdm
