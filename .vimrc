if filereadable(expand('~/.vim/autoload/plug.vim'))
    call plug#begin('~/.vim/plugged')

    " run :PlugInstall to install new plugins
    Plug 'nvie/vim-flake8'
    Plug 'craigemery/vim-autotag'
    Plug 'taylor/vim-zoomwin'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'ivalkeen/vim-simpledb'
    Plug 'tonchis/vim-to-github'
    Plug 'fatih/vim-go'
    Plug 'psf/black'
    " Plug 'python-mode/python-mode', { 'for': 'python', 'branch': 'develop' }
    Plug 'pangloss/vim-javascript'
    Plug 'leafgarland/typescript-vim'
    Plug 'peitalin/vim-jsx-typescript'
    Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
    Plug 'jparise/vim-graphql'
    Plug 'prettier/vim-prettier', { 'do': 'yarn install', 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] }

    call plug#end()
endif

set nocompatible

" sane editing options
set tabstop=4                  " number of spaces that a <Tab> in the file counts for
set shiftwidth=4               " number of spaces to use for each step of (auto)indent
set expandtab
set whichwrap=b,s,h,l,<,>,[,]  " allow the cursor to wrap on anything
set backspace=2                " fully enable backspace to delete anything in insert mode
set noshowmatch                " don't go back to the matching bracket (annoying)
set exrc                       " use a local vimrc on a per-directory basis (for Vroom::Vroom support)
set secure                     " disable unsafe commands in project-specific .vimrc files
set tags+=.git/tags;~          " recursively look from current dir for a git dir with tags files

" enable syntax highlighting
syntax on                      " turn on syntax highlighting
filetype indent plugin on      " set indentation rules based on file type and enable filetype plugins (for matchit.vim)
syntax sync minlines=200       " always sync syntax highlighting at least 200 lines back
set t_Co=256                   " use 256 colors
"colorscheme default
colorscheme travis

" boldify the line number in the status line
hi User1 cterm=bold ctermfg=196 ctermbg=255 gui=bold guifg=#ff0000 guibg=#eeeeee

" just boldify the parenthese, to make it slightly clearer, don't knock me over the head or anything
hi clear MatchParen
hi MatchParen term=bold cterm=bold gui=bold

" search options
set hlsearch                   " highlight the search term
set ignorecase                 " search is case insensitive
set smartcase                  " override ignorecase if search contains uppercase characters
set incsearch                  " search as you type
set wrapscan                   " searches wrap around the end of the file

" no bells
set noerrorbells               " no freaking error bells ever!
set visualbell                 " turn on error beep/flash (turns off the audible bell)
set t_vb=                      " turn off terminal's visual bell

" gui options
set guioptions-=T              " no toolbar icons in gvim (ugly)
set mousehide                  " hide the mouse pointer while typing

" fix completion modes
set completeopt=menu,preview,longest " insert any common text for insert completion (and show a menu)
set wildmode=longest,list            " in ex mode, complete longest common string, then list alternatives (like bash)
"set diffopt-=iwhite                  " don't ignore whitespace in diffmode

" set up a real statusline
set statusline=%f\ %y%r%m%=col\ %c\ line\ %1*%l%*/%L " set up statusline to show file, read-only, modified, file type, and line number
set laststatus=2                            " always show the status line

ab pdb import pdb; pdb.set_trace()

function StyleCheck()
    if &filetype == 'python'
        " TODO: this should only get executed on files in source control
        " if executable('black')
        "     execute ':Black'
        " endif
        if executable('flake8')
            call Flake8()
        endif
    endif
endfunction

