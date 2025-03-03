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
  else
    echo "paru is already installed."
  fi
}

# Install paru
install_paru

# Create necessary directories
mkdir -p ~/Applications ~/Github ~/Documents ~/Music ~/Pictures ~/Videos ~/Pictures/screenshots

# Set up AMD GPU Conf file
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
  reflector
  dunst
  kitty
  neovim
  tree-sitter
  fastfetch
  openssh
  git
  feh
  wget
  bottom
  lib32-mesa
  vulkan-radeon
  lib32-vulkan-radeon
  xorg-server
  xorg-xinit
  xorg-xrandr
  xorg-xsetroot
  xorg-xinput
  sws
  arandr
  libwacom
  xf86-input-wacom
  mpv
  unclutter
  xdg-user-dirs
  bat
  lsd
  sxiv
  ranger
  libheif
  imagemagick
  fzf
  ripgrep
  ripgrep-all
  sxhkd
  go
  pnpm
  nodejs
  sassc
  hugo
  ueberzug
  thunar
  steam
  gvfs
  gvfs-smb
  smbclient
  cifs-utils
  tumbler
  ffmpegthumbnailer
  thunar-archive-plugin
  file-roller
  thunar-volman
  thunar-media-tags-plugin
  thunar-shares-plugin
  firefox
  polkit-gnome
  clipmenu
  satty
  jq
  pipewire
  pipewire-pulse
  wireplumber
  pipewire-jack
  helvum
  pamixer
  pavucontrol
  cups
  system-config-printer
  glabels
  networkmanager
  network-manager-applet
  qt5ct
  ttf-jetbrains-mono
  ttf-font-awesome
  zathura
  ncmpcpp
  mpd
  mpd-mpris
  fd
  xclip
  xdotool
  xorg-xprop
  xorg-xev
  duf
  ncdu
  aria2
  realtime-privileges
  alsa-utils
  tmux
  p7zip
  unrar
  lrzip
  clamav
  noto-fonts-emoji
  ttf-nerd-fonts-symbols
  picom
  swh-plugins
  alsa-plugins
  shellcheck
  htop
  trash-cli
  xorg-xdpyinfo
  webp-pixbuf-loader
  lynis
  rkhunter
  udiskie
  brightnessctl
  xdg-desktop-portal-gtk
  flatpak
  libnotify
  tldr
  zsh
  noise-suppression-for-voice
  ffmpeg
  libavif
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
  xdg-utils
  autorandr
  xorg-xrdb
  yq
  lua
  lua-language-server
  tcpdump
  nmap
  smartmontools
  cyme
  gcolor3
  libgsf
  xournalpp
  libappimage
  shellharden
  iperf3
  arp-scan
  starship
  direnv
  lazygit
  vale
  haskell-pandoc
  steam
  sox
  duperemove
  traceroute
  bmon
  pdfgrep
  translate-shell
  xorg-xwininfo
  rtirq
  hunspell
  hunspell-en_ca
  enchant
  darktable
  reapack
  reaper
  lsp-plugins
  obsidian
  lxappearance
  qt5ct
  kvantum
  gparted
  playerctl
)

# List of packages to install from the AUR
AUR_PACKAGES=(
  bitwarden-bin
  clipster
  syncthing-gtk
  xdg-ninja
  z.lua
  chkrootkit
  fzf-extras
  fzf-tab-git
  neovim-gruvbox-material-git
  gruvbox-material-gtk-theme-git
  gruvbox-material-icon-theme-git
  xcursor-simp1e-gruvbox-dark
  gruvbox-plus-icon-theme-git
  kimageformats
  appimagelauncher
  flatseal
  xremap-x11-bin
)

# Install official packages
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Install AUR packages using paru
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

for pkg in "${AUR_PACKAGES[@]}"; do
  if ! paru -Q "$pkg" &>/dev/null; then
    paru -S --needed --noconfirm "$pkg"
  else
    echo "$pkg is already installed."
  fi
done

# Post-installation setup
echo "Adding user to the realtime group for audio performance."
sudo usermod -aG tty,realtime,video,audio,input "$USER"

# Enable required services
echo "Enabling NetworkManager and CUPS..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now cups

# Install Flatpak applications
echo "Installing Flatpak applications..."

# Ensure Flatpak is installed
sudo pacman -S --noconfirm flatpak

# Install displaycal via Flatpak
flatpak install flathub net.displaycal.DisplayCAL

# Clone dotfiles repo
echo "Cloning dotfiles repo..."
git clone https://github.com/tristengrant/dotfiles.git ~/Scripts/dotfiles

# Symlinking dotfiles
cd ~/Scripts
./symlink_dotfiles.sh
cd ~/

# Finishing up
echo "Installation complete. Reboot your system to apply all changes."
