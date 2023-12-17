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

# point bashrc to bash config in .config
bash_config_path="$(find home -name config.bash)"
bash_config_link_path="$(echo $bash_config_path | sed 's|home|\$HOME|g')"
cat > "$HOME/.bashrc" << EOF
#!/bin/bash

[ -f "$bash_config_link_path" ] && source "$bash_config_link_path"
EOF
