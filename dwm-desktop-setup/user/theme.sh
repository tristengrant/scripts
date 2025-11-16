#!/bin/bash
# DESC: Install Orchis Grey Dark GTK theme and Colloid Grey Dracula Dark icon theme using their install.sh scripts

set -euo pipefail

GTK_THEME="Orchis-Grey-Dark"
ICON_THEME="Colloid-Grey-Dracula-Dark"

THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
TEMP_DIR="/tmp/theme_$$"

die() { echo "ERROR: $1" >&2; exit 1; }
trap "rm -rf $TEMP_DIR" EXIT

mkdir -p "$THEME_DIR" "$ICON_DIR" "$TEMP_DIR"
cd "$TEMP_DIR"

echo "Cloning themes..."

# GTK THEME (Orchis)
git clone -q https://github.com/vinceliuice/Orchis-theme || die "Failed to clone Orchis theme"
cd Orchis-theme
# Run install.sh with options for Grey + Dark
./install.sh -c dark -t grey -d /home/tristen/.themes || die "Orchis theme installation failed"
cd "$TEMP_DIR"

# ICON THEME (Colloid)
git clone -q https://github.com/vinceliuice/Colloid-icon-theme || die "Failed to clone Colloid icon theme"
cd Colloid-icon-theme
# Run install.sh with options for Grey + Dracula + Dark
./install.sh -t grey -s dracula -d /home/tristen/.icons || die "Colloid icon theme installation failed"
cd "$TEMP_DIR"

echo "GTK and icon themes installed via install.sh!"

# GTK CONFIG FILES
echo "Writing GTK configuration files..."

mkdir -p "$HOME/.config/gtk-3.0"

# GTK 3
cat > "$HOME/.config/gtk-3.0/settings.ini" <<EOF
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
cat > "$HOME/.gtkrc-2.0" <<EOF
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

# Apply via gsettings (GTK3 applications)
#gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
#gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"

echo "Themes installed and applied successfully"
