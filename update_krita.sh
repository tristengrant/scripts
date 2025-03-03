#!/bin/bash

set -e # Exit on error

# Define directories
APP_DIR="$HOME/Applications"
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR" "$DESKTOP_DIR"

# Get the latest version number from KDE's download page
LATEST_VERSION=$(curl -s https://download.kde.org/stable/krita/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' | sort -V | tail -n1)

# Construct the download URL
APPIMAGE_URL="https://download.kde.org/stable/krita/${LATEST_VERSION}/krita-${LATEST_VERSION}-x86_64.appimage"

# Define file names
APPIMAGE_PATH="$APP_DIR/krita-${LATEST_VERSION}.appimage"
DESKTOP_ENTRY="$DESKTOP_DIR/krita.desktop"

# Remove old Krita AppImages
echo "Removing old Krita AppImages..."
rm -f "$APP_DIR"/krita-*.appimage

# Download the latest Krita AppImage
echo "Downloading Krita $LATEST_VERSION..."
wget -q --show-progress -O "$APPIMAGE_PATH" "$APPIMAGE_URL"

# Make it executable
chmod +x "$APPIMAGE_PATH"

# Create a desktop entry for Krita
echo "Creating Krita desktop entry..."
cat >"$DESKTOP_ENTRY" <<EOF
[Desktop Entry]
Name=Krita
Exec=$APPIMAGE_PATH
Icon=krita
Terminal=false
Type=Application
Categories=Graphics;
EOF

chmod +x "$DESKTOP_ENTRY"

# Force update the desktop menu to ensure Krita appears
echo "Updating desktop menu..."
xdg-desktop-menu forceupdate

echo "Krita $LATEST_VERSION installed successfully!"
echo "Run it with: $APPIMAGE_PATH or searching with your application menu."
