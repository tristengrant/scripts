#!/bin/bash
set -e # Exit immediately if a command fails

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Update the system clock
echo "Setting system clock..."
timedatectl set-ntp true

# Set up pacman mirror list with reflector
echo "Setting up the fastest mirrors..."

# Use reflector to get the fastest mirrors for Canada (or your preferred country)
reflector --country "Canada" --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

# Update the system
pacman -Syu --noconfirm

# Partition the disks (assuming your system uses nvme0n1 for the main drive and sda for the extra SSD)
echo "Partitioning the disks..."

# Create partitions using sfdisk or any other partitioning tool (adjust according to your setup)
# This is a rough template, adjust according to your actual setup
# This will create the partition scheme on your nvme and sda
(
echo label gpt
echo,1G,EFI
echo,,linux
) | sfdisk /dev/nvme0n1

# Swap setup (use zram)
SWAP_PARTITION="/dev/zram0"
mkswap "$SWAP_PARTITION"
swapon "$SWAP_PARTITION"

# Create partition for /ssd
echo "Creating partition for /ssd..."
(
echo label gpt
echo,,linux
) | sfdisk /dev/sda

# Format the partitions (adjust fs type as needed)
echo "Formatting the partitions..."
mkfs.fat -F32 /dev/nvme0n1p1  # EFI partition
mkfs.btrfs /dev/nvme0n1p2      # Main Btrfs partition
mkfs.btrfs /dev/sda1            # /ssd Btrfs partition

# Mount the root filesystem
echo "Mounting the root filesystem..."
mount /dev/nvme0n1p2 /mnt

# Create subvolumes for Btrfs
echo "Creating Btrfs subvolumes..."
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@log
btrfs subvolume create /mnt/@snapshots

# Mount the subvolumes
umount /mnt
mount -o noatime,compress=lzo,subvol=@ /dev/nvme0n1p2 /mnt
mkdir /mnt/{boot,home,var,tmp,log,.snapshots}
mount -o noatime,compress=lzo,subvol=@home /dev/nvme0n1p2 /mnt/home
mount -o noatime,compress=lzo,subvol=@var /dev/nvme0n1p2 /mnt/var
mount -o noatime,compress=lzo,subvol=@tmp /dev/nvme0n1p2 /mnt/tmp
mount -o noatime,compress=lzo,subvol=@log /dev/nvme0n1p2 /mnt/log
mount -o noatime,compress=lzo,subvol=@snapshots /dev/nvme0n1p2 /mnt/.snapshots

# Mount the /ssd drive to /ssd
echo "Mounting /dev/sda1 to /ssd..."
mkdir /mnt/ssd
mount /dev/sda1 /mnt/ssd

# Set up the EFI partition
mount /dev/nvme0n1p1 /mnt/boot

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware btrfs-progs vim networkmanager reflector git sudo base-devel

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into the new system
echo "Chrooting into the new system..."
arch-chroot /mnt

# Set time zone
echo "Setting time zone..."
ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
hwclock --systohc

# Localization
echo "Setting up localization..."
echo "en_CA.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_CA.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Set hostname
echo "Setting hostname..."
echo "arch" > /etc/hostname

# Set up root password
echo "Setting root password..."
passwd

# Add user "tristen"
echo "Creating user 'tristen'..."
useradd -m -G wheel -s /bin/bash tristen
echo "Set password for user 'tristen'..."
passwd tristen

# Grant sudo privileges
echo "Setting up sudo privileges..."
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

# Install and configure bootloader (GRUB for UEFI)
echo "Installing GRUB bootloader..."
pacman -S --noconfirm grub efibootmgr

# Install GRUB to the EFI partition
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Create the GRUB configuration
echo "Generating GRUB config..."
grub-mkconfig -o /boot/grub/grub.cfg

# Enable necessary services
echo "Enabling services..."
systemctl enable NetworkManager

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
  gruvbox-dark-gtk

# Install other packages from the repo
echo "Installing other packages..."
pacman -S --noconfirm \
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
  tofi \
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

# Clone your website repository
echo "Cloning your website repository..."
cd /home/tristen/Github
git clone https://github.com/tristengrant/tristengrant.com.git tristengrant
cd ~

# Clone your comic site repository
echo "Cloning your comic website repository..."
cd /home/tristen/Github
git clone https://github.com/tristengrant/catandbotcomic.com.git catandbot
cd ~

# Clone your website repository
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

# Update Krita
cd ~/Scripts && ./update_krita.sh

# Enable services
sudo systemctl enable --now cups cronie

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

# Force update the desktop menu to ensure Krita appears
echo "Updating desktop menu..."
xdg-desktop-menu forceupdate

echo "Krita $LATEST_VERSION installed successfully!"
echo "Run it with: $APPIMAGE_PATH or searching with your application menu."

# Enable Ly Login Manager without starting it
systemctl enable ly.service

# Reboot
echo "Installation completed. Rebooting..."
reboot







