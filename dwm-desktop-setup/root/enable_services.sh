#!/usr/bin/env bash
set -euo pipefail

echo "Enabling services..."
systemctl enable NetworkManager cups cups-browsed avahi-daemon acpid

echo "Adding persistent 1.1.1.1 fix for Helium..."

# Add the route immediately
ip route add 1.1.1.1/32 dev lo 2>/dev/null || true

# Create NetworkManager dispatcher script for persistence
cat <<'EOF' > /etc/NetworkManager/dispatcher.d/01-fix-1.1.1.1
#!/bin/bash
# Add route for Helium only if this interface is the default gateway
DEFAULT_IF=$(ip route | awk '/default/ {print $5}' | head -n1)
if [ "$2" = "up" ] && [ "$1" = "$DEFAULT_IF" ]; then
    ip route add 1.1.1.1/32 dev lo 2>/dev/null || true
fi
EOF

chmod +x /etc/NetworkManager/dispatcher.d/01-fix-1.1.1.1

echo "Persistent Helium 1.1.1.1 route installed."
