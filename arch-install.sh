#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status

# Ensure the script is run as a normal user with sudo privileges
if [[ $EUID -eq 0 ]]; then
  echo "Please do not run this script as root. Run it as a normal user with sudo privileges."
  exit 1
fi

# Function to install paru if not installed
install_paru() {
  if ! command -v paru &>/dev/null; then
    echo "Installing paru..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/paru-bin.git ~/paru-bin
    cd ~/paru-bin && makepkg -si --noconfirm
    cd ~ && rm -rf ~/paru-bin

    # Check again to confirm installation
    if command -v paru &>/dev/null; then
      echo "Paru has been successfully installed."
    else
      echo "Error: Paru installation failed. Please check the logs and install it manually."
      exit 1
    fi

  else
    echo "paru is already installed."
  fi
}

# Install paru
install_paru

# Create necessary directories
mkdir -p ~/Applications ~/Github ~/Documents ~/Music ~/Pictures/{screenshots} ~/Videos

# Set up AMD GPU Conf file
sudo mkdir -p /etc/X11/xorg.conf.d/
sudo chmod 755 /etc/X11/xorg.conf.d/

# Create the file with root privileges and set the content
sudo tee /etc/X11/xorg.conf.d/20-amdgpu.conf >/dev/null <<EOF
Section "Device"
	Identifier "AMD Graphics"
	Driver "amdgpu"
	Option "TearFree" "true"
	Option "DRI" "3"
	Option "AccelMethod" "glamor"
EndSection
EOF

# List of packages to install from the official repositories
PACKAGES=(
  networkmanager
  network-manager-applet
  reflector
  wget
  git
  openssh
  tmux
  p7zip
  unrar
  lrzip
  trash-cli
  udiskie
  xorg-server
  xorg-xinit
  xorg-xrandr
  xorg-xsetroot
  xorg-xinput
  xorg-xprop
  xorg-xev
  xorg-xwininfo
  xorg-xdpyinfo
  xorg-xrdb
  lib32-mesa
  vulkan-radeon
  lib32-vulkan-radeon
  xclip
  xdotool
  libnotify
  pipewire
  pipewire-pulse
  pipewire-jack
  wireplumber
  helvum
  pamixer
  pavucontrol
  alsa-utils
  alsa-plugins
  realtime-privileges
  rtirq
  cups
  nfs-utils
  system-config-printer
  glabels
  bat
  lsd
  fzf
  ripgrep
  ripgrep-all
  fd
  jq
  yq
  shellcheck
  htop
  bmon
  ncdu
  duf
  nmap
  iperf3
  smartmontools
  lazygit
  vale
  direnv
  starship
  lua
  lua-language-server
  hugo
  sassc
  go
  nodejs
  bottom
  pnpm
  haskell-pandoc
  libwacom
  xf86-input-wacom
  neovim
  tree-sitter
  kitty
  xed
  dunst
  feh
  sxhkd
  arandr
  lxappearance
  qt5ct
  kvantum
  polkit-gnome
  clipmenu
  satty
  sxiv
  ranger
  ueberzug
  xdg-utils
  xdg-user-dirs
  xdg-desktop-portal-gtk
  brightnessctl
  flatpak
  ffmpegthumbnailer
  tumbler
  file-roller
  ffmpeg
  imagemagick
  libheif
  libavif
  webp-pixbuf-loader
  mpv
  mpd
  mpc
  mpd-mpris
  ncmpcpp
  unclutter
  thunar
  thunar-archive-plugin
  thunar-volman
  thunar-media-tags-plugin
  thunar-shares-plugin
  gvfs
  gvfs-smb
  smbclient
  cifs-utils
  firefox
  obsidian
  darktable
  reaper
  reapack
  sws
  playerctl
  syncthing
  lynis
  rkhunter
  cyme
  ttf-jetbrains-mono
  ttf-nerd-fonts-symbols
  noto-fonts-emoji
  noise-suppression-for-voice
  pdfgrep
  sox
  duperemove
  shellharden
  gparted
  xournalpp
  libgsf
  libappimage
  swh-plugins
  lsp-plugins
  gcolor3
  zathura
  hunspell
  hunspell-en_ca
  enchant
  steam
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)

