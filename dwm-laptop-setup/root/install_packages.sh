#!/usr/bin/env bash
set -euo pipefail
trap 'echo "Warning: Error on line $LINENO"; exit 1' ERR
export DEBIAN_FRONTEND=noninteractive

echo "Adding the Helium browser to sources list..."
curl -fsSL https://justaguylinux.codeberg.page/helium-deb-repo/key.asc | gpg --dearmor -o /usr/share/keyrings/helium-deb-repo.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/helium-deb-repo.gpg] https://justaguylinux.codeberg.page/helium-deb-repo stable main" | tee /etc/apt/sources.list.d/helium-deb-repo.list

echo "Adding Yazi to the sources list..."
curl -sS https://debian.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/debian.griffo.io.gpg
echo "deb https://debian.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | tee /etc/apt/sources.list.d/debian.griffo.io.list

echo "Adding WezTerm to the sources list..."
curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | tee /etc/apt/sources.list.d/wezterm.list
chmod 644 /usr/share/keyrings/wezterm-fury.gpg

dpkg --add-architecture i386
apt update -y
apt upgrade -y

echo "Installing essential system packages..."

BASE_PKGS=(
    xorg xorg-dev xinit xbacklight xbindkeys xinput build-essential sxhkd xdotool dbus-x11
    libnotify-bin libnotify-dev libusb-0.1-4 libwacom-common xserver-xorg-input-wacom
    libx11-dev libxft-dev libxinerama-dev libxrandr-dev libx11-xcb-dev ibxext-dev
    libxcb1-dev libxcb-util0-dev libxcb-keysyms1-dev libxcb-randr0-dev
    libxcb-xinerama0-dev libxcb-icccm4-dev libxcb-res0-dev steam-devices
    mesa-utils x11-xserver-utils xclip xdg-utils brightnessctl brightness-udev
    network-manager-gnome network-manager-applet dnsutils openssh-client openssh-server
    sshfs smbclient syncthing pipewire pipewire-audio pipewire-pulse pipewire-alsa
    pipewire-jack wireplumber alsa-utils pavucontrol pulsemixer pamixer
    mpd mpc ncmpcpp rtkit thunar thunar-archive-plugin thunar-volman gvfs-backends
    gvfs-common dialog mtools cups cups-pdf printer-driver-brlaser
    system-config-printer unar unzip tar gzip zip udiskie avahi-daemon acpi acpid
    xfce4-power-manager flameshot qimgv xdg-user-dirs-gtk fd-find zoxide smartmontools
    arandr autorandr suckless-tools tmux htop nano orchis-gtk-theme adwaita-icon-theme
    adwaita-qt adwaita-qt6 curl wget git cmake meson ninja-build pkg-config python3 python-is-python3
    npm node-copy-paste firefox-esr lightdm playerctl lsb-release lxpolkit fonts-recommended
    fonts-noto-sans fonts-noto-serif fonts-noto-color-emoji fonts-jetbrains-mono fonts-terminus
    fonts-font-awesome okular gimp steam-installer peek ark qt5ctgeany gnome-disk-utility
    j4-dmenu-desktop yazi helium-browser wezterm
)

apt install -y "${BASE_PKGS[@]}" || echo "WARNING: Some packages could not be installed."

echo "Refreshing font cache..."
fc-cache -fv

echo "Install NPM packages for coding...""
npm install -g prettier stylelint typescript typescript-language-server vscode-langservers-extracted bash-language-server yaml-language-server

# Set wezterm as default terminal emulator (fixes Debian 13 defaulting to lxterminal)
if command -v wezterm &> /dev/null && command -v update-alternatives &> /dev/null; then
    echo "Setting wezterm as default terminal emulator..."
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/wezterm 50
    update-alternatives --set x-terminal-emulator /usr/bin/wezterm
fi

echo "Cleaning up..."
apt autoremove -y
apt clean
apt-get check

echo "Installation complete! Reboot to start LightDM and your desktop environment."
