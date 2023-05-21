###############################
# Connor's Bash Configuration #
###############################

# Set vi mode for bash
set -o vi
complete -cf sudo

# source env vars
env_path="$HOME/.config/shell/env"
[ -f "$env_path" ] && . "$env_path"

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

# enable color support for some common commands
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=always'
fi


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
mkfile() {
    dir_path="$(dirname "$@")"
    mkdir -p "$dir_path"
    touch "$@"
    "$EDITOR" "$@"
}
spe() { . .venv/bin/activate; } # Source python environment
# Launch application without closing terminal
launch() { [ -n "$@" ] && nohup "$@" >/dev/null 2>&1 & }
# Edit this bash config file
bash_config() {
    "$EDITOR" "$BASH_SOURCE"
    . "$BASH_SOURCE"
    echo "$BASH_SOURCE"
}

#export clear="[3J[H[2J" # Optimised clear function, clears the screen 5 times faster, but leaves previous frame behind, merely shifts entire screen down
#clear() { echo -n $clear; }

