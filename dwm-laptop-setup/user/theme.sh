#!/bin/bash
# DESC: Install Orchis Grey Dark GTK theme and Colloid Grey Dracula Dark icon theme (no install.sh)

set -euo pipefail

GTK_THEME="Orchis-Grey-Dark"
ICON_THEME="Colloid-Grey-Dracula-Dark"

THEME_DIR="/home/tristen/.themes"
ICON_DIR="/home/tristen/.icons"
TEMP_DIR="/tmp/theme_$$"

die() { echo "ERROR: $1" >&2; exit 1; }

trap "rm -rf $TEMP_DIR" EXIT

mkdir -p "$THEME_DIR" "$ICON_DIR" "$TEMP_DIR"

echo "Downloading themes..."
cd "$TEMP_DIR"

# GTK THEME (Orchis)
git clone -q https://github.com/vinceliuice/Orchis-theme || die "Failed to clone Orchis theme"

# The repo contains many variants — we only want:
# Orchis-Grey-Dark
if [ ! -d "Orchis-theme/src/$GTK_THEME" ]; then
    die "Expected GTK theme subfolder not found: Orchis-theme/src/$GTK_THEME"
fi

cp -r "Orchis-theme/src/$GTK_THEME" "$THEME_DIR/$GTK_THEME"
echo "Installed GTK theme → $THEME_DIR/$GTK_THEME"

# ICON THEME (Colloid)
git clone -q https://github.com/vinceliuice/Colloid-icon-theme || die "Failed to clone Colloid icon theme"

# Path inside repo:
# Colloid-icon-theme/themes/Colloid-Grey-Dracula-Dark
if [ ! -d "Colloid-icon-theme/themes/$ICON_THEME" ]; then
    die "Expected icon theme subfolder not found: Colloid-icon-theme/themes/$ICON_THEME"
fi

cp -r "Colloid-icon-theme/themes/$ICON_THEME" "$ICON_DIR/$ICON_THEME"
echo "Installed icon theme → $ICON_DIR/$ICON_THEME"

# VERIFY
[ ! -d "$THEME_DIR/$GTK_THEME" ] && die "GTK theme install failed"
[ ! -d "$ICON_DIR/$ICON_THEME" ] && die "Icon theme install failed"

# GTK CONFIG FILES

echo "Writing GTK configuration files..."

mkdir -p "/home/tristen/.config/gtk-3.0"

# GTK 3
cat > "/home/tristen/.config/gtk-3.0/settings.ini" <<EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

# GTK 2
cat > "/home/tristen/.gtkrc-2.0" <<EOF
gtk-theme-name="$GTK_THEME"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

echo "Done!"
echo "GTK + Icon themes installed and configured."

# Apply via gsettings (required for GTK3 applications)
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"

echo "Themes installed and applied successfully"
