" CMHJ's neovim config

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set rnu nu
set smartcase

" Install vim-plug if not already installed
" glob for the file, if the results returned are empty
if empty(glob($XDG_DATA_HOME . '/nvim/site/autoload/plug.vim'))
    " Install vim-plug
    silent !curl -fLo "$XDG_DATA_HOME/nvim/site/autoload/plug.vim"
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    " Install the plugins listed below
    autocmd VimEnter * PlugInstall
endif

" Only load plugins if vim-plug detected
if filereadable(expand($XDG_DATA_HOME . '/nvim/site/autoload/plug.vim'))
    call plug#begin(stdpath('data') . '/plugged')
        Plug 'junegunn/goyo.vim'
        Plug 'tpope/vim-surround'
    call plug#end()
endif
