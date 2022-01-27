#!/bin/sh
script_dir="$(dirname "$(readlink -f "$0")")"

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/
ln -sf "$script_dir"/.config/VSCodium/User/settings.json \
    "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/settings.json
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/settings.json

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/
ln -sf "$script_dir"/init.vim "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim

ln -sf "$script_dir"/bash_config.bash "$HOME"/.bash_aliases
ls -l "$HOME"/.bash_aliases

# Setup lynx config
"$script_dir"/lynx/setup
