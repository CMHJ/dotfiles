#!/bin/sh
script_dir="$(dirname "$(readlink -f "$0")")"

#ln -sf "$script_dir"/vimrc ~/.vimrc
#ls -l ~/.vimrc

mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/
ln -sf "$script_dir"/init.vim "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim
ls -l "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim/init.vim

ln -sf "$script_dir"/bash_config.bash ~/.bash_aliases
ls -l ~/.bash_aliases

# Setup lynx config
"$script_dir"/lynx/setup
