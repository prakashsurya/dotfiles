"
" Pathogen does not work in compatibility mode, so we must ensure this
" is not set, prior to attempting to use it.
"
" See also: https://github.com/tpope/vim-pathogen/issues/50
"
set nocompatible
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
set number
set ruler
set showmatch
set smartcase
set nospell " spell check doesn't work with code
set textwidth=72
set wrap
set wrapscan

let mapleader=","

"
" Configure the "vim-markdown-preview" plugin to use GitHub's API to
" generate the preview; this requires a network connection.
"
let vim_markdown_preview_github=1

"
" Configure the "command-t" plugin to use "git ls-files" to generate its
" list of files; this way, files in .gitignore are ignored.
"
" See also: https://github.com/wincent/command-t/blob/master/doc/command-t.txt
"
let g:CommandTFileScanner="git"

"
" Easy execution of Vimux commands, for running shell commands and
" utilities inside tmux panes.
"
map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vl :VimuxRunLastCommand<CR>
map <Leader>vi :VimuxInspectRunner<CR>
map <Leader>vz :VimuxZoomRunner<CR>
map <Leader>vq :VimuxCloseRunner<CR>
map <Leader>vs :VimuxInterruptRunner<CR>
map <Leader>vc :VimuxClearRunnerHistory<CR>

"
" To avoid reaching for the escape key, we create an alternate mapping
" for it while in insert mode.
"
imap kj <Esc>

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
