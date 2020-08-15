#!/bin/sh
current_dir="$(dirname "$(readlink -f "$0")")"
install_sh="$current_dir/install-vscode-packages"
printf "#!/bin/sh\n" > "$install_sh"
code --list-extensions | xargs -L 1 echo code --install-extension >> "$install_sh"
