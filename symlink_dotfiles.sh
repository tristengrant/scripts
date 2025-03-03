#!/bin/bash

# In the home directory
ln -sf ~/Github/dotfiles/bashrc ~/.bashrc
ln -sf ~/Github/dotfiles/bash_profile ~/.bash_profile
ln -sf ~/Github/dotfiles/xinitrc ~/.xinitrc
ln -sf ~/Github/dotfiles/Xresources ~/.Xresources
ln -sf ~/Github/dotfiles/Xauthority ~/.Xauthority
ln -sf ~/Github/dotfiles/gtkrc-2.0 ~/.gtkrc-2.0
ln -sf ~/Github/dotfiles/profile ~/.profile
ln -sf ~/Github/dotfiles/gitconfig ~/.gitconfig

# In the home/.config
ln -sf ~/Github/dotfiles/config/fontconfig ~/.config
ln -sf ~/Github/dotfiles/config/gtk-3.0 ~/.config
ln -sf ~/Github/dotfiles/config/kitty ~/.config
ln -sf ~/Github/dotfiles/config/QtProject.conf ~/.config
ln -sf ~/Github/dotfiles/config/qt5ct ~/.config
ln -sf ~/Github/dotfiles/config/nvim ~/.config

