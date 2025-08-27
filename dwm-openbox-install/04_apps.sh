#!/bin/bash
# 01_packages.sh
# Installs essential packages, daemons, and recommended tools for a minimal DWM Debian system

set -e

echo "🔧 Updating system and installing base packages..."
sudo apt update && sudo apt upgrade -y

# -------------------------------
# Essential system daemons/services
# -------------------------------
sudo apt install -y \
  sudo \
  build-essential git curl wget unzip xclip \
  dbus zip p7zip-full unrar network-manager network-manager-gnome \
  cups system-config-printer cups-browsed \
  pipewire pipewire-pulse wireplumber pavucontrol pasystray qpwgraph \
  acpi acpid aspell aspell-en \
  udev alsa-utils xdg-user-dirs \
  gnome-keyring libpam-gnome-keyring \
  isomd5sum genisoimage

# -------------------------------
# Opensbox as a backup WM
# -------------------------------
sudo apt install -y \
  openbox obconf tint2 lxterminal x11-xserver-utils

# -------------------------------
# suckless-tools Debian repo as default starting point
# -------------------------------
sudo apt install -y \
  dwm dmenu slstatus suckless-tools

# -------------------------------
# Recommended DWM tools / utilities
# -------------------------------
sudo apt install -y \
  dunst \
  feh \
  nsxiv mpv \
  thunar thunar-volman thunar-archive-plugin gvfs gvfs-backends \
  zathura zathura-pdf-poppler \
  neovim ripgrep fd-find fzf lf mc tmux alacritty \
  qutebrowser firefox-esr \
  htop acpi ffmpeg maim or scrot pandoc qalculate-gtk \
  fonts-jetbrains-mono fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
  papirus-icon-theme

# -------------------------------
# Additional software
# -------------------------------
sudo apt install -y \
  inkscape gimp geany mousepad

# -------------------------------
# For main PC
# -------------------------------
sudo apt install -y \
  glabels

# -------------------------------
# For the laptop
# -------------------------------
sudo apt install -y \
  xfce4-power-manager brightnessctl \
  tlp tlp-rdw avahi-daemon bluetooth blueman

# -------------------------------
# Optional / skippable packages
# -------------------------------
# sudo apt install -y bluetooth blueman   # Skip if no Bluetooth devices
# sudo apt install -y seahorse            # GUI keyring manager (optional)
# sudo apt install -y cron anacron        # For scheduled tasks (optional)
# sudo apt install -y avahi-daemon        # Network discovery / Bonjour (optional)

echo "✅ Essential packages and recommended tools installed."
echo "💡 Optional packages are listed in comments; uncomment to install if needed."

# -------------------------------
# User home directories
# -------------------------------
# 1. make sure confg directory exists
mkdir -p "$HOME/.config"

# 2. create directories in home
mkdir - p "$HOME/github" \
  "$HOME/videos" \
  "$HOME/pictures" \
  "$HOME/downloads" \
  "$HOME/projects" \
  "$HOME/documents" \
  "$HOME/applications" \
  "$HOME/projects/web" \
  "$HOME/projects/comics" \
  "$HOME/projects/illustration" \
  "$HOME/projects/music"

# 3. write the xdg-user-dirs configuration
cat >"$HOME/.config/user-dirs.dirs" <<'EOF'
# Minimal XDG user directories for a tiling/window-manager setup
XDG_DESKTOP_DIR="$HOME"           # no desktop folder
XDG_DOCUMENTS_DIR="$HOME/documents"
XDG_DOWNLOAD_DIR="$HOME/downloads"
# XDG_MUSIC_DIR="$HOME/music"
XDG_PICTURES_DIR="$HOME/pictures"
XDG_VIDEOS_DIR="$HOME/videos"
# XDG_TEMPLATES_DIR="$HOME/templates"
# XDG_PUBLICSHARE_DIR="$HOME/public"  # optional, create if needed
EOF

# Optional: refresh XDG dirs cache if the utility is installed
if command -v xdg-user-dirs-update >/dev/null 2>&1; then
  xdg-user-dirs-update
fi
