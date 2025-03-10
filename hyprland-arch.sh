#!/bin/bash

# Install paru if not installed
if ! command -v paru &>/dev/null; then
  echo "Installing paru..."

  # Install necessary dependencies for building paru
  pacman -S --needed --noconfirm git base-devel xf86-video-amdgpu
  
  # Clone the paru repository and build it
  if [ ! -d ~/paru-bin ]; then
    git clone https://aur.archlinux.org/paru-bin.git ~/paru-bin
  fi

  cd ~/paru-bin
  makepkg -si --noconfirm
  
  # Clean up the build directory after installation
  rm -rf ~/paru-bin
  
  # Check if paru was successfully installed
  if ! command -v paru &>/dev/null; then
    echo "paru installation failed, aborting AUR package installation."
    exit 1
  fi
else
  echo "Paru is already installed."
fi

# Install AUR packages
echo "Installing AUR packages..."
paru -S --noconfirm \
  vcvrack \
  bitwarden-bin \
  fzf-extras \
  zen-browser-bin \
  gruvbox-dark-gtk \
  tofi

# Install other packages from the repo
echo "Installing other packages..."
pacman -S --noconfirm \
  qt5-wayland \
  qt5-wayland \
  xdg-desktop-portal-hyprland \
  ly \
  reflector \
  wget \
  cronie \
  git \
  hyprland \
  hyprpicker \
  hyprcursor \
  hypridle \
  hyprlock \
  hyprpolkitagent \
  hyprgraphics \
  hyprutils \
  nwg-displays \
  hyprland-qtutils \
  waybar \
  openssh \
  kitty \
  tmux \
  p7zip \
  unrar \
  lrzip \
  trash-cli \
  udiskie \
  hyprctl \
  libinput \
  lib32-mesa \
  vulkan-radeon \
  lib32-vulkan-radeon \
  wl-clipboard \
  ydotool \
  libnotify \
  pipewire \
  pipewire-pulse \
  pipewire-jack \
  wireplumber \
  helvum \
  alsa-utils \
  realtime-privileges \
  rtirq \
  cups \
  nfs-utils \
  system-config-printer \
  glabels \
  bat \
  lsd \
  fzf \
  ripgrep \
  ripgrep-all \
  fd \
  jq \
  yq \
  tldr \
  shellcheck \
  htop \
  bmon \
  ncdu \
  duf \
  nmap \
  iperf3 \
  smartmontools \
  lazygit \
  vale \
  direnv \
  starship \
  lua \
  lua-language-server \
  hugo \
  go
  bottom \
  haskell-pandoc \
  libwacom \
  wlr-tablet \
  neovim \
  tree-sitter \
  xed \
  mako \
  wpaperd \
  wlr-randr \
  lxappearance \
  qt5ct \
  kvantum \
  grim \
  slurp \
  nsxiv \
  nnn \
  xdg-utils \
  xdg-user-dirs \
  xdg-desktop-portal-gtk \
  ffmpegthumbnailer \
  tumbler \
  file-roller \
  ffmpeg \
  imagemagick \
  libheif \
  libavif \
  webp-pixbuf-loader \
  mpv \
  mpd \
  mpc \
  mpd-mpris \
  ncmpcpp \
  seatd \
  thunar \
  thunar-archive-plugin \
  thunar-volman \
  thunar-media-tags-plugin \
  gvfs \
  gvfs-smb \
  smbclient \
  cifs-utils \
  obsidian \
  darktable
  reaper \
  reapack \
  sws \
  playerctl \
  syncthing \
  lynis \
  rkhunter \
  cyme \
  ttf-jetbrains-mono \
  ttf-font-awesome \
  noto-fonts-emoji \
  noise-suppression-for-voice \
  pdfgrep \
  sox \
  duperemove \
  shellharden \
  gparted \
  xournalpp \
  libgsf \
  libappimage \
  swh-plugins \
  lsp-plugins \
  zathura \
  hunspell \
  hunspell-en_ca \
  enchant \
  steam \
  extra/kimageformats \
  interception-tools \
  wtype \
  zoxide \

# Make directories as needed
echo "Creating necessary directories..."
mkdir -p /home/tristen/{Documents,Downloads,Pictures,Videos,Music,Templates,Github,Applications}

# Clone your git repository
echo "Cloning your dotfiles repository..."
cd /home/tristen/Github
git clone https://github.com/tristengrant/dotfiles.git
cd ~

# Clone your scripts repository
echo "Cloning your scripts repository..."
cd /home/tristen/Github
git clone https://github.com/tristengrant/scripts.git
chmod +x ~/Github/scripts
cd ~

# Clone your wallpapers repository
echo "Cloning your wallpapers repository..."
cd /home/tristen/Pictures
git clone https://github.com/tristengrant/wallpapers.git
cd ~

# Clone your github introduction repository
echo "Cloning your website repository..."
cd /home/tristen/Github
git clone https://github.com/tristengrant/tristengrant.git readme
cd ~

# Make sure your user owns the directories
# Check and change ownership for each directory
for dir in /home/tristen/Documents /home/tristen/Downloads /home/tristen/Pictures /home/tristen/Videos /home/tristen/Music /home/tristen/Templates /home/tristen/Github /home/tristen/Applications; do
  if [ -d "$dir" ]; then
    echo "Directory $dir exists, changing ownership..."
    chown -R tristen:tristen "$dir"
  else
    echo "Directory $dir does not exist, skipping..."
  fi
done

# Mount music folder
MOUNT_DIR="$HOME/Music"
FSTAB_ENTRY="192.168.2.221:/storage1/music $MOUNT_DIR nfs defaults,noatime 0 0"
[ ! -d "$MOUNT_DIR" ] && mkdir -p "$MOUNT_DIR"
grep -qF "$FSTAB_ENTRY" /etc/fstab || echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
sudo mount -a

# Create Hyprland .desktop file
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/hyprland.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

# Add user to groups
for grp in tty realtime video audio input; do
  sudo usermod -aG "$grp" "$USER"
done

# Define directories
APP_DIR="/home/tristen/Applications"
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$APP_DIR" "$DESKTOP_DIR"

# Get the latest version number from KDE's download page
LATEST_VERSION=$(curl -s https://download.kde.org/stable/krita/ | grep -oP '(?<=href=")[0-9]+\.[0-9]+\.[0-9]+(?=/")' | sort -V | tail -n1)

# Construct the download URL
APPIMAGE_URL="https://download.kde.org/stable/krita/${LATEST_VERSION}/krita-${LATEST_VERSION}-x86_64.appimage"

# Define file names
APPIMAGE_PATH="$APP_DIR/krita-${LATEST_VERSION}.appimage"
DESKTOP_ENTRY="$DESKTOP_DIR/krita.desktop"

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

echo "Krita $LATEST_VERSION installed successfully!"
echo "Run it with: $APPIMAGE_PATH or searching with your application menu."

# Enable Ly Login Manager without starting it
systemctl enable ly.service

# Reboot
echo "Installation completed. Please reboot..."
