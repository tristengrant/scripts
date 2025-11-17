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

# Enable lingering so user services start even without login
echo "Enabling user lingering for $USER..."
loginctl enable-linger "$USER"

echo ""
echo "Done!"
echo "IMPORTANT: Log out and back in to activate new groups."
echo "PipeWire services will auto-start at login."
