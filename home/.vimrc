" disable vi compatibility
set nocompatible

syntax enable

colorscheme koehler
set background=dark "uncomment this if your terminal has a dark background
hi Normal guibg=NONE ctermbg=NONE

"disable cursor blinking
set gcr=n:blinkon0

" set splitting behaviour to something more expected in modern editors
set splitbelow
set splitright

" disable bells
set belloff=all
set novisualbell

" automatically load changed files
set autoread

" trim trailing whitespace on save
autocmd BufWritePre * :%s/\s\+$//e

" auto-reload vimrc
set noswapfile

" show the filename in the window titlebar
set title

" set encoding
set encoding=utf-8

" display incomplete commands at the bottom
set showcmd

" disable mouse support
set mouse=
set ttymouse=

" line numbers
set number relativenumber

" highlight cursor line
set cursorline

" wrapping stuff
set textwidth=120 " autowrap at 120 characters
set colorcolumn=80
highlight ColorColumn ctermbg=darkmagenta

" set number of lines to always show when scrolling
set scrolloff=8

" ignore whitespace in diff mode
set diffopt+=iwhite

" Be able to arrow key and backspace across newlines
set whichwrap=bs<>[]

" make laggy connections work faster
set ttyfast

" let vim open up to 100 tabs at once
set tabpagemax=100

" case-insensitive filename completion
set wildignorecase

set nohlsearch "when there is a previous search pattern, highlight all its matches
set incsearch "while typing a search command, show immediately where the so far typed pattern matches
set ignorecase "ignore case in search patterns
set smartcase "override the 'ignorecase' option if the search pattern contains uppercase characters
"
" When auto-indenting, use the indenting format of the previous line
set copyindent
" When on, a <Tab> in front of a line inserts blanks according to 'shiftwidth'.
" 'tabstop' is used in other places. A <BS> will delete a 'shiftwidth' worth of
" space at the start of the line.
set smarttab
" Copy indent from current line when starting a new line (typing <CR> in Insert
" mode or when using the "o" or "O" command)
set autoindent
" Automatically inserts one extra level of indentation in some cases, and works
" for C-like files
set smartindent

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

" tab settings
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" set leader to Spacebar
nnoremap <space> <nop>
map <space> <leader>

" keep Ctrl-C behaviour consistent with Esc
inoremap <C-c> <Esc>

" Open file explorer with leader pf
nnoremap <leader>pf :Ex<CR>

" This won't work without gvim or nvim
" leader y yanks into system clipboard if supported by vim
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y

" leader d deletes into null register
nnoremap <leader>d "_d
vnoremap <leader>d "_d

