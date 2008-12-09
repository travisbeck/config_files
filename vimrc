set nocompatible

set tabstop=4
set shiftwidth=4

syntax on                      " turn on syntax highlighting
filetype indent plugin on      " set indentation rules based on file type and enable filetype plugins (for matchit.vim)

"set foldenable
"set foldmethod=syntax

" search options
set hlsearch                   " highlight the search term
set ignorecase                 " search is case insensitive
set incsearch                  " search as you type
set wrapscan                   " searches wrap around the end of the file
set whichwrap=b,s,h,l,<,>,[,]  " allow the cursor to wrap on anything
set backspace=2                " fully enable backspace to delete anything in insert mode

set noshowmatch                " don't go back to the matching bracket (annoying)
let loaded_matchparen = 1      " don't show matching parens in vim 7+

set statusline=%f\ %y%r%m%=line\ %l/%L " set up statusline to show file, read-only, modified, file type, and line number
set laststatus=2                       " always show the status line
" make the status line in an active window white on red, and black on white in non-active
highlight StatusLine   term=NONE cterm=NONE ctermfg=red ctermbg=white guifg=red guibg=white
highlight StatusLineNC term=NONE cterm=NONE ctermfg=black ctermbg=white guifg=black guibg=white 

" hide the mouse pointer while typing
set mousehide

set noerrorbells        " no freaking error bells ever!
set visualbell          " turn on error beep/flash
set t_vb=				" turn off terminal's visual bell
set t_Co=256            " enable 256 colors

set guioptions-=T              " no toolbar icons in gvim (ugly)

set completeopt+=longest       " insert any common text for insert completion
set wildmode=longest,list      " in ex mode, complete longest common string, then list alternatives (like bash)
set diffopt+=iwhite            " ignore whitespace in diffmode

" always sync syntax highlighting at least 200 lines back
syn sync minlines=200

" set filetype to 'perl' for .t files
au BufNewFile,BufRead *.t set filetype=perl

" set filetype to 'html' for .rhtml files (embedded ruby templates)
au BufNewFile,BufRead *.rhtml set filetype=html

" In text files, always limit the width of text to 78 characters
autocmd BufRead *.txt set textwidth=78

" for CSS and HTML, indent using 2 spaces
autocmd FileType html,css,ruby set expandtab tabstop=2 shiftwidth=2

autocmd BufNewFile,BufRead *.yaml,*.yml set filetype=yaml

" for yaml, don't ever use tabs to indent
autocmd FileType yaml,yml set expandtab tabstop=2 shiftwidth=2

" for Mason files, tabs are 2 spaces wide
autocmd FileType mason set tabstop=2 shiftwidth=2

" toggle a comment at the beginning of the line
" see http://www.perlmonks.org/?node_id=561215 for more info
function ToggleComment() 
	let comment_start = '#'
	let comment_end   = ''

	if &filetype == 'sql'
		let comment_start = '--'
	endif
	if &filetype == 'vim'
		let comment_start = '"'
	endif
	if &filetype == 'css'
		let comment_start = '\/\* '
		let comment_end   = ' \*\/'
	endif
	if &filetype == 'javascript'
		let comment_start = '\/\/'
	endif

	if getline('.') =~ ('^' . comment_start)
		execute 's/^' . comment_start . '//'
		execute 's/' . comment_end . '$//'
	else
		s/^/\=comment_start/
		s/$/\=comment_end/
	endif
endfunction
map <silent> X :call ToggleComment()<cr>j

" remap tab to autocomplete words when not at the beginning of a line
function InsertTabWrapper() 
	let col = col('.') - 1 
	if !col || getline('.')[col - 1] !~ '\k' 
		return "\<tab>" 
	else 
		return "\<c-p>" 
	endif 
endfunction 

inoremap <tab> <c-r>=InsertTabWrapper()<cr>

" set filename in the screen status line if we are using screen
" see http://www.vim.org/tips/tip.php?tip_id=1126
autocmd BufEnter * let &titlestring = expand("%:t")

if &term == "screen"
	set t_ts=k
	set t_fs=\
endif

if &term == "screen" || &term == "xterm"
	set title
endif 

" allow % to match anything that filetype plugins can, not just '{' or '(' or '['
source $VIMRUNTIME/macros/matchit.vim
