#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Functions
require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "⚠️  This script must be run as root or with sudo."
        echo "Try: sudo $0"
        exit 1
    fi
}

install_pkg() {
    local pkg="$1"
    if ! dpkg -s "$pkg" &>/dev/null; then
        echo "📦 Installing $pkg..."
        apt-get install -y "$pkg"
    else
        echo "✅ $pkg already installed."
    fi
}

# Main
require_root

echo "🔄 Updating package lists..."
apt-get update -y

echo "⬆️ Upgrading existing packages..."
apt-get upgrade -y

# Base Utilities
echo "🧰 Installing essential system packages..."
BASE_PKGS=(
    curl
    wget
    git
    nano
    helix
    tmux
    htop
    build-essential
    ca-certificates
    software-properties-common
    unzip
    tar
    unar
    gzip
    kitty
    zip
    net-tools
    psmisc
    policykit-1
    lm-sensors
    npm
    picom
    python3
    python-is-python3
    zoxide
    zstd
    libwacom-common
    firefox-esr
    x11-xserver-utils
    xclip
    yt-dlp
    node-copy-paste
    fd-find
    xdotool
    brightnessctl
    brightness-udev
    xdg-utils
    smartmontools
    dictionaries-common
    hunspell
    hunspell-en-ca
    enchant-2
    adwaita-icon-theme
    adwaita-qt
    adwaita-qt6
    gvfs-common
    polkitd
    rtkit
    lxpolkit
)
for pkg in "${BASE_PKGS[@]}"; do install_pkg "$pkg"; done

# Display Server + DWM dependencies
echo "🪟 Installing Xorg and basic window system..."
DISPLAY_PKGS=(
    xorg
    xinit
    libx11-dev
    libxft-dev
    libxinerama-dev
    libxrandr-dev
    libx11-xcb-dev
    mesa-utils
    feh
    dunst
    udiskie
    arandr
    autorandr
)
for pkg in "${DISPLAY_PKGS[@]}"; do install_pkg "$pkg"; done

# PipeWire Audio Setup
echo "🎧 Installing PipeWire and audio tools..."
AUDIO_PKGS=(
    pipewire
    pipewire-audio
    pipewire-pulse
    pipewire-alsa
    pipewire-jack
    wireplumber
    alsa-utils
    pavucontrol
    lsp-plugins-vst3
    qpwgraph
)
for pkg in "${AUDIO_PKGS[@]}"; do install_pkg "$pkg"; done

# MPD / NCMPCPP Music Player
echo "🎵 Installing music playback tools..."
MUSIC_PKGS=(
    mpd
    mpc
    ncmpcpp
)
for pkg in "${MUSIC_PKGS[@]}"; do install_pkg "$pkg"; done

# Printing Support
echo "🖨️ Installing printer support..."
PRINT_PKGS=(
    cups
    printer-driver-all
    printer-driver-cups
    glabels
)
for pkg in "${PRINT_PKGS[@]}"; do install_pkg "$pkg"; done

# Printer / Network Printer Setup
echo "🖨️ Configuring CUPS for network printers..."

# Enable and start CUPS
systemctl enable cups
systemctl start cups

# Give the user a moment to make sure CUPS is running
sleep 2

# List detected printers
echo "🔍 Network printers detected:"
lpinfo -v | grep -i network || echo "No network printers detected yet."

# Attempt auto-add
PRINTER_URI=$(lpinfo -v | grep -i 'Brother HL-L2460DW' | awk '{print $2}')
if [[ -n "$PRINTER_URI" ]]; then
    lpadmin -p HL-L2460DW -E -v "$PRINTER_URI" -m everywhere
    echo "✅ Brother HL-L2460DW added automatically"
else
    echo "⚠️ HL-L2460DW not detected automatically. Add via http://localhost:631"
fi

# Fonts and Theming
echo "🖋️ Installing fonts and themes..."
FONT_PKGS=(
    fonts-dejavu
    fonts-noto
    fonts-noto-color-emoji
    fonts-liberation
    fonts-noto-mono
    fonts-noto-cjk
    fonts-jetbrains-mono
    fonts-font-awesome
    fonts-hack
    fonts-symbola
    qt5ct
    lxappearance
)
for pkg in "${FONT_PKGS[@]}"; do install_pkg "$pkg"; done

# Video Packages
echo "🖋️ Installing video packages..."
VIDEO_PKGS=(
    mpv
    ffmpeg
    imagemagick
    mpdris2
    mpv-mpris
    playerctl
)
for pkg in "${VIDEO_PKGS[@]}"; do install_pkg "$pkg"; done

