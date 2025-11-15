#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
GROUPS=(realtime video audio input lp)

# Create groups if they don't exist
for grp in "${GROUPS[@]}"; do
    if ! getent group "$grp" >/dev/null; then
        echo "Creating group $grp..."
        groupadd "$grp"
    fi
done

# Add user to groups
echo "Adding $USER to groups..."
usermod -aG "${GROUPS[*]}" "$USER"

# Configure real-time audio limits
LIMITS_FILE="/etc/security/limits.d/99-realtime.conf"
if [ ! -f "$LIMITS_FILE" ]; then
    echo "Creating $LIMITS_FILE to configure real-time audio limits..."
    cat <<EOF > "$LIMITS_FILE"
# Real-time audio permissions for PipeWire/JACK
@audio   -  rtprio     95
@audio   -  memlock    unlimited
@audio   -  nice      -10
EOF
    echo "Real-time limits configured in $LIMITS_FILE."
else
    echo "$LIMITS_FILE already exists. Skipping."
fi

# Enable PipeWire services for the user
echo "Enabling PipeWire services for $USER..."
sudo -u "$USER" systemctl --user enable pipewire pipewire-pulse wireplumber
sudo -u "$USER" systemctl --user start pipewire pipewire-pulse wireplumber

# Verify PipeWire services are running
echo "Verifying PipeWire services..."
for svc in pipewire pipewire-pulse wireplumber; do
    if sudo -u "$USER" systemctl --user is-active --quiet "$svc"; then
        echo "$svc is running"
    else
        echo "$svc is not running"
    fi
done

echo "Setup complete. Log out and back in for group changes and user services to take effect."
