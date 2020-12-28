###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi

# Set script dir in PATH variable
export PATH="$(dirname "$(readlink -f "$HOME/.bash_aliases")")/scripts":$PATH


# Set go paths
if command -v /usr/bin/go &> /dev/null
then
    export GOPATH=$(go env GOPATH)
    export PATH=$PATH:$(go env GOPATH)/bin
fi

# Custom Aliases
#unalias -a
#alias v='nvim'
alias v='vim'
alias c='clear'
alias uu='sudo apt update && sudo apt upgrade -y'
alias uur='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias gs='git status'
alias gfs='git fetch && git status'
alias gs='git status'
alias gd='git diff'
alias steal='git clone'

alias pie='perl -p -i -e' # Useful for running substitute commands on files in dir i.e.
# pie 's/replace-text/with-this-text/g' ./*.txt

# Custom functions
cs() { cd "$@" && ls -laF; }
mkcd() { mkdir -p "$@" && cd "$@"; }
vic() { vim $(which "$1"); } # Useful for editing scripts on path variable

export clear="[3J[H[2J" # Optimised clear function, clears the screen 5 times faster
clear() { echo -n $clear; }