# For steam
dpkg --add-architecture i386
apt-get update -y

# Misc Packages
echo "🖋️ Installing misc packages..."
MISC_PKGS=(
    okular
    qimgv
    samba-common
    rsync
    ripgrep
    flameshot
    suckless-tools
    thunar
    thunar-archive-plugin
    thunar-data
    thunar-font-manager
    thunar-volman
    tumbler
    fzf
    ffmpegthumbnailer
    gimp
    inkscape
    gnome-disk-utility
    meld
    peek
    filezilla
    scribus
    steam-installer
)
for pkg in "${MISC_PKGS[@]}"; do install_pkg "$pkg"; done

# Networking
echo "🌐 Installing network utilities..."
NET_PKGS=(
    network-manager
    network-manager-applet
    dnsutils
    openssh-client
    openssh-server
    sshfs
    smbclient
    syncthing
)
for pkg in "${NET_PKGS[@]}"; do install_pkg "$pkg"; done

systemctl enable NetworkManager

# Clean Up
echo "🧹 Cleaning up..."
apt-get autoremove -y
apt-get clean

echo "✅ Base Debian setup complete!"

echo "Adding user to the realtime group for audio performance."
usermod -aG realtime,video,audio,input,lp "$USER"

# Configure ~/.xinitrc
echo "Configuring ~/.xinitrc..."
cat > ~/.xinitrc <<EOF
# Set DPI (adjust as needed)
xrandr --dpi 96
autorandr --change

# Prevent screen blanking / DPMS
xset s off
xset -dpms
xset s noblank

# Load environment variables from ~/.profile
[ -f ~/.profile ] && source ~/.profile

# Load X resources (fonts, colors, cursor size)
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Set cursor theme and size before starting any apps
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

# Set default cursor fallback
xsetroot -cursor_name left_ptr

# Qt/GTK theming
export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORMTHEME=qt5ct

# Disable X11 bell
xset b off

# Ensure XDG user dirs exist
xdg-user-dirs-update

