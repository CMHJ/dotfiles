" CMHJ's neovim config

" Install vim-plug if not already installed
" glob for the file, if the results returned are empty
if empty(glob(stdpath('data') . '/site/autoload/plug.vim'))
    " Install vim-plug
    silent execute '!mkdir -p ' . stdpath('data') . '/site/autoload'
    silent execute '!curl -fLo ' . stdpath('data') .
        \ '/site/autoload/plug.vim ' . 
        \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    " Install the plugins listed below
    autocmd VimEnter * PlugInstall
endif

" Only load plugins if vim-plug detected
" This only runs the first time, if new plugins are added PlugInstall will
" need to be called again
if filereadable(expand(stdpath('data') . '/site/autoload/plug.vim'))
    call plug#begin(stdpath('data') . '/plugged')
        "Plug 'dracula/vim'
        Plug 'morhetz/gruvbox'
        Plug 'junegunn/goyo.vim'
        Plug 'tpope/vim-surround'
    call plug#end()
endif

set scrolloff=10 " Keep a space of 10 lines at top and bottom
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab " Convert tabs to spaces
set rnu nu " Lines numbering with relative numbering as well
set smartcase " Do case insensitive search unless that are capitals
set nohlsearch " Do not continue to highlight words after a search
colorscheme ron
colorscheme gruvbox
set colorcolumn=80 " Have a ruler at 80 character mark, make it lightgrey
highlight ColorColumn ctermbg=0 guibg=lightgrey
" Remove the solid background from the colorscheme
highlight Normal ctermbg=none
highlight NonText ctermbg=none

" Remappings
nmap <C-g> :Goyo<CR>

