#!/bin/sh

install_sh="install-vscode-packages.sh"
current_dir=$(dirname $0)
echo "#!/bin/sh\n" > $install_sh
code --list-extensions | xargs -L 1 echo code --install-extension >> $install_sh
