#!/bin/sh
script_dir="$(dirname "$(readlink -f "$0")")"

# Link configurations to config folder
#for file in "$script_dir"/.config/*; do
    #ln -sf "$file" "${XDG_CONFIG_HOME:-$HOME/.config}"
    #ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/"$(basename "$file")"
#done

ln -sf "$script_dir"/.config/flake8 "$HOME"/.flake8
ls -l "$HOME"/.config/flake8

ln -sf "$script_dir"/.config/VSCodium/User/settings.json \
    "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/settings.json
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/VSCodium/User/settings.json

#ln -sf "$script_dir"/vimrc $HOME/vimrc
#ls -l $HOME/vimrc

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/
ln -sf "$script_dir"/init.vim "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim

ln -sf "$script_dir"/bash_config.bash "$HOME"/.bash_aliases
ls -l "$HOME"/.bash_aliases

# Setup lynx config
"$script_dir"/lynx/setup
