" Plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.local/share/nvim/plugged')

Plug 'morhetz/gruvbox' " Theme

Plug 'ctrlpvim/ctrlp.vim' " The mighty CtrlP
Plug 'mbbill/undotree' " The migthy undo
Plug 'scrooloose/nerdtree' " Treeview of files (not that migthy as CtrlP ;) )
Plug 'vim-airline/vim-airline' " Bottom bar ;)
Plug 'vim-airline/vim-airline-themes' " Bottom bar themes

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

Plug 'parsonsmatt/intero-neovim' " Intero (Haskell)

" Consider deletion:
Plug 'ludovicchabant/vim-gutentags' " Automatic tagfile regeneration

" In-testing
Plug 'junegunn/fzf'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': './install.sh'
    \ }
Plug 'Shougo/echodoc.vim'
Plug 'sgur/vim-editorconfig'

Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'
Plug 'Shougo/neco-vim' | Plug 'ncm2/ncm2-vim'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'ncm2/ncm2-ultisnips'

" To be restored?
"Plug 'neomake/neomake' " :make and syntastic in one plugin

call plug#end()
" 

" Basic configuration
" 
" Compat
set nocompatible
set encoding=utf-8
set nobomb
filetype plugin indent on

" Color
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

set wildmenu
set wildignore+=.git " Common
set wildignore+=.cabal,.cabal-sandbox,dist " Haskell
set wildignore+=*.lock.json

set diffopt=filler,vertical

" Rulers
set textwidth=80
set colorcolumn=+1
set ruler
set nowrap

" Tabs and autoindentation
set tabstop=4
set shiftwidth=4
set shiftround
set autoindent
set expandtab

" Search
set incsearch
set ignorecase
set hlsearch
set gdefault
"
" Directories
set directory=~/.vim/swaps
set backupdir=~/.vim/backups
set tags=tags;/,codex.tags;/

set foldmethod=marker

let mapleader=','

" Fixups
let g:python_host_prog = "/usr/bin/python2"
let g:python3_host_prog = "/usr/bin/python3"

" Key bindings
" 

" Navigation, rebinds, helpers
" 
" Remove last-search, works like <C-/> in Terminator
map <silent> <C-_> :nohlsearch<CR>

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

" NCM2, UltiSnips
au User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
au User Ncm2PopupClose set completeopt=menuone

autocmd BufEnter * call ncm2#enable_for_buffer()
inoremap <silent> <expr> <CR> ncm2_ultisnips#expand_or("\<CR>", 'n')
inoremap <expr> <Tab> (pumvisible() ? "\<C-n>" : "\<Tab>")
inoremap <expr> <S-Tab> (pumvisible() ? "\<C-p>" : "\<S-Tab>")

"  Tagbar
nmap <silent> <F9> :TagbarToggle<CR>

"  Undotree
nmap <silent> <F10> :UndotreeToggle<CR>

"  CtrlP
nmap <silent> <Leader>p :CtrlPTag<CR>
nmap <silent> <Leader>P :CtrlPBufTagAll<CR>

"  EasyMotion
map s <Plug>(easymotion-s)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

"  Neoterm
nmap <silent> <Leader>tt <Plug>(neoterm-repl-send)
xmap <silent> <Leader>tt <Plug>(neoterm-repl-send)
" 

" Haskell
" 
augroup haskell_bindings
    autocmd!

    autocmd FileType haskell setlocal foldlevel=2
    autocmd FileType haskell setlocal textwidth=80

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
augroup END
" 
" 

" Plugin configs
" 
"  CtrlP
let g:ctrlp_map = '<C-P>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_buftag_types = {
    \ 'haskell': {
        \ 'bin': 'hasktags',
        \ 'args': '-x -c --ignore-close-implementation --file=-'
        \ }
    \ }
let g:ctrlp_extensions = ['tag', 'buffertag', 'dir']
let g:ctrlp_root_markers = ['.ctrlp']

" EasyMotion
let g:EasyMotion_do_mapping = 0
hi EasyMotionTarget ctermbg=none ctermfg=green
hi EasyMotionShade  ctermbg=none ctermfg=blue

" NerdTree
autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTreeType') && b:NERDTreeType == 'primary') | q | endif
let NERDTreeIgnore    = ['\.git[[dir]]', '\~$\', '\.cabal[[dir]]', 'dist[[dir]]']
let NERDTreeDirArrows = 1

" Airline and statusline
set laststatus=2
let g:airline_theme                         = 'gruvbox'
let g:airline_powerline_fonts               = 1
let g:airline#extensions#tagbar#enabled     = 1
let g:airline#extensions#hunks#enabled      = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#tabline#enabled    = 1

" Indent Guides
let g:indent_guides_guide_size            = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_exclude_filetypes     = ['help', 'nerdtree', 'ControlP']
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

"  Neomake
"autocmd! BufWritePost * Neomake

" haskell-vim
let g:haskell_enable_quantification   = 1
let g:haskell_enable_pattern_synonyms = 1
hi link haskellType Statement

" Gutentags
let g:gutentags_ctags_executable_haskell = expand('~/.vim/tools/hasktags_wrapper')
let g:gutentags_cache_dir                = '~/.vim/tags'

" Tabular
let g:haskell_tabular = 1

" GitGutter
let g:gitgutter_override_sign_column_highlight = 0

" Intero
autocmd BufWritePost *.hs InteroReload

" Neoterm
let g:neoterm_automap_keys = ''

" LanguageClient & NCM2
let g:LanguageClient_serverCommands = { 'haskell': ['hie-wrapper'] }
let g:LanguageClient_changeThrottle = 1
let g:LanguageClient_loggingLevel = 'INFO'

" UltiSnips
let g:UltiSnipsJumpForwardTrigger	= "<c-j>"
let g:UltiSnipsJumpBackwardTrigger	= "<c-k>"
let g:UltiSnipsRemoveSelectModeMappings = 0

