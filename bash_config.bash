# Custom Aliases
#unalias -a
#alias v='nvim'
alias v='vim'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias uu='sudo apt update && sudo apt upgrade -y'
alias uur='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias gfs='git fetch && git status'

# Custom functions
cs() { cd "$@" && ls -laF; }
mkcd() { mkdir -p "$@" && cd "$@"; }
