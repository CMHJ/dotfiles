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
        Plug 'dracula/vim'
        Plug 'morhetz/gruvbox'

        Plug 'junegunn/goyo.vim' " Centres text to allow for comfy writing
        Plug 'tpope/vim-surround' " Allows for shortcuts with paired characters
        Plug 'lambdalisue/suda.vim' " Fix for sudo commands in nvim
        Plug 'itmammoth/doorboy.vim' " Auto closing of paired characters
    call plug#end()
endif

set noswapfile " Disable annoying swap file
set scrolloff=10 " Keep a space of 10 lines at top and bottom
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab " Convert tabs to spaces
set rnu nu " Lines numbering with relative numbering as well
set smartcase " Do case insensitive search unless that are capitals
set nohlsearch " Do not continue to highlight words after a search
set colorcolumn=80 " Have a ruler at 80 character mark, make it lightgrey

" Remove the solid background from the colorscheme and add ruler
augroup colour-fixes
    autocmd!
    autocmd ColorScheme * highlight Normal guibg=none ctermbg=none
    autocmd ColorScheme * highlight NonText guibg=none ctermbg=none
    autocmd ColorScheme * highlight ColorColumn ctermbg=0 guibg=lightgrey
augroup END

"autocmd! User GoyoLeave nested set bg=dark | colorscheme dracula
colorscheme ron "Set to desired colourscheme if dracula isn't available
colorscheme dracula

" Remappings
nmap <C-g> :Goyo<CR>

" Forceably write to a sudo protected file
" This plugin is used while this is a problem:
" https://github.com/neovim/neovim/issues/1716
" cnoremap w!! w !sudo tee % > /dev/null
cnoremap w!! SudaWrite

