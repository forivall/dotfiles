set nocompatible

call plug#begin()

Plug 'tpope/vim-sensible'
" Plug 'chriskempson/base16-vim'
Plug 'chriskempson/vim-tomorrow-theme'
Plug 'sheerun/vim-polyglot'

call plug#end()

set guifont=Monospace\ 11

" my custom settings
set ignorecase
set smartcase

" A tab produces a 2-space indentation
set softtabstop=2
set shiftwidth=2
"set expandtab
"set noexpandtab
set tabstop=2

"set t_Co=256

:colorscheme Tomorrow-Night

" style "no-resize-handle"
" {
"     GtkWindow::resize-grip-height = 0
"     GtkWindow::resize-grip-width = 0
" }
" 
" class "GtkWidget" style "no-resize-handle"
