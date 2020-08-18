#!/bin/sh
script_dir="$(dirname "$(readlink -f "$0")")"

ln -sf "$script_dir"/vimrc ~/.vimrc
ls -l ~/.vimrc

ln -sf "$script_dir"/bash_config.bash ~/.bash_aliases
ls -l ~/.bash_aliases

# Setup lynx config
"$script_dir"/lynx/setup