# List of packages to install from the AUR
AUR_PACKAGES=(
  vcvrack
  #bitwarden-bin
  clipster
  xdg-ninja
  z.lua
  fzf-extras
  fzf-tab-git
  gruvbox-material-gtk-theme-git
  gruvbox-material-icon-theme-git
  xcursor-simp1e-gruvbox-dark
  kimageformats
  flatseal
  tiger
  chkrootkit
  xremap-x11-bin
)

# Install official packages
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Install AUR packages using paru
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

for pkg in "${AUR_PACKAGES[@]}"; do
  if ! paru -Q "$pkg" &>/dev/null; then
    echo "Installing $pkg..."
    paru -S --needed --noconfirm "$pkg"
  fi
done

# Final confirmation that all AUR packages were installed
for pkg in "${AUR_PACKAGES[@]}"; do
  if paru -Q "$pkg" &>/dev/null; then
    echo "$pkg installation confirmed."
  else
    echo "Error: $pkg failed to install."
  fi
done

# Post-installation setup
echo "Adding user to various groups..."
for grp in tty realtime video audio input; do
  if ! groups "$USER" | grep -qw "$grp"; then
    sudo usermod -aG "$grp" "$USER"
  fi
done

# Make sure all of your scripts are executable
if [ -d ~/Scripts ]; then
  chmod +x ~/Scripts/*
else
  echo "Script directory not found. Skipping."
fi

# Enable required services
echo "Enabling NetworkManager and CUPS..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now cups

# Enable MPD service
systemctl --user enable mpd
systemctl --user start mpd

# Install Flatpak applications
echo "Installing Flatpak applications..."
# Ensure Flatpak is installed
if ! command -v flatpak &>/dev/null; then
  sudo pacman -S --noconfirm flatpak
else
  echo "Flatpak is already installed."
fi
# Install displaycal via Flatpak
echo "Installing DisplayCAL Flatpak..."
flatpak install -y flathub net.displaycal.DisplayCAL

#Install Bitwarden via Flatpak
echo "Installing Bitwarden Flatpak..."
flatpak install -y flathub com.bitwarden.dektop

# Clone dotfiles repo
echo "Cloning dotfiles repo..."
if [ ! -d ~/Scripts/dotfiles ]; then
  git clone https://github.com/tristengrant/dotfiles.git ~/Scripts/dotfiles
else
  echo "Dotfiles repository already exists."
fi

# Symlinking dotfiles
if [ ! -f ~/Scripts/symlink_dotfiles.sh ]; then
  chmod +x ~/Scripts/symlink_dotfiles.sh
  cd ~/Scripts
  ./symlink_dotfiles.sh
  cd ~/
else
  echo "symlink_dotfiles.sh not found, skipping."
fi

# Downloading wallpapers
mkdir -p ~/Pictures/wallpapers
git clone https://github.com/tristengrant/wallpapers.git ~/Pictures/wallpapers

# Download the latest Krita AppImage
if [ -f ~/Scripts/update_krita.sh ]; then
  chmod +x ~/Scripts/update_krita.sh
  cd ~/Scripts
  ./update_krita.sh
  cd ~/
else
  echo "update_krita.sh not found, skipping."
fi

# Music folder
echo "Mounting the media server's music folder..."
MOUNT_DIR="/home/tristen/Music"
FSTAB_ENTRY="192.168.2.221:/storage1/music $MOUNT_DIR nfs defaults,noatime 0 0"

# Create mount point if it doesn’t exist
[ -d "$MOUNT_DIR" ] || mkdir -p "$MOUNT_DIR"

# Add entry to fstab if not already present
if ! grep -qF "$FSTAB_ENTRY" /etc/fstab; then
  echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
fi

# Mount all filesystems from fstab
sudo mount -a

# Finishing up
echo "Installation complete. Reboot your system to apply all changes."
