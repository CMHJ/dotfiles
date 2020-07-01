#!/bin/sh
echo "Removing old config files."
rm -f ~/.bashrc
rm -f ~/.vimrc

echo "Creating sym links to config files on home directory."
ln -s -t ~/ ~/dotfiles/.bashrc
ln -s -t ~/ ~/dotfiles/.vimrc

echo "Sourcing config files and resetting."
. ~/.bashrc

echo "Done."

