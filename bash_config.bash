###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi

# Set env vars
export EDITOR="nvim"
export LC_ALL="en_US.UTF-8"

# XDG vars
export XDG_CONFIG_HOME="$HOME/.config"

# NPM vars
export NPM_CONFIG_PREFIX="$XDG_CONFIG_HOME/npm-global"

# Add script dir in PATH variable
export PATH="$(dirname "$(readlink -f "$HOME/.bash_aliases")")/scripts":$PATH
export PATH="$PATH:$HOME/.local/bin"


# Set go paths
if command -v /usr/bin/go &> /dev/null
then
    export GOPATH=$(go env GOPATH)
    export PATH=$PATH:$(go env GOPATH)/bin
fi

# Custom Aliases
#unalias -a
alias c='clear'
alias auu='sudo apt update && sudo apt upgrade -y'
alias auur='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias gs='git status'
alias gfs='git fetch && git status'
alias gfp='git fetch --prune'
alias gd='git diff'
alias steal='git clone'
alias copy='xclip -sel clip'
alias paste='xclip -out -sel clip'
alias yt='yt-dlp -i --add-metadata'

alias pie='perl -p -i -e' # Useful for running substitute commands on files in dir.
# example: pie 's/replace-text/with-this-text/g' ./*.txt

# Custom functions
cs() { cd "$@" && ls -laF; }
mkcd() { mkdir -p "$@" && cd "$@"; }
vic() { vim $(which "$1"); } # Useful for editing scripts on path variable

#export clear="[3J[H[2J" # Optimised clear function, clears the screen 5 times faster
#clear() { echo -n $clear; }

