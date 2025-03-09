#!/bin/bash
set -e # Exit immediately if a command fails

# Ensure script is run as a normal user
if [[ $EUID -eq 0 ]]; then
  echo "Please do not run this script as root. Use a normal user with sudo."
  exit 1
fi

# Install paru if not installed
if ! command -v paru &>/dev/null; then
  echo "Installing paru..."
  sudo pacman -S --needed --noconfirm git base-devel
  git clone https://aur.archlinux.org/paru-bin.git ~/paru-bin
  pushd ~/paru-bin
  makepkg -si --noconfirm
  popd
  rm -rf ~/paru-bin
fi

# Create necessary directories
mkdir -p ~/Applications ~/Github ~/Documents ~/Music ~/Pictures/screenshots ~/Videos

# Set up AMD GPU config
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
  sddm
  qt5-quickcontrols
  qt5-graphicaleffects
  qt5-svg
  qt5-quickcontrols2
  networkmanager
  network-manager-applet
  reflector
  wget
  cronie
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
  flameshot
  sxiv
  w3m
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
  bitwarden-bin
  clipster
  xdg-ninja
  z.lua
  fzf-extras
  fzf-tab-git
  brave-bin
  gruvbox-material-gtk-theme-git
  gruvbox-material-icon-theme-git
  xcursor-simp1e-gruvbox-dark
  kimageformats
  flatseal
  tiger
  chkrootkit
  xremap-x11-bin
)
# Install packages
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# Add user to groups
for grp in tty realtime video audio input; do
  sudo usermod -aG "$grp" "$USER"
done

# Make scripts executable
[ -d ~/Scripts ] && chmod +x ~/Scripts/*

# Enable services
sudo systemctl enable --now NetworkManager cups sddm cronie
systemctl --user enable --now mpd

# Create DWM .desktop file
sudo tee /usr/share/xsessions/dwm.desktop >/dev/null <<EOF
[Desktop Entry]
Name=DWM
Comment=Dynamic Window Manager
Exec=/usr/local/bin/dwm
Type=Application
EOF

# Install Flatpak & DisplayCAL
if ! command -v flatpak &>/dev/null; then
  sudo pacman -S --noconfirm flatpak
fi
flatpak install -y flathub net.displaycal.DisplayCAL

# Clone dotfiles repo
DOTFILES_DIR=~/Scripts/dotfiles
[ ! -d "$DOTFILES_DIR" ] && git clone https://github.com/tristengrant/dotfiles.git "$DOTFILES_DIR"

chmod +x ~/Github/dotfiles/xprofile ~/Github/dotfiles/xsession ~/Github/dotfiles/xinitrc

# Symlink dotfiles
SYMLINK_SCRIPT=~/Scripts/symlink_dotfiles.sh
[ -f "$SYMLINK_SCRIPT" ] && chmod +x "$SYMLINK_SCRIPT" && "$SYMLINK_SCRIPT"

# Download wallpapers
WALLPAPER_DIR=~/Pictures/wallpapers
[ ! -d "$WALLPAPER_DIR" ] && git clone https://github.com/tristengrant/wallpapers.git "$WALLPAPER_DIR"

# Update Krita
KRITA_SCRIPT=~/Scripts/update_krita.sh
[ -f "$KRITA_SCRIPT" ] && chmod +x "$KRITA_SCRIPT" && "$KRITA_SCRIPT"

# Mount music folder
MOUNT_DIR="$HOME/Music"
FSTAB_ENTRY="192.168.2.221:/storage1/music $MOUNT_DIR nfs defaults,noatime 0 0"
[ ! -d "$MOUNT_DIR" ] && mkdir -p "$MOUNT_DIR"
grep -qF "$FSTAB_ENTRY" /etc/fstab || echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
sudo mount -a

echo "Installation complete. Reboot to apply all changes."
