###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi

# Set script dir in PATH variable
export PATH="$(dirname "$(readlink -f "$HOME/.bash_aliases")")/scripts":$PATH

# Custom Aliases
#unalias -a
#alias v='nvim'
alias v='vim'
alias c='clear'
alias uu='sudo apt update && sudo apt upgrade -y'
alias uur='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias gfs='git fetch && git status'
alias steal='git clone'

alias pie='perl -p -i -e'

# Custom functions
cs() { cd "$@" && ls -laF; }
mkcd() { mkdir -p "$@" && cd "$@"; }
