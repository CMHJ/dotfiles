" designed for vim 8+
let skip_defaults_vim=1
set nocompatible

" Just the defaults, these are changed per filetype by plugins.
" Most of the utility of all of this has been superceded by the use of
" modern simplified pandoc for capturing knowledge source instead of
" arbitrary raw text files.

set formatoptions-=t   " don't auto-wrap text using text width
set formatoptions+=c   " autowrap comments using textwidth with leader
set formatoptions-=r   " don't auto-insert comment leader on enter in insert
set formatoptions-=o   " don't auto-insert comment leader on o/O in normal
set formatoptions+=q   " allow formatting of comments with gq
set formatoptions-=w   " don't use trailing whitespace for paragraphs
set formatoptions-=a   " disable auto-formatting of paragraph changes
set formatoptions-=n   " don't recognized numbered lists
set formatoptions+=j   " delete comment prefix when joining
set formatoptions-=2   " don't use the indent of second paragraph line
set formatoptions-=v   " don't use broken 'vi-compatible auto-wrapping'
set formatoptions-=b   " don't use broken 'vi-compatible auto-wrapping'
set formatoptions+=l   " long lines not broken in insert mode
set formatoptions+=m   " multi-byte character line break support
set formatoptions+=M   " don't add space before or after multi-byte char
set formatoptions-=B   " don't add space between two multi-byte chars in join 
set formatoptions+=1   " don't break a line after a one-letter word

"####################### Vi Compatible (~/.exrc) #######################

" automatically indent new lines
set autoindent

" automatically write files when changing when multiple files open
set autowrite

" activate line numbers
set number

" turn col and row position on in bottom right
set ruler

" show command and insert mode
set showmode

set tabstop=4

"#######################################################################

" Set theme for editor
"colo delek
"colo pablo
"colo elflord
colo ron
set background=dark

set softtabstop=4
set shiftwidth=4
set smartindent
set smarttab

" replace tabs with spaces automatically
set expandtab

" enough for line numbers + gutter within 80 standard
set textwidth=72 

" disable relative line numbers, remove no to sample it
"set norelativenumber
set relativenumber

" easier to see characters when `set paste` is on
set listchars=tab:→\ ,eol:↲,nbsp:␣,space:·,trail:·,extends:⟩,precedes:⟨

" turn on default spell checking
"set spell 
set spelllang=en_au

" more risky, but cleaner
"set nobackup
set noswapfile
"set nowritebackup

" keep the terminal title updated
set laststatus=0
set icon

" center the cursor always on the screen
" set scrolloff=999

" prevents truncated yanks, deletes, etc.
set viminfo='20,<1000,s1000

" Allow autocomplete menu
set wildmenu

" stop complaints about switching buffer with changes
set hidden

" command history
set history=100

" here because plugins and stuff need it
syntax enable

" faster scrolling
set ttyfast

" Esc shortcut for insert mode
inoremap jk     <Esc>

" Mapping timeout
set timeout timeoutlen=250

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" Autoclose parentheses
"inoremap {      {<Space><Space>}<Left><Left>
"inoremap {<CR>  {<CR>}<Esc>O
"inoremap {{     {
"inoremap {}     {}
"inoremap {;<CR> {<CR>};<ESC>O

"inoremap (      ()<Left>
"inoremap (<CR>  (<CR>)<Esc>O
"inoremap ((     (
"inoremap ()     ()

"inoremap [      []<Left>
"inoremap [<CR>  [<CR>]<Esc>O
"inoremap [[     [
"inoremap []     []

" inoremap "      ""<Left>
" inoremap ""     "

" inoremap '      ''<Left>
" inoremap ''     '

" allow sensing the filetype
filetype plugin on

" Install vim-plug if not already installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

" only load plugins if Plug detected
if filereadable(expand("~/.vim/autoload/plug.vim"))
  call plug#begin('~/.vimplugins')
  Plug 'junegunn/goyo.vim'
  Plug 'vim-pandoc/vim-pandoc'
  Plug 'https://gitlab.com/rwxrob/vim-pandoc-syntax-simple'
  "Plug 'https://gitlab.com/rwx.gg/abnf'
  "Plug 'cespare/vim-toml'
  "Plug 'pangloss/vim-javascript'
  Plug 'rust-lang/rust.vim'
  Plug 'fatih/vim-go'
  "Plug 'PProvost/vim-ps1'
  "Plug 'airblade/vim-gitgutter'
  "Plug 'morhetz/gruvbox'
  call plug#end()
  let g:pandoc#formatting#mode = 'h' " A'
  let g:pandoc#formatting#textwidth = 72
  let g:go_fmt_fail_silently = 0 " let me out even with errors
  let g:go_fmt_command = 'goimports' " autoupdate import
  let g:go_fmt_autosave = 1
else
  autocmd vimleavepre *.go !gofmt -w % " backup if fatih fails
endif

autocmd vimleavepre *.rs !rustfmt %

" Remappings
nmap <C-g> :Goyo<CR>

" Detecting filetypes
augroup pandoc_syntax
  au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc
augroup END
