execute pathogen#infect()
syntax on
filetype plugin indent on
colorscheme solarized

"
" Use :help 'option' to see the documentation for an option. If you install
" scriptease.vim, you can press K on an option (or command, or function) to
" jump to its documentation.
"
set autoindent
set autoread
set autowrite
set background=dark
set colorcolumn=80
set nocompatible
set nocscopeverbose
set formatoptions=tcq
set hlsearch
set ignorecase
set incsearch
set linebreak
set list
set mouse=nvi
set number
set ruler
set showmatch
set smartcase
set nospell " spell check doesn't work with code
set textwidth=72
set wrap
set wrapscan

let mapleader=","

" #############################################################################
" This places the cursor in it's previous location after opening a file.
"
function! ResetCursor()
	if line("'\"") > 1 && line("'\"") <= line("$")
		normal! g'"
		return 1
	endif
endfunction

if has("autocmd")
	augroup resetCursor
		autocmd!
		au BufReadPost * call ResetCursor()
	augroup END
endif
" #############################################################################

" #############################################################################
" This will highlight trailing whitespace in red.
" See also: http://vim.wikia.com/wiki/Highlight_unwanted_spaces
"
if has("autocmd")
	highlight ExtraWhitespace ctermbg=red guibg=red
	match ExtraWhitespace /\s\+$/
	autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
	autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
	autocmd InsertLeave * match ExtraWhitespace /\s\+$/
"	autocmd BufWinLeave * call clearmatches()
endif
" #############################################################################
