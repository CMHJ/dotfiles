#!/bin/sh

set -xe

# Add user to groups
sudo usermod -a -G rfkill "$USER"

# Install base packages
sudo pacman -Syyu --noconfirm \
base-devel \
git \
cmake \
gparted \
vim \
gvim

# Install yay
cd /tmp
git clone https://aur.archlinux.org/yay-git.git yay
chown -R "$USER":"$USER" ./yay
cd ./yay
makepkg -si

yay -Syyu --noconfirm \
brave-bin \
vscodium-bin \
qdirstat-bin

