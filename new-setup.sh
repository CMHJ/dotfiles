#!/bin/sh

dirs="$(find home -type d)"
# dirs=${dirs#home} # remove first home
dirs="$(echo $dirs | sed "s|home|$HOME|g")"

# create all paths if they don't exist
for p in $dirs; do
    echo $p
    mkdir -p "$p"
done

files="$(find home -type f)"
link_files=
for f in $files; do
    real_path="$(realpath "$f")"
    link_path="$(echo $f | sed "s|home|$HOME|g")"
    echo "$real_path" "$link_path"
    ln -sf "$real_path" "$link_path"
done
