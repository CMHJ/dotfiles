#!/bin/sh
echo "Re-enabling Desktop Icons"
gsettings set org.gnome.desktop.background show-desktop-icons true || true
