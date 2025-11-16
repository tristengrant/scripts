#!/usr/bin/env bash
set -euo pipefail

echo "Enabling services..."
systemctl enable NetworkManager cups cups-browsed avahi-daemon acpid lightdm
