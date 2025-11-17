#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"

mkdir -p "$HOME_DIR/.config"

cat > "$HOME_DIR/.config/user-dirs.dirs" <<'EOF'
XDG_DESKTOP_DIR="/home/tristen"
XDG_DOCUMENTS_DIR="/home/tristen/documents"
XDG_DOWNLOAD_DIR="/home/tristen/downloads"
XDG_MUSIC_DIR="/home/tristen/music"
XDG_PICTURES_DIR="/home/tristen/pictures"
XDG_VIDEOS_DIR="/home/tristen/videos"
XDG_TEMPLATES_DIR="/home/tristen/"
XDG_PUBLICSHARE_DIR="/home/tristen/"
EOF

echo "Making home directories..."
mkdir -p "$HOME_DIR/documents"
mkdir -p "$HOME_DIR/downloads"
mkdir -p "$HOME_DIR/music"
mkdir -p "$HOME_DIR/pictures"
mkdir -p "$HOME_DIR/pictures/screenshots"
mkdir -p "$HOME_DIR/videos"
mkdir -p "$HOME_DIR/projects"
mkdir -p "$HOME_DIR/applications"
mkdir -p "$HOME_DIR/.local/bin"
mkdir -p "$HOME_DIR/.local/share/applications"
mkdir -p "$HOME_DIR/.local/state"

echo "Cloning and symlinking dotfiles..."
cd "$HOME_DIR/projects"
[ -d "$HOME_DIR/projects/dotfiles" ] || git clone https://github.com/tristengrant/dotfiles.git

# In .config
ln -sf "$HOME_DIR/projects/dotfiles/config/Thunar" "$HOME_DIR/.config/Thunar"
ln -sf "$HOME_DIR/projects/dotfiles/config/picom" "$HOME_DIR/.config/picom"
ln -sf "$HOME_DIR/projects/dotfiles/config/helix" "$HOME_DIR/.config/helix"
ln -sf "$HOME_DIR/projects/dotfiles/config/kitty" "$HOME_DIR/.config/kitty"
ln -sf "$HOME_DIR/projects/dotfiles/config/mpv" "$HOME_DIR/.config/mpv"
ln -sf "$HOME_DIR/projects/dotfiles/config/qt5ct" "$HOME_DIR/.config/qt5ct"
ln -sf "$HOME_DIR/projects/dotfiles/config/mpd" "$HOME_DIR/.config/mpd"

# In home directory
ln -sf "$HOME_DIR/projects/dotfiles/dot_xinitrc" "$HOME_DIR/.xinitrc"
ln -sf "$HOME_DIR/projects/dotfiles/dot_bashrc" "$HOME_DIR/.bashrc"
ln -sf "$HOME_DIR/projects/dotfiles/dot_bash_aliases" "$HOME_DIR/.bash_aliases"
ln -sf "$HOME_DIR/projects/dotfiles/dot_nanorc" "$HOME_DIR/.nanorc"
ln -sf "$HOME_DIR/projects/dotfiles/dot_profile" "$HOME_DIR/.profile"
ln -sf "$HOME_DIR/projects/dotfiles/dot_xprofile" "$HOME_DIR/.xprofile"

# In .local/share/applications
ln -sf "$HOME_DIR/projects/dotfiles/local/share/application/qimgv.desktop" "$HOME_DIR/.local/share/applications/qimgv.desktop"
ln -sf "$HOME_DIR/projects/dotfiles/local/share/applications/st.desktop" "$HOME_DIR/.local/share/applications/st.desktop"

source /home/tristen/.bashrc

chmod +x /home/tristen/.xinitrc
