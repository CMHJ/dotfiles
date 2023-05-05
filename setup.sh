#!/bin/sh
script_dir="$(dirname "$(readlink -f "$0")")"

# Bash
ln -sf "$script_dir"/bash_config.bash "$HOME"/.bash_aliases
ls -l "$HOME"/.bash_aliases

# tmux
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/tmux/
ln -sf "$script_dir"/.config/tmux/tmux.conf "${XDG_CONFIG_HOME:-$HOME/.config}"/tmux/tmux.conf
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/tmux/tmux.conf

# Neovim
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/
ln -sf "$script_dir"/init.vim "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim

# VSCodium
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/
ln -sf "$script_dir"/.config/VSCodium/User/settings.json \
    "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/settings.json
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/settings.json

# Setup lynx config
"$script_dir"/lynx/setup

# Git
ln -sf "$script_dir"/gitconfig "$HOME"/.gitconfig

# Firefox
browserdir="$HOME/.mozilla/firefox"
profilesini="$browserdir/profiles.ini"
profile="$(sed -n "/Default=.*.default-release/ s/.*=//p" "$profilesini")"
pdir="$browserdir/$profile"
ln -sf "$script_dir/user-overrides.js" "$pdir/user-overrides.js"
ls -l "$pdir/user-overrides.js"

