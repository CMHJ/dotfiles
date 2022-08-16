###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi
complete -cf sudo
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '

# Set env vars
export BROWSER="brave"
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export VISUAL="codium"
export LC_ALL="en_US.UTF-8"

export HISTSIZE=10000

# XDG vars
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"

# NPM vars
#export NPM_CONFIG_PREFIX="$XDG_CONFIG_HOME/npm-global"

# Add script dir in PATH variable
export PATH="$(dirname "$(readlink -f "$HOME/.bash_aliases")")/scripts":$PATH
export PATH="$PATH:$HOME/.local/bin"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"


# Set go paths
if command -v /usr/bin/go &> /dev/null
then
    export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
    export PATH=$PATH:$(go env GOPATH)/bin
fi

# Custom Aliases
#unalias -a
alias c='clear'
alias p='sudo pacman'
alias auu='sudo apt update && sudo apt upgrade -y'
alias auur='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias pip='python3 -m pip'
alias steal='git clone --recursive'
alias gsu='git submodule update --init --recursive'
alias gs='git status'
alias gfs='git fetch && git status'
alias gfp='git fetch --prune'
alias gd='git diff'
alias gcm='git commit -m'

alias copy='xclip -sel clip'
alias paste='xclip -out -sel clip'

alias yt='yt-dlp -i --add-metadata'
alias tmux='tmux -f $XDG_CONFIG_HOME/tmux/tmux.conf'

alias pie='perl -p -i -e' # Useful for running substitute commands on files in dir.
# example: pie 's/replace-text/with-this-text/g' ./*.txt
cs() { cd "$@" && ls -lAFh; }
mkcd() { mkdir -p "$@" && cd "$@"; }
spe() { . .venv/bin/activate; } # Source python environment
# Launch application without closing terminal
launch() { [ -n "$@" ] && nohup "$@" >/dev/null 2>&1 & }

#export clear="[3J[H[2J" # Optimised clear function, clears the screen 5 times faster, but leaves previous frame behind, merely shifts entire screen down
#clear() { echo -n $clear; }

