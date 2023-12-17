#!/bin/sh
script_dir="$(dirname "$(readlink -f "$0")")"

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

# point .bashrc to bash config in .config
bash_config_path="$(find home -name config.bash)"
bash_config_link_path="$(echo $bash_config_path | sed 's|home|\$HOME|g')"
cat > "$HOME/.bashrc" << EOF
#!/bin/bash

[ -f "$bash_config_link_path" ] && source "$bash_config_link_path"

EOF

# setup env vars to be sourced at login in profile
touch "$HOME/.profile"
env_path="$HOME/.config/shell/env"
if ! grep -q /shell/env $HOME/.profile; then
    cat >> "$HOME/.profile" << EOF
[ -f "$env_path" ] && source "$env_path"

EOF
fi

# setup lynx config
"$script_dir"/lynx/setup

# setup Firefox
browserdir="$HOME/.mozilla/firefox"
profilesini="$browserdir/profiles.ini"
profile="$(sed -n "/Default=.*.default-release/ s/.*=//p" "$profilesini")"
pdir="$browserdir/$profile"
ln -sf "$script_dir/user-overrides.js" "$pdir/user-overrides.js"