" set filetype for some more obscure file extensions
autocmd BufNewFile,BufRead *.t          set filetype=perl
autocmd BufNewFile,BufRead *.rhtml      set filetype=html              " interpret .rhtml files (embedded ruby templates) as html to get some highlighting
autocmd BufNewFile,BufRead *.yaml,*.yml set filetype=yaml
autocmd BufNewFile,BufRead *.go         set filetype=go
autocmd BufNewFile,BufRead *.pde        set filetype=cpp               " arduino cpp files
autocmd BufNewFile,BufRead *.txt        set tw=78                      " in text files, always limit the width of text to 78 characters
autocmd BufWritePost       *.py         call StyleCheck()              " call flake8 after write for python files
autocmd BufReadCmd *.egg,*.jar,*.xpi    call zip#Browse(expand("<amatch>")) " treat these file extensions as zip files for browsing

" set some options on a per-filetype basis
autocmd BufNewFile,BufRead,BufEnter /Users/tbeck/code/optimizely/* set tabstop=2 shiftwidth=2
autocmd FileType javascript,html,css,ruby,yaml,yml set expandtab tabstop=2 shiftwidth=2
autocmd FileType python set diffopt-=iwhite                  " don't ignore whitespace in python
autocmd FileType python,ruby set expandtab                   " indent with spaces
autocmd FileType go,perl set noexpandtab                     " indent with tabs

" sync the entire file for js since it seems to get out of sync a lot
autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

function GetCommentChar()
	let comment = {}
	let comment.sql        = '--'
	let comment.vim        = '"'
	let comment.css        = [ '\/\*', '\*\/' ]
	let comment.cpp        = '\/\/'
	let comment.javascript = '\/\/'
	let comment.go         = '\/\/'

	if !has_key(comment, &filetype)
		return [ '#', '' ]
	elseif type(comment[&filetype]) == type([])
		return comment[&filetype]
	elseif type(comment[&filetype]) == type('')
		return [ comment[&filetype], '' ]
	endif
endfunction
autocmd BufNewFile,BufRead * let [ b:comment_start, b:comment_end ] = GetCommentChar()

" toggle a comment for a line
" see http://www.perlmonks.org/?node_id=561215 for more info
function ToggleComment()

	" if the comment start is at the beginning of the line and isn't followed
	" by a space (i.e. the most likely form of an actual comment, to keep from
	" uncommenting real comments
	if getline('.') =~ ('^' . b:comment_start . '\( \w\)\@!')
		execute 's/^' . b:comment_start . '//'
		execute 's/' . b:comment_end . '$//'
	else
		execute 's/^/' . b:comment_start . '/'
		execute 's/$/' . b:comment_end . '/'
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

" set up emacs/readline style command line editing keys (see :help emacs-keys)
" start of line
cnoremap <C-A>    <Home>
" end of line
cnoremap <C-E>    <End>
" back one character
cnoremap <C-B>    <Left>
" forward one character
cnoremap <C-F>    <Right>
" delete character under cursor
cnoremap <C-D>    <Del>
" back one word
cnoremap <Esc>b    <S-Left>
" forward one word
cnoremap <Esc>f    <S-Right>
" delete back one word
cmap <Esc><C-?> <M-BS>
cmap <Esc><C-h> <M-BS>
cmap <Esc><BS> <M-BS>
cnoremap <M-BS>    <C-W>
" remap ctrl-p/ctrl-n in command mode to take whatever text has already been
" entered and search with that (what up/down do by default)
cnoremap <C-P> <Up>
cnoremap <C-N> <Down>

" Maximum number of tab pages to be opened by -p
set tabpagemax=100

" map Left/Right to switch tabs
nnoremap <Left> :tabprevious<CR>
nnoremap <Right> :tabnext<CR>

" switch all open buffers to tabs
"nnoremap v :vertical unhide<CR>:tabo<CR>
"
" switch all tabs to vertical split
"nnoremap t :tab unhide<CR>

" map Alt-Left/Alt-Right to move the current tab left/right
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

" make '-' hide a buffer
let g:zappedbuffers = []
function! ZapBuffer()
    call add(g:zappedbuffers, bufnr('%'))
    hide
endfunction
command! ZapBuffer call ZapBuffer()
nnoremap <silent> - :call ZapBuffer()<cr>

" and make '+' unhide it in a vertical split
function! UnzapBuffer()
    if len(g:zappedbuffers) > 0
      let num = g:zappedbuffers[0]
      let g:zappedbuffers = g:zappedbuffers[1:]
      execute 'vert sb ' . num
    endif
endfunction
nnoremap <silent> + :call UnzapBuffer()<cr>

" map C-Enter to open tags in a new tab
nnoremap  <C-w><C-]><C-w>T

" set filename in the screen status line if we are using screen
" see http://www.vim.org/tips/tip.php?tip_id=1126
autocmd BufEnter * let &titlestring = expand("%:t")

if &term == "screen" || &term == "screen-bce"
	set t_ts=k
	set t_fs=\
endif

if &term == "screen" || &term == "xterm" || &term == "screen-bce"
	set title
endif
let &titleold = fnamemodify(getcwd(), ':~:t')

" highlight questionable whitespace differently depending on whether
" or not expandtab is set
highlight QuestionableWhitespace ctermbg=green guibg=green
autocmd BufNewFile,BufRead * call HighlightWhitespace()
function HighlightWhitespace()
	if &expandtab
		" highlight tabs not at the beginning of the line (but allow # for comments and % for mason),
		" and trailing whitespace not followed by the cursor
		" (maybe think about highlighting leading spaces not in denominations of tabstop?)
		match QuestionableWhitespace /^\t+\|\(^[%#]\?\t*\)\@<!\t\|[ \t]\+\(\%#\)\@!$/
	else
		" highlight any leading spaces (TODO: ignore spaces in formatted assignment statements),
		" tabs not at the beginning of the line (but allow # for comments and % for mason),
		" and trailing whitespace not followed by the cursor
		match QuestionableWhitespace /^ \+\|\(^[%#]\?\t*\)\@<!\t\|[ \t]\+\(\%#\)\@!$/
	endif
endfunction

" highlight long lines - see http://vim.wikia.com/wiki/Highlight_long_lines
highlight LongLines ctermbg=lightgrey guibg=lightgrey
"autocmd FileType python 2match LongLines /^.\{120,\}$/
"autocmd BufWinEnter * let w:m1=matchadd('Search', '\%<121v.\%>77v', -1)
autocmd BufWinEnter *.py let w:m2=matchadd('LongLines', '\%>120v.\+', -1)

" plugins
source $VIMRUNTIME/macros/matchit.vim    " allow % to match anything that filetype plugins can, not just '{' or '(' or '['

" figure out a way to open multiple buffers by default in vertical split
"vertical ball                            " if multiple buffers were opened, vertically split the screen to show all of them

runtime plugin/vcscommand.vim
function! Diffbranch()
    let mergebase = system('git merge-base origin/master HEAD')
    execute VCSVimDiff mergebase
endfunction
"com! -nargs=* Diff call Diffbranch()

function! Mergebase(...)
    let mergebase = system('git merge-base ' . a:1 . ' HEAD')
    let cmd = 'VCSVimDiff ' . mergebase
    return mergebase
endfunction

function! DiffAllTabs(...)
    if(a:0 > 0)
        let mergebase = system('git merge-base ' . a:1 . ' HEAD')
        echo mergebase
        let cmd = 'VCSVimDiff ' . mergebase
        echo cmd
        execute cmd
    endif
endfunction
com! -nargs=* Diffbase call DiffAllTabs(<f-args>)

" CtrlP
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_switch_buffer = 'etvh'
let g:ctrlp_custom_ignore = { 'dir': '\.git$\|\.hg$\|\.svn$' }
let g:ctrlp_user_command = {
  \ 'types': {
    \ 1: ['.git', 'cd %s && git ls-files . -co --exclude-standard'],
  \ },
  \ 'fallback': 'find %s -type f'
\ }
" default to opening in new tab
let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-t>'],
    \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
    \ }

