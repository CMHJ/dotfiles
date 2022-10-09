###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi
complete -cf sudo

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

if [ -x "$(command -v tput)" ] && tput setaf 1 >&/dev/null; then
# We have color support; assume it's compliant with Ecma-48
# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# a case would tend to support setf rather than setaf.)
color_prompt=yes
else
color_prompt=
fi

if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\$ '
else
    PS1='\u@\h:\W\$ '
fi
unset color_prompt

# Set env vars
export BROWSER="brave"
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export VISUAL="nvim"
export LC_ALL="en_US.UTF-8"

export HISTSIZE=1000000

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

# Stardict Dictionaries
export DICS="/usr/share/stardict/dic/"

# Custom Aliases
#unalias -a
alias c='clear'
alias p='paru'
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

