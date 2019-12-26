" Plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.local/share/nvim/plugged')

Plug 'morhetz/gruvbox' " Theme

Plug 'mbbill/undotree' " The migthy undo
Plug 'scrooloose/nerdtree' " Treeview of files
Plug 'vim-airline/vim-airline' " Bottom bar
Plug 'vim-airline/vim-airline-themes'

Plug 'kassio/neoterm' " :terminal helpers
Plug 'scrooloose/nerdcommenter' " Comments, the <leader>c* keys
Plug 'godlygeek/tabular' " Align lines
Plug 'easymotion/vim-easymotion' " ,s hotkey
Plug 'airblade/vim-gitgutter' " The git changes in gutter
Plug 'nathanaelkane/vim-indent-guides' " Well...
Plug 'sheerun/vim-polyglot' " Lang packs
Plug 'tpope/vim-repeat' " Fixup the . command
Plug 'tpope/vim-surround' " Take a textobj and change the quotes :D
Plug 'majutsushi/tagbar' " The mighty TagBar

Plug 'junegunn/fzf' " FZF (CtrlP replacement)
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-slash'

Plug 'neoclide/coc.nvim', {'branch': 'release'} " OMG, I love it
Plug 'neoclide/coc-pairs', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-yank', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'iamcco/coc-vimlsp', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-rust-analyzer', {'do': 'yarn install --frozen-lockfile'}

Plug 'honza/vim-snippets'
Plug 'neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile'}

Plug 'sgur/vim-editorconfig'
Plug 'takac/vim-hardtime'
Plug 'parsonsmatt/intero-neovim'
Plug 'machakann/vim-highlightedyank'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-rooter'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-fugitive'

Plug 'ryanoasis/vim-devicons'

Plug 'hashivim/vim-terraform'
Plug 'rust-lang/rust.vim'

call plug#end()
"

" Basic configuration
"
" Compat
set nocompatible
set encoding=utf-8
set nobomb
filetype plugin indent on

syntax enable
set termguicolors
set background=dark
colorscheme gruvbox

" Basic
set clipboard=unnamedplus
set showmode
set showcmd
set noerrorbells
set nostartofline
set title
set scrolloff=4
set hidden
set exrc
set number
set mouse=a
set mousehide
set splitbelow
set splitright
set autoread
set autowrite
set signcolumn=yes
set lazyredraw

set wildignore+=.git " Common
set wildoptions=pum
set wildignore+=.cabal,.cabal-sandbox,dist " Haskell
set wildignore+=*.lock.json

set diffopt=filler,vertical

" Rulers
set textwidth=100
set colorcolumn=+1
set ruler
set nowrap

" Tabs and autoindentation
set tabstop=4
set shiftwidth=4
set shiftround
set autoindent
set expandtab
autocmd FileType bash setlocal shiftwidth=2 tabstop=2
autocmd FileType zsh setlocal shiftwidth=2 tabstop=2

" Search
set incsearch
set ignorecase
set hlsearch
set gdefault

" Directories
set directory=~/.vim/swaps
set backupdir=~/.vim/backups
set tags=tags;/,codex.tags;/

set foldmethod=marker

" Line numbers
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

let mapleader=','

" Fixups
let g:python_host_prog = "/usr/bin/python2"
let g:python3_host_prog = "/usr/bin/python3"

" Key bindings
"

" Navigation, rebinds, helpers
"

" Easier navigation
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map zl zL
map zh zH

" Split management
nnoremap <silent> <S-Up> :resize +1<CR>
nnoremap <silent> <S-Down> :resize -1<CR>
nnoremap <silent> <S-Left> :vertical :resize -1<CR>
nnoremap <silent> <S-Right> :vertical :resize +1<CR>

nnoremap Y y$
tnoremap <Esc> <C-\><C-n>

" Plugins

" File mgmt & panels
nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader>p :BTags<CR>
nnoremap <silent> <leader><S-P> :Tags<CR>
nnoremap <silent> <leader>b :Buffers<CR>

nmap <silent> <F9> :NERDTreeToggle<CR>
nmap <silent> <F10> :TagbarToggle<CR>
nmap <silent> <F11> :UndotreeToggle<CR>

"  Coc
nnoremap <silent> gd :call CocAction('jumpDefinition')<CR>
nnoremap <silent> <F2> :call CocAction('rename')<CR>
nnoremap <silent> <F3> :CocFix<CR>
nnoremap <silent> <F4> :call CocAction('codeLensAction')<CR>
nnoremap <F5> :call CocAction('doHover')<CR>
nnoremap <silent> <Leader>= :call CocAction('format')<CR>

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

inoremap <silent><expr> <TAB>
    \ pumvisible() ? coc#_select_confirm() :
    \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

function! CocTagFunc(pattern, flags, info) abort
	if a:flags != "c"
		return v:null
	endif

	let name = expand("<cword>")
	execute("call CocAction('jumpDefinition')")
	let filename = expand('%:p')
	let cursor_pos = getpos(".")
	let cmd = '/\%'.cursor_pos[1].'l\%'.cursor_pos[2].'c/'
	execute("normal \<C-o>")
	return [ { 'name': name, 'filename': filename, 'cmd': cmd } ]
