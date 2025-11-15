#!/usr/bin/env bash
set -euo pipefail

USER="tristen"
HOME_DIR="/home/$USER"

echo "Making sure default directories are created..."
xdg-user-dirs-update

echo "Cloning and symlinking dotfiles..."
mkdir -p "$HOME_DIR/Projects"
mkdir -p ~/.local/share/applications

cd "$HOME_DIR/Projects"
[ -d "$HOME_DIR/Projects/dotfiles" ] || git clone https://github.com/tristengrant/dotfiles.git

# In .config
ln -sf "$HOME_DIR/Projects/dotfiles/config/Thunar" "$HOME_DIR/.config/Thunar"
ln -sf "$HOME_DIR/Projects/dotfiles/config/picom" "$HOME_DIR/.config/picom"
ln -sf "$HOME_DIR/Projects/dotfiles/config/helix" "$HOME_DIR/.config/helix"
ln -sf "$HOME_DIR/Projects/dotfiles/config/kitty" "$HOME_DIR/.config/kitty"
ln -sf "$HOME_DIR/Projects/dotfiles/config/mpv" "$HOME_DIR/.config/mpv"
ln -sf "$HOME_DIR/Projects/dotfiles/config/qt5ct" "$HOME_DIR/.config/qt5ct"

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
