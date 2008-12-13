set nocompatible

" sane editing options
set tabstop=4                  " number of spaces that a <Tab> in the file counts for
set shiftwidth=4               " number of spaces to use for each step of (auto)indent
set whichwrap=b,s,h,l,<,>,[,]  " allow the cursor to wrap on anything
set backspace=2                " fully enable backspace to delete anything in insert mode
set noshowmatch                " don't go back to the matching bracket (annoying)
let loaded_matchparen = 1      " don't show matching parens in vim 7+

" enable syntax highlighting
syntax on                      " turn on syntax highlighting
filetype indent plugin on      " set indentation rules based on file type and enable filetype plugins (for matchit.vim)
syntax sync minlines=200       " always sync syntax highlighting at least 200 lines back

" search options
set hlsearch                   " highlight the search term
set ignorecase                 " search is case insensitive
set smartcase                  " override ignorecase if search contains uppercase characters
set incsearch                  " search as you type
set wrapscan                   " searches wrap around the end of the file

" no bells
set noerrorbells        " no freaking error bells ever!
set visualbell          " turn on error beep/flash
set t_vb=               " turn off terminal's visual bell

" gui options
set guioptions-=T              " no toolbar icons in gvim (ugly)
set mousehide                  " hide the mouse pointer while typing

" fix completion modes
set completeopt+=longest       " insert any common text for insert completion
set wildmode=longest,list      " in ex mode, complete longest common string, then list alternatives (like bash)
set diffopt+=iwhite            " ignore whitespace in diffmode

" set up a real statusline
set statusline=%f\ %y%r%m%=line\ %1*%l%*/%L " set up statusline to show file, read-only, modified, file type, and line number
set laststatus=2                            " always show the status line

" tweak statusline highlighting
highlight StatusLine   term=NONE cterm=NONE ctermfg=darkred ctermbg=lightgrey guifg=darkred guibg=lightgrey
highlight StatusLineNC term=NONE cterm=NONE ctermfg=black ctermbg=white guifg=black guibg=white 
highlight User1        term=bold cterm=bold ctermfg=red ctermbg=lightgrey

" set filetype for some more obscure file extensions
autocmd BufNewFile,BufRead *.t       set filetype=perl
autocmd BufNewFile,BufRead *.md,*.mh set filetype=mason         " shutterstock convention for mason components
autocmd BufNewFile,BufRead *.rhtml   set filetype=html          " interpret .rhtml files (embedded ruby templates) as html to get some highlighting
autocmd BufNewFile,BufRead *.yaml,*.yml set filetype=yaml
autocmd BufNewFile,BufRead *.txt     set tw=78                  " in text files, always limit the width of text to 78 characters

" set some options on a per-filetype basis
"autocmd FileType html,css set expandtab tabstop=2 shiftwidth=2        " for CSS and HTML, indent using 2 spaces
"autocmd FileType mason set tabstop=2 shiftwidth=2                     " for mason files, tabs are 2 spaces wide (cause that's dan's preference)
autocmd FileType yaml,yml set expandtab tabstop=2 shiftwidth=2         " for yaml, always use two spaces to indent
autocmd FileType perl,mason set iskeyword+=: path=.,/home/ssuser/lib/  " in perl/mason use ':' as a word character (for module names)

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

" highlight leading spaces (indent with tabs thanks),
" tabs not at the beginning of the line (allow % as in mason files), and trailing spaces or tabs
highlight InvalidWhitespace ctermbg=green guibg=green
match InvalidWhitespace /^ \+\|\(^[%#]\?\t*\)\@<!\t\|[ \t]\+$/

" plugins
source $VIMRUNTIME/macros/matchit.vim    " allow % to match anything that filetype plugins can, not just '{' or '(' or '['
