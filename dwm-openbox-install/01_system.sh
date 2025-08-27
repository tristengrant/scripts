#!/bin/bash
set -e

sudo apt update && sudo apt upgrade -y

sudo apt install -y \
  dwm suckless-tools lightdm lightdm-gtk-greeter \
  network-manager network-manager-gnome cups system-config-printer \
  pipewire pipewire-pulse wireplumber qpwgraph pavucontrol \
  thunar thunar-volman thunar-archive-plugin gvfs gvfs-backends \
  dunst feh nsxiv mpv arandr syncthing \
  neovim git ripgrep fd-find fzf lf mc tmux xclip \
  zathura zathura-pdf-poppler qutebrowser firefox-esr \
  htop acpi ffmpeg maim pandoc pasystray qalculate-gtk \
  fonts-jetbrains-mono fonts-noto fonts-noto-cjk fonts-noto-color-emoji papirus-icon-theme