endfunction
set tagfunc=CocTagFunc

" EasyMotion
map s <Plug>(easymotion-bd-f)
nmap s <Plug>(easymotion-overwin-f)
map <Leader>j <Plug>(easymotion-jk)
map <Leader>k <Plug>(easymotion-jk)

"  Neoterm
nmap <silent> <Leader>tt <Plug>(neoterm-repl-send)
xmap <silent> <Leader>tt <Plug>(neoterm-repl-send)

" Haskell
"
augroup haskell_bindings
    autocmd!

    autocmd FileType haskell setlocal foldlevel=2
    autocmd FileType haskell setlocal textwidth=100

    autocmd FileType cabal setlocal foldlevel=2
    autocmd FileType cabal setlocal tabstop=2
    autocmd FileType cabal setlocal shiftwidth=2

    autocmd FileType haskell nnoremap <silent> <Leader>hs :%!stylish-haskell<CR>
    autocmd FileType haskell nnoremap <silent> <leader>hc :!codex update --force<CR>
    autocmd FileType haskell map <silent> <leader>ht <Plug>InteroGenericType
    autocmd FileType haskell map <silent> <leader>hT <Plug>InteroType
    autocmd FileType haskell nnoremap <silent> <leader>hit :InteroTypeInsert<CR>
    autocmd FileType haskell map <silent> <leader>ho :InteroOpen<CR>
    autocmd FileType haskell map <silent> <leader>hr :InteroReload<CR>
    autocmd FileType haskell map <silent> <leader>hcf :InteroLoadCurrentFile<CR>
    autocmd FileType haskell map <silent> <leader>hcm :InteroLoadCurrentModule<CR>

    autocmd BufWritePost *.hs InteroReload
augroup END
"
"

" Plugin configs

" FZF
let g:fzf_layout = { 'down': '20split' }
autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

" EasyMotion
let g:EasyMotion_do_mapping = 0
hi EasyMotionShade ctermbg=none ctermfg=blue

" NerdTree
autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTreeType') && b:NERDTreeType == 'primary') | q | endif
let NERDTreeIgnore    = ['\.git[[dir]]', '\~$\', '\.cabal[[dir]]', 'dist[[dir]]']
let NERDTreeDirArrows = 1

" Airline and statusline
set laststatus=2
let g:airline_theme                             = 'gruvbox'
let g:airline_powerline_fonts                   = 1
let g:airline#extensions#tagbar#enabled         = 1
let g:airline#extensions#hunks#enabled          = 1
let g:airline#extensions#whitespace#enabled     = 1
let g:airline#extensions#tabline#enabled        = 1
let g:airline#extensions#languageclient#enabled = 1
let g:airline#extensions#coc#enabled            = 1

" Indent Guides
let g:indent_guides_guide_size            = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_exclude_filetypes     = ['help', 'nerdtree', 'fzf']
let g:indent_guides_start_level           = 2

" Undotree
let g:undotree_WindowLayout       = 3
let g:undotree_SetFocusWhenToggle = 1
set undodir=~/.vim/undo
set undofile

" Tagbar
let g:tagbar_autofocus = 1
if executable('hasktags')
    let g:tagbar_type_haskell = {
        \ 'ctagsbin'  : 'hasktags',
        \ 'ctagsargs' : '-x -c -o-',
        \ 'kinds'     : [
            \  'm:modules:0:1',
            \  'd:data: 0:1',
            \  'd_gadt: data gadt:0:1',
            \  't:type names:0:1',
            \  'nt:new types:0:1',
            \  'c:classes:0:1',
            \  'cons:constructors:1:1',
            \  'c_gadt:constructor gadt:1:1',
            \  'c_a:constructor accessors:1:1',
            \  'ft:function types:1:1',
            \  'fi:function implementations:0:1',
            \  'o:others:0:1'
        \ ],
        \ 'sro'        : '.',
        \ 'kind2scope' : {
            \ 'm' : 'module',
            \ 'c' : 'class',
            \ 'd' : 'data',
            \ 't' : 'type'
        \ },
        \ 'scope2kind' : {
            \ 'module' : 'm',
            \ 'class'  : 'c',
            \ 'data'   : 'd',
            \ 'type'   : 't'
        \ }
    \ }
endif

" haskell-vim
let g:haskell_enable_quantification   = 1
let g:haskell_enable_pattern_synonyms = 1
hi link haskellType Statement

" Tabular
let g:haskell_tabular = 1

" GitGutter
let g:gitgutter_override_sign_column_highlight = 0

" Neoterm
let g:neoterm_automap_keys = ''

" Other
let g:hardtime_default_on          = 1
let g:hardtime_maxcount            = 5
let g:startify_session_persistence = 1
let g:startify_fortune_use_unicode = 1
let g:rooter_manual_only           = 1
let g:terraform_fmt_on_save        = 1

" Helpers
command! Reload source ~/.vimrc

