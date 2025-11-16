#!/usr/bin/env bash
set -euo pipefail

echo "Starting services..."
systemctl start --no-block  NetworkManager cups cups-browsed avahi-daemon acpid lightdm
