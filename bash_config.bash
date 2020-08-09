###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi

# Custom Aliases
#unalias -a
#alias v='nvim'
alias v='vim'
alias c='clear'
alias uu='sudo apt update && sudo apt upgrade -y'
alias uur='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias gfs='git fetch && git status'
alias steal='git clone'

# Custom functions
cs() { cd "$@" && ls -laF; }
mkcd() { mkdir -p "$@" && cd "$@"; }
