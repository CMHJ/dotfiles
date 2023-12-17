#!/bin/sh

# create all config dirs if they don't exist
dirs="$(find home -type d)"
dirs="$(echo $dirs | sed "s|home|$HOME|g")"
for p in $dirs; do
    mkdir -p "$p"
done

# symlink all config files to the appropriate spot in the home dir
files="$(find home -type f)"
for f in $files; do
    real_path="$(realpath "$f")"
    link_path="$(echo $f | sed "s|home|$HOME|g")"
    ln -sf "$real_path" "$link_path"
done
