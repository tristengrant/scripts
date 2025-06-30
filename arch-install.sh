#!/bin/bash
set -e # Exit immediately if a command fails

# Ensure script is run as a normal user
if [[ $EUID -eq 0 ]]; then
  echo "Please do not run this script as root. Use a normal user with sudo."
  exit 1
fi

# Install paru if not installed, commented out because I'm using EndeavourOS which installed yay by default
#if ! command -v paru &>/dev/null; then
#  echo "Installing paru..."
#  sudo pacman -S --needed --noconfirm git base-devel
#  git clone https://aur.archlinux.org/paru-bin.git ~/paru-bin
#  pushd ~/paru-bin
#  makepkg -si --noconfirm
#  popd
#  rm -rf ~/paru-bin
#fi

# Create necessary directories
mkdir -p ~/Applications ~/Github ~/Documents ~/Pictures/screenshots ~/Pictures/wallpapers ~/Videos

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
  networkmanager
  reflector
  fastfetch
  wget
  openssh
  p7zip
  unrar
  lrzip
  trash-cli
  udiskie
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
  qpwgraph
  alsa-utils
  realtime-privileges
  rtirq
  cups
  nfs-utils
  system-config-printer
  glabels
  htop
  duf
  dysk
  nodejs
  npm
  libwacom
  xf86-input-wacom
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
  nsxiv
  xdg-utils
  xdg-user-dirs
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  ffmpegthumbnailer
  tumbler
  ffmpeg
  libheif
  libavif
  sshfs
  mpv
  mpd
  mpc
  mpd-mpris
  ncmpcpp
  rmpc
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
  ttf-jetbrains-mono
  ttf-nerd-fonts-symbols
  ttf-nerd-fonts-symbols-mono
  ttf-noto-nerd
  ttf-font-awesome
  noto-fonts-emoji
  noise-suppression-for-voice
  gparted
  xournalpp
  lsp-plugins-clap
  zathura
  enchant
  steam
  firefox
  bitwarden
  vim
  neovim
)

# List of packages to install from the AUR
AUR_PACKAGES=(
  clipster
  vcvrack
  xdg-ninja
  gruvbox-material-gtk-theme-git
  gruvbox-material-icon-theme-git
  xcursor-simp1e-gruvbox-dark
)
# Install packages
sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"
yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"

# Add user to groups
for grp in tty realtime video audio input lp; do
  sudo usermod -aG "$grp" "$USER"
done

# Enable services
sudo systemctl enable --now NetworkManager cups

# Create DWM .desktop file
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/dwm.desktop >/dev/null <<EOF
[Desktop Entry]
Name=DWM
Comment=Dynamic Window Manager
Exec=/usr/local/bin/dwm
Type=Application
EOF

# Clone dotfiles repo
cd ~/Github && git clone https://github.com/tristengrant/dotfiles.git
chmod +x ~/Github/dotfiles/xprofile ~/Github/dotfiles/xsession

# Get suckless software
cd ~/Github
git clone https://github.com/tristengrant/suckless.git
cd ~/Github/suckless/dwm && sudo make install
cd ~/github/suckless/dmenu && sudo make install
cd ~/Github/suckless/st && sudo make install

# Update Krita
cd ~/Github/scripts && ./update_krita.sh

# Enabling SDDM
systemctl enable sddm.service

echo "✅ Installation complete. Reboot to apply all changes."
echo "👉 After a reboot plug in your USB and run: ./mount-music.sh"
