#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"

mkdir -p "$HOME_DIR/.config"

cat > "$HOME_DIR/.config/user-dirs.dirs" <<'EOF'
XDG_DESKTOP_DIR="/home/tristen"
XDG_DOCUMENTS_DIR="/home/tristen/Documents"
XDG_DOWNLOAD_DIR="/home/tristen/Downloads"
XDG_MUSIC_DIR="/home/tristen/Music"
XDG_PICTURES_DIR="/home/tristen/Pictures"
XDG_VIDEOS_DIR="/home/tristen/Videos"
XDG_TEMPLATES_DIR="/home/tristen/"
XDG_PUBLICSHARE_DIR="/home/tristen/"
EOF

echo "Making home directories..."
mkdir -p "$HOME_DIR/Documents"
mkdir -p "$HOME_DIR/Downloads"
mkdir -p "$HOME_DIR/Music"
mkdir -p "$HOME_DIR/Pictures"
mkdir -p "$HOME_DIR/Pictures/screenshots"
mkdir -p "$HOME_DIR/Videos"
mkdir -p "$HOME_DIR/Projects"
mkdir -p "$HOME_DIR/Applications"
mkdir -p "$HOME_DIR/.local/bin"
mkdir -p "$HOME_DIR/.local/share/applications"
mkdir -p "$HOME_DIR/.local/state"

echo "Cloning and symlinking dotfiles..."
cd "$HOME_DIR/Projects"
[ -d "$HOME_DIR/Projects/dotfiles" ] || git clone https://github.com/tristengrant/dotfiles.git

# In .config
ln -sf "$HOME_DIR/Projects/dotfiles/config/Thunar" "$HOME_DIR/.config/Thunar"
ln -sf "$HOME_DIR/Projects/dotfiles/config/picom" "$HOME_DIR/.config/picom"
ln -sf "$HOME_DIR/Projects/dotfiles/config/helix" "$HOME_DIR/.config/helix"
ln -sf "$HOME_DIR/Projects/dotfiles/config/kitty" "$HOME_DIR/.config/kitty"
ln -sf "$HOME_DIR/Projects/dotfiles/config/mpv" "$HOME_DIR/.config/mpv"
ln -sf "$HOME_DIR/Projects/dotfiles/config/qt5ct" "$HOME_DIR/.config/qt5ct"
ln -sf "$HOME_DIR/Projects/dotfiles/config/mpd" "$HOME_DIR/.config/mpd"

# In home directory
ln -sf "$HOME_DIR/Projects/dotfiles/dot_xinitrc" "$HOME_DIR/.xinitrc"
ln -sf "$HOME_DIR/Projects/dotfiles/dot_bashrc" "$HOME_DIR/.bashrc"
ln -sf "$HOME_DIR/Projects/dotfiles/dot_bash_aliases" "$HOME_DIR/.bash_aliases"
ln -sf "$HOME_DIR/Projects/dotfiles/dot_nanorc" "$HOME_DIR/.nanorc"
ln -sf "$HOME_DIR/Projects/dotfiles/dot_profile" "$HOME_DIR/.profile"
ln -sf "$HOME_DIR/Projects/dotfiles/dot_xprofile" "$HOME_DIR/.xprofile"

# In .local/share/applications
ln -sf "$HOME_DIR/Projects/dotfiles/local/share/application/qimgv.desktop" "$HOME_DIR/.local/share/applications/qimgv.desktop"
ln -sf "$HOME_DIR/Projects/dotfiles/local/share/applications/st.desktop" "$HOME_DIR/.local/share/applications/st.desktop"

source /home/tristen/.bashrc

chmod +x /home/tristen/.xinitrc