# Start background apps AFTER cursor/theme is set
lxpolkit &
feh --bg-fill --randomize ~/Pictures/wallpapers/* &
dunst &
udiskie &
syncthing --no-browser &
picom --experimental-backends -b &
slstatus &
nm-applet &

# XFCE helpers (Thunar integration + settings)
/usr/libexec/xfce4/xfconfd &
/usr/libexec/xfce4/xfsettingsd &

# Thunar daemon
thunar --daemon &

# Make sure ~/bin is in PATH
export PATH="$HOME/bin:$PATH"

# Start DWM
exec dwm
EOF

# Configure ~/.bashrc
echo "Configuring ~/.bashrc..."
cat > ~/.bashrc <<EOF
#
# ~/.bashrc
#

export QT_QPA_PLATFORMTHEME=qt5ct
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# DWM
alias dwm-patch='patch -p1 < '

# Git aliases
alias ga="git add ."
alias gp="git push"
alias gc="git commit -m"
alias gs="git status -sb"
alias gac="git add . && git commit -m"
alias pushit="git push"

# General
alias ls='ls --color=auto'
alias ll='ls -alFh'
alias c='clear'
alias cls="clear && ls"
alias cla="clear && ls -la"

# Directory
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias scripts='cd ~/Projects/scripts/'
alias dotfiles='cd ~/Projects/dotfiles/'
alias tgsite='cd ~/Projects/tristengrant-website/'
alias cbsrc='cd ~/Projects/catandbot-sources/'
alias cbsite='cd ~/Projects/catandbot-website/'
alias readme='cd ~/Projects/readme/'
alias suckless='cd ~/Projects/suckless/'

# File management
alias md='mkdir -p'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias hg='history | grep'

PS1='[\u@\h \W]\$ '

# LTEX configuration for Helix
export LTEX_CONFIG="$HOME/.config/helix/ltex-settings.json"

export PATH="$HOME/.local/bin:$HOME/Applications:$HOME/.local/ltex-ls-plus:$HOME/.cargo/bin:$PATH"
EOF

# Configure ~/.profile
echo "Configuring ~/.profile..."
cat > ~/.profile <<EOF
export XDG_SESSION_TYPE=x11
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
export GTK_THEME=adwaita-dark
export QT_QPA_PLATFORMTHEME=qt5ct
export _JAVA_AWT_WM_NONREPARENTING=1 # Fix Java apps in tiling WMs
export MOZ_ENABLE_WAYLAND=0 # Force Firefox to use X11 (if you switch to Wayland later, remove this)
export XDG_CURRENT_DESKTOP=Gnome
EOF

# Configure ~/.config/gtk-3.0/settings.ini
mkdir -p ~/.config/gtk-3.0
touch ~/.config/gtk-3.0/settings.ini

echo "Configuring ~/.config/gtk-3.0/settings.ini"
cat > ~/.config/gtk-3.0/settings.ini <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
gtk-icon-theme-name=adwaita-dark
gtk-cursor-theme-size=24
EOF

# Configure ~/.gtkrc-2.0
touch ~/.gtkrc-2.0

echo "Configuring ~/.gtkrc-2.0"
cat > ~/.gtkrc-2.0 <<EOF
gtk-icon-theme-name="adwaita-dark"
gtk-cursor-theme-size=24
EOF

# Set up Git
git config --global user.email "hello@tristengrant.com"
git config --global user.name "Tristen Grant"
git config --global credential.helper store

# Making home directories
mkdir ~/Applications
mkdir ~/Documents
mkdir ~/Downloads
mkdir ~/Music
mkdir ~/Pictures
mkdir -p ~/Pictures/screenshots
mkdir ~/Projects
mkdir ~/Videos

# Install patched DWM, dMenu and slStatus builds
echo "Cloning your suckless Github repo"
cd ~/Projects
[ -d ~/Projects/suckless ] || git clone https://github.com/tristengrant/suckless.git

echo "Installing DWM"
cd ~/Projects/suckless/desktop/dwm
make
make install
make clean
rm config.h

echo "Installing Dmenu"
cd ~/Projects/suckless/desktop/dmenu
make
make install
make clean
rm config.h

echo "Installing Slstatus"
cd ~/Projects/suckless/desktop/slstatus
make
make install
make clean
rm config.h

# Configure ~/.Xresources
echo "Configuring ~/.Xresources..."
cat > ~/.Xresources <<EOF
Xft.dpi: 96                    # Adjust for HiDPI (e.g., 120, 144)
Xft.antialias: true            # Enable font anti-aliasing
Xft.hinting: true              # Enable font hinting
Xft.rgba: rgb                  # Subpixel rendering (rgb, bgr, vrgb, vbgr)
Xft.hintstyle: hintslight      # Options: hintnone, hintslight, hintmedium, hintfull
Xft.lcdfilter: lcddefault      # Smoother fonts
Xcursor.size: 24
EOF

# Clone scripts repo
echo "Cloning your scripts Github repo..."
cd ~/Projects
[ -d ~/Projects/scripts ] || git clone https://github.com/tristengrant/scripts.git

# Clone dotfiless repo
echo "Cloning your dotfiles Github repo..."
cd ~/Projects
[ -d ~/Projects/dotfiles ] || git clone https://github.com/tristengrant/dotfiles.git

# Symlink dotfiles
echo "Symlinking dotfiles..."
mkdir -p ~/.config
ln -sf ~/Projects/dotfiles/helix ~/.config/helix
ln -sf ~/Projects/dotfiles/kitty ~/.config/kitty
ln -sf ~/Projects/dotfiles/mpv ~/.config/mpv
ln -sf ~/Projects/dotfiles/picom ~/.config/picom
ln -sf ~/Projects/dotfiles/qt5ct ~/.config/qt5ct
ln -sf ~/Projects/dotfiles/Thunar ~/.config/Thunar
ln -sf ~/Projects/dotfiles/xfce4 ~/.config/xfce4
ln -sf ~/Projects/dotfiles/dot_nanorc ~/.nanorc
ln -sf ~/Projects/dotfiles/mimeapps.list ~/.config
ln -sf ~/Projects/dotfiles/user-dirs.conf ~/.config
ln -sf ~/Projects/dotfiles/user-dirs.dirs ~/.config
ln -sf ~/Projects/dotfiles/user-dirs.locale ~/.config

# Symlink AppImage launch scripts
echo "Symlinking AppImage launch scripts to work in dmenu..."
mkdir -p ~/.local/bin
ln -sf ~/Projects/scripts/reaper.sh ~/.local/bin/reaper
ln -sf ~/Projects/scripts/vcv-rack.sh ~/.local/bin/vcv-rack
ln -sf ~/Projects/scripts/krita.sh ~/.local/bin/krita
ln -sf ~/Projects/scripts/bitwarden.sh ~/.local/bin/bitwarden
ln -sf ~/Projects/scripts/obsidian.sh ~/.local/bin/obsidian
chmod +x ~/.local/bin/reaper
chmod +x ~/.local/bin/vcv-rack
chmod +x ~/.local/bin/krita
chmod +x ~/.local/bin/bitwarden
chmod +x ~/.local/bin/obsidian

# Install NPM packages for coding
npm install -g prettier stylelint typescript typescript-language-server vscode-langservers-extracted bash-language-server ruff-lsp yaml-language-server

# Enable realtime audio limits
echo "Enabling realtime audio limits..."
cat > /etc/security/limits.d/audio.conf <<EOF
@audio   -  rtprio     95
@audio   -  memlock    unlimited
EOF

# Install Taplo TOML toolkit
curl -fsSL -o taplo.gz https://github.com/tamasfe/taplo/releases/latest/download/taplo-linux-x86_64.gz
gzip -d taplo.gz
sudo install -m 755 taplo /usr/local/bin/taplo
rm taplo taplo.gz

# Install marksman markdown assist
curl -fsSL -o marksman  https://github.com/artempyanykh/marksman/releases/latest/download/marksman-linux-x64
sudo install -m 755 marksman /usr/local/bin/marksman
rm marksman

# Install markdown-oxide
set -euo pipefail
IFS=$'\n\t'

echo "Installing markdown-oxide via cargo..."

# Ensure Rust toolchain
if ! command -v cargo >/dev/null; then
  echo "Rust not found. Installing rustup and toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Install markdown-oxide
cargo install --locked --git https://github.com/Feel-ix-343/markdown-oxide.git markdown-oxide

echo "markdown-oxide installed successfully."

#Install latest Krita AppImage
set -euo pipefail
IFS=$'\n\t'

# Destination directory
DEST_DIR="$HOME/Applications"
mkdir -p "$DEST_DIR"

# Base URL for Krita stable AppImage builds
BASE_URL="https://download.kde.org/stable/krita"

echo "Fetching latest Krita version number..."
version=$(curl -fsSL "$BASE_URL/" | \
  grep -Po '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' | \
  sort -V | tail -n1)

echo "Latest version: $version"

# Build download URL
file_name="krita-${version}-x86_64.AppImage"
url="${BASE_URL}/${version}/${file_name}"
echo "Downloading Krita AppImage from: $url"

# Download, rename, and make executable
tmpfile=$(mktemp)
curl -fsSL -o "$tmpfile" "$url"
mv "$tmpfile" "${DEST_DIR}/krita.appimage"
chmod +x "${DEST_DIR}/krita.appimage"

echo "Krita AppImage installed at ${DEST_DIR}/krita.appimage"

# Install latest Bitwarden AppImage
set -euo pipefail
IFS=$'\n\t'

DEST_DIR="$HOME/Applications"
mkdir -p "$DEST_DIR"

DOWNLOAD_URL="https://bitwarden.com/download/?app=desktop&platform=linux&variant=appimage"
TMPFILE=$(mktemp)

echo "Downloading Bitwarden AppImage..."
curl -fsSL -o "$TMPFILE" "$DOWNLOAD_URL"

DESTFILE="${DEST_DIR}/bitwarden.appimage"
mv "$TMPFILE" "$DESTFILE"
chmod +x "$DESTFILE"

echo "Bitwarden AppImage installed at $DESTFILE"

# Install latest Obsidian .deb Package
set -euo pipefail
IFS=$'\n\t'

OWNER="obsidianmd"
REPO="obsidian-releases"

# 1. Fetch latest tag via GitHub API
tag=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
       | grep -Po '"tag_name":\s*"\K[^"]+')
if [ -z "$tag" ]; then
  echo "❗ Could not fetch latest tag for ${OWNER}/${REPO}"
  exit 1
fi
echo "Latest version tag: $tag"

# 2. Construct the .deb asset name (usually obsidian_<version>_amd64.deb)
ver="${tag#v}"   # remove leading ‘v’ if present
asset="obsidian_${ver}_amd64.deb"
url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/${asset}"

echo "Download URL: $url"

# 3. Download the .deb
tmpfile=$(mktemp)
curl -fsSL -o "$tmpfile" "$url"

# 4. Install the .deb
sudo dpkg -i "$tmpfile" || sudo apt-get install -f -y

# 5. Clean up
rm -f "$tmpfile"

echo "✅ Obsidian version $ver installed."

# Install the latest Helium web browser AppImage
set -euo pipefail
IFS=$'\n\t'

OWNER="imputnet"
REPO="helium-linux"
DEST_DIR="$HOME/Applications"

mkdir -p "$DEST_DIR"

# 1. Get latest release info
tag=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
      | grep -Po '"tag_name":\s*"\K[^"]+')
if [ -z "$tag" ]; then
  echo "❗ Could not fetch latest release tag for ${OWNER}/${REPO}"
  exit 1
fi
echo "Latest version: $tag"

# 2. Find the asset name for linux x86_64 AppImage
asset=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
        | grep -Po '"name":\s*"\K[^"]+' \
        | grep -E 'x86_64.*\.AppImage$' \
        | head -n1)
if [ -z "$asset" ]; then
  echo "❗ Could not find a linux x86_64 .AppImage asset in release $tag"
  exit 1
fi
echo "Found asset: $asset"

# 3. Construct download URL
url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/${asset}"
echo "Downloading from: $url"

# 4. Download and install
tmpfile=$(mktemp)
curl -fsSL -o "$tmpfile" "$url"

mv "$tmpfile" "${DEST_DIR}/helium.appimage"
chmod +x "${DEST_DIR}/helium.appimage"

echo "Helium AppImage installed at ${DEST_DIR}/helium.appimage"

# Install the latest Yazi terminal file browser
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | tee /etc/apt/sources.list.d/debian.griffo.io.list
apt update
apt install yazi
echo "Installed Yazi"

# Install latest ltex-ls-plus
set -euo pipefail
IFS=$'\n\t'

OWNER="ltex-plus"
REPO="ltex-ls-plus"
DEST_DIR="$HOME/.local"
FINAL_NAME="ltex-ls-plus"

echo "Installing ${REPO} into ${DEST_DIR}/${FINAL_NAME}…"

# Create destination if missing
mkdir -p "$DEST_DIR"

# Get latest tag
tag=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
      | grep -Po '"tag_name":\s*"\K[^"]+')
if [ -z "$tag" ]; then
  echo "❗ Could not fetch latest tag for ${OWNER}/${REPO}"
  exit 1
fi
echo "Latest version: $tag"

# Find linux x64 tar.gz asset
asset=$(curl -fsSL "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" \
         | grep -Po '"name":\s*"\K[^"]+' \
         | grep -E 'linux.*x64.*\.tar\.gz$' \
         | head -n1)
if [ -z "$asset" ]; then
  echo "❗ Could not find linux x64 tar.gz asset for version $tag"
  exit 1
fi
echo "Found asset: $asset"

# Construct download URL
url="https://github.com/${OWNER}/${REPO}/releases/download/${tag}/${asset}"
echo "Download URL: $url"

# Download to temp file
tmpfile=$(mktemp)
curl -fsSL -o "$tmpfile" "$url"

# Extract directly into DEST_DIR
tmp_extract_dir=$(mktemp -d)
tar -xzvf "$tmpfile" -C "$tmp_extract_dir"

# Find the extracted folder
extracted=$(find "$tmp_extract_dir" -maxdepth 1 -type d -name "${REPO}-*" | head -n1)
if [ -z "$extracted" ]; then
  echo "❗ Could not determine extracted directory"
  exit 1
fi

# Remove old install if exists
rm -rf "${DEST_DIR}/${FINAL_NAME}"

# Move and rename
mv "$extracted" "${DEST_DIR}/${FINAL_NAME}"

# Clean up
rm -f "$tmpfile"
rm -rf "$tmp_extract_dir"

echo "Symlinking ltex-ls-plus bin to ~/.local/bin"
ln -sf ~/.local/ltex-ls-plus/bin/ltex-ls-plus ~/.local/bin

echo "Installed ${REPO} version $tag into ${DEST_DIR}/${FINAL_NAME}"

echo "Install latest WezTerm..."
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
chmod 644 /usr/share/keyrings/wezterm-fury.gpg
apt update
apt install wezterm
echo "WezTerm installed successfully..."

echo "Writing todo file in Downloads directory..."
cat > ~/Downloads/todo.txt <<EOF
Install:
Jellyfin Media Player - https://github.com/jellyfin/jellyfin-media-player/releases
Hugo - https://github.com/gohugoio/hugo/releases/
VCV Rack - https://vcvrack.com/Rack#get
Reaper - https://www.reaper.fm/download.php
EOF

echo
echo "Next steps:"
echo " - Build and install DWM (and related suckless tools)."
echo " - Manually install Krita, Reaper, and VCV Rack."
echo " - Reboot before starting your session."
