#!/bin/sh
script_dir=$(dirname $0)

ln -sf "$PWD"/vimrc ~/.vimrc
ls -l ~/.vimrc

ln -sf "$PWD"/bash_config.bash ~/.bash_aliases
ls -l ~/.bash_aliases
