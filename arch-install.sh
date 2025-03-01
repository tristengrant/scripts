#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

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
mkdir -p ~/Applications ~/Github ~/Scripts ~/Desktop ~/Documents ~/Music ~/Pictures ~/Public ~/Templates ~/Videos ~/Pictures/screenshots

# Set up AMD GPU Conf file
sudo chmod 755 /etc/X11/xorg.conf.d/

# Create the file with root privileges and set the content
sudo tee /etc/X11/xorg.conf.d/20-amdgpu.conf > /dev/null <<EOF
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
    ttf-jetbrains-mono-nerd
    ttf-hack-nerd
    ttf-terminus-nerd
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
    yoshimi
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
    dragonfly-reverb
    ffmpeg
    libavif
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-history-substring-search
    xdg-utils
    autorandr
    xorg-xrdb
    zynaddsubfx
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
    stow
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
    mda.lv2
    obsidian
    lxappearance
    qt5ct
)

# List of packages to install from the AUR
AUR_PACKAGES=(
    bitwarden-bin
    clipster
    yabridge
    carla
    syncthing-gtk
    xdg-ninja
    z.lua
    chkrootkit
    fzf-extras
    fzf-tab-git
    xcursor-simp1e-gruvbox-dark
    neovim-gruvbox-material-git
    gruvbox-material-icon-theme-git
    gruvbox-material-gtk-theme-git
    kimageformats
    appimagelauncher
    flatseal
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
sudo usermod -aG realtime,video,audio,input "$USER"

# Enable required services
echo "Enabling NetworkManager and CUPS..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now cups

# Install Flatpak applications
echo "Installing Flatpak applications..."

# Ensure Flatpak is installed
sudo pacman -S --noconfirm flatpak

# Add the Flathub repository if it's not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install displaycal via Flatpak
flatpak install flathub net.displaycal.DisplayCAL

# Configure ~/.xinitrc
echo "Configuring ~/.xinitrc..."
cat > ~/.xinitrc <<EOF
# Set DPI (adjust as needed)
xrandr --dpi 96

# Set Monitor Layout
xrandr --output DisplayPort-1 --mode 2560x1440 --pos 1200x480 --rotate normal \
       --output DisplayPort-2 --mode 1920x1200 --pos 0x0 --rotate left

# Load environment variables from ~/.profile
[ -f ~/.profile ] && source ~/.profile

# Load environment variables from ~/.Xresources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Set default cursor
xsetroot -cursor_name left_ptr  # Set default cursor

# Start background applications
feh --bg-fill --randomize ~/Pictures/wallpapers/* &
dwmblocks &
dunst &
udiskie &
syncthing-gtk --hidden &
picom --experimental-backends -b
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
clipster -d 2>/dev/null &

#Start DWM
exec dwm
EOF

# Configure ~/.Xresources
echo "Configuring ~/.Xresources..."
cat > ~/.Xresources <<EOF
Xft.dpi: 96                    # Adjust for HiDPI (e.g., 120, 144)
Xft.antialias: true            # Enable font anti-aliasing
Xft.hinting: true              # Enable font hinting
Xft.rgba: rgb                  # Subpixel rendering (rgb, bgr, vrgb, vbgr)
Xft.hintstyle: hintslight       # Options: hintnone, hintslight, hintmedium, hintfull
Xft.lcdfilter: lcddefault       # Smoother fonts
Xcursor.theme: xcursor-simp1e-gruvbox-dark
Xcursor.size: 24
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

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || echo "Failed to add Flathub."

# General Shortcuts
alias ls='ls --color=auto'
alias ll='ls -la --color=auto'
alias grep='grep --color=auto'
alias l='ls -CF' # Compact view
alias ..='cd ..' # Go up one directory 
alias ...='cd ../..' # Go up two directories 
alias ....='cd ../../..' # Go up three directories 
alias ~='cd ~' # Go to home directory

# Safety & Confirmation
alias cp='cp -i'   # Confirm before overwriting
alias mv='mv -i'   # Confirm before moving
alias rm='rm -i'   # Confirm before deleting

# File & Directory Management
alias mkdir='mkdir -p' # Create parent directories if needed
alias untar='tar -xvf' # Extract tar files
alias zipf='zip -r' # Create a zip file
alias mkcd='foo() { mkdir -p "$1" && cd "$1" || echo "Failed to create and cd into directory $1"; }; foo'

# Networking
alias myip="curl ifconfig.me" # Show public IP
alias ports='netstat -tulanp' # Show open ports
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -' # Speed test

# System Monitoring
alias cpu='lscpu'              # Show CPU details
alias mem='free -h'            # Show memory usage
alias disk='df -h'             # Show disk usage
alias du1='du -h --max-depth=1' # Show folder sizes
alias psme='ps aux | grep $USER'  # Show processes of current user

# Package Management (For Arch Linux)
alias update='sudo pacman -Syu' # Update system 
alias upgrade='sudo pacman -Syyu' # Force refresh and update 
alias install='sudo pacman -S' # Install a package 
alias remove='sudo pacman -Rns' # Remove package and dependencies 
alias orphan='sudo pacman -Qdtq | sudo pacman -Rns -' # Remove orphaned packages 
alias cleanup='sudo pacman -Sc' # Clean package cache
alias update-mirrors='sudo reflector --country Canada --latest 50 --protocol https --sort rate --download-timeout 10 --save /etc/pacman.d/mirrorlist && sudo pacman -Syy' # Update and get fasest Arch mirrors
alias yay='paru'
alias aur='paru'

# Git
alias gs='git status' # Show status 
alias ga='git add .' # Add all changes 
alias gc='git commit -m' # Commit with message 
alias gp='git push' # Push changes 
alias glog='git log --oneline --graph --decorate' # Pretty log 
alias gco='git checkout' # Switch branches 
alias gpull='git pull' # Pull latest changes 
alias gdiff='git diff' # Show differences

# Other Utilities
alias cls='clear' # Clear terminal 
alias path='echo $PATH | tr ":" "\n"' # View PATH in readable format 
alias extract='tar -xvf' # Extract tar files 

# Misc
alias ff='fastfetch'
alias vim='nvim'
alias vi='nvim'
alias tgsite='cd ~/Github/tristengrant/'
alias cbcomic='cd ~/Github/catandbotcomic/'
alias suckless='cd ~/Github/suckless/ && ls'

PS1='[\u@\h \W]\$ '

export PATH="$HOME/Scripts:$HOME/Github:$HOME/Applications:$PATH"
EOF

# Configure ~/.profile
echo "Configuring ~/.profile..."
cat > ~/.profile <<EOF
export XDG_SESSION_TYPE=x11
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export XCURSOR_THEME=xcursor-simp1e-gruvbox-dark
export XCURSOR_SIZE=24
export GTK_THEME=gruvbox-material
export QT_QPA_PLATFORMTHEME=qt5ct
export GTK_USE_PORTAL=1
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
gtk-icon-theme-name=gruvbox-material
gtk-cursor-theme-name=xcursor-simp1e-gruvbox-dark
gtk-cursor-theme-size=24
EOF

# Configure ~/.gtkrc-2.0
touch ~/.gtkrc-2.0

echo "Configuring ~/.gtkrc-2.0"
cat > ~/.gtkrc-2.0 <<EOF
gtk-icon-theme-name="gruvbox-material"
gtk-cursor-theme-name="xcursor-simp1e-gruvbox-dark"
gtk-cursor-theme-size=24
EOF

# Install DWM and Dmenu
echo "Cloning your suckless Github repo"
cd ~/Github
git clone https://github.com/tristengrant/suckless.git

echo "Installing DWM"
cd ~/Github/suckless/dwm
make
sudo make clean install

echo "Installing Dmenu"
cd ~/Github/suckless/dmenu
make
sudo make clean install

# Finishing up
echo "Installation complete. Reboot your system to apply all changes."
