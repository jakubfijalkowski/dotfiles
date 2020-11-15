" Plugins
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.local/share/nvim/plugged')

Plug 'morhetz/gruvbox'                                                           " Theme

Plug 'mbbill/undotree'                                                           " The migthy undo
Plug 'scrooloose/nerdtree'                                                       " Treeview of files
Plug 'vim-airline/vim-airline'                                                   " Bottom bar
Plug 'vim-airline/vim-airline-themes'

Plug 'scrooloose/nerdcommenter'                                                  " Comments, the <leader>c* keys
Plug 'godlygeek/tabular'                                                         " Align lines
Plug 'easymotion/vim-easymotion'                                                 " ,s hotkey
Plug 'airblade/vim-gitgutter'                                                    " The git changes in gutter
Plug 'nathanaelkane/vim-indent-guides'                                           " Well...
Plug 'sheerun/vim-polyglot'                                                      " Lang packs
Plug 'tpope/vim-repeat'                                                          " Fixup the . command
Plug 'tpope/vim-surround'                                                        " Take a textobj and change the quotes :D
Plug 'ryanoasis/vim-devicons'                                                    " Icon pack
Plug 'takac/vim-hardtime'                                                        " Force me to use proper movements
Plug 'machakann/vim-highlightedyank'                                             " Show me what have I yanked
Plug 'mhinz/vim-startify'                                                        " Start page
Plug 'tpope/vim-fugitive'                                                        " I'm yet to get used to it
Plug 'airblade/vim-rooter'                                                       " Find the root, esp. with/ startify
Plug 'editorconfig/editorconfig-vim'                                             " It should work someday
Plug 'qpkorr/vim-bufkill'                                                        " bdelete override with sanity

Plug 'junegunn/fzf'                                                              " FZF (CtrlP replacement)
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-slash'

Plug 'neoclide/coc.nvim',             { 'branch': 'release' }                    " OMG, I love it
Plug 'neoclide/coc-json',             { 'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-pairs',            { 'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-snippets',         { 'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-yaml',             { 'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-yank',             { 'do': 'yarn install --frozen-lockfile'}
Plug 'iamcco/coc-vimlsp',             { 'do': 'yarn install --frozen-lockfile && yarn build'}
Plug 'fannheyward/coc-rust-analyzer', { 'do': 'yarn install --frozen-lockfile'}
Plug 'honza/vim-snippets'
Plug 'antoinemadec/coc-fzf'

Plug 'rust-lang/rust.vim'
Plug 'hashivim/vim-terraform'

Plug 'liuchengxu/vista.vim'

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
set inccommand=nosplit
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
nnoremap <silent> <leader>p :CocFzfList symbols<CR>
nnoremap <silent> <leader>b :Buffers<CR>

nnoremap <silent> <F9> :NERDTreeFocus<CR>
nnoremap <silent> <F10> :UndotreeToggle<CR>
nnoremap <silent> <F11> :Vista!!<CR>
nnoremap <silent> <F12> :CocFzfList commands<CR>

let g:NERDTreeMapOpenSplit = '<C-x>'
let g:NERDTreeMapPreviewSplit = '<C-X>'
let g:NERDTreeMapOpenVSplit = '<C-v>'
let g:NERDTreeMapPreviewVSplit = '<C-V>'
nnoremap <silent> gr :NERDTreeFind<CR>

"  Coc
set tagfunc=CocTagFunc

nmap <silent> <F2> <Plug>(coc-rename)
nnoremap <silent> <F3> :CocFzfList diagnostics<CR>
nmap <silent> <F4> <Plug>(coc-codelens-action)
vmap <silent> <F5> <Plug>(coc-codeaction-selected)
nmap <silent> <F5> <Plug>(coc-codeaction-selected)l
inoremap <F5> <C-o>:call CocActionAsync('codeAction', 'char')<CR>

nmap <silent> <leader>= <Plug>(coc-format)
nmap <silent> <leader>qf <Plug>(coc-fix-current)

nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> K :call <SID>show_documentation()<CR>

inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

let g:coc_snippet_next = '<tab>'

inoremap <silent><expr> <TAB>
    \ pumvisible() ? coc#_select_confirm() :
    \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ coc#refresh()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')

" EasyMotion
map s <Plug>(easymotion-bd-f)
nmap s <Plug>(easymotion-overwin-f)
map <Leader>j <Plug>(easymotion-jk)
map <Leader>k <Plug>(easymotion-jk)

" Haskell
augroup haskell_bindings
    autocmd!

    autocmd FileType haskell setlocal foldlevel=2
    autocmd FileType haskell setlocal textwidth=100

    autocmd FileType cabal setlocal foldlevel=2
    autocmd FileType cabal setlocal tabstop=2
    autocmd FileType cabal setlocal shiftwidth=2

    autocmd FileType haskell nnoremap <silent> <Leader>hs :%!stylish-haskell<CR>
    autocmd FileType haskell nnoremap <silent> <leader>hc :!codex update --force<CR>
augroup END

" Rust
augroup rust_bindings
    autocmd!
    autocmd FileType rust let b:coc_root_patterns = ['Cargo.toml']
augroup END

" Terraform
augroup terraform_bindings
    autocmd!
    autocmd FileType terraform let b:coc_root_patterns = ['main.tf']
augroup END

" Plugin configs

" FZF
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
augroup fzf
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
                \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
    autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
augroup END

" EasyMotion
let g:EasyMotion_do_mapping = 0
hi EasyMotionShade ctermbg=none ctermfg=blue

" NerdTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeIgnore    = ['\.git[[dir]]', '\~$\', '\.cabal[[dir]]', 'dist[[dir]]', 'target[[dir]]']
let NERDTreeDirArrows = 1

" Airline and statusline
set laststatus=2
let g:airline_theme                         = 'gruvbox'
let g:airline_powerline_fonts               = 1
let g:airline_highlighting_cache            = 1
let g:airline#extensions#hunks#enabled      = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#tabline#enabled    = 1
let g:airline#extensions#coc#enabled        = 1
let g:airline_extensions = [
      \ 'branch', 'coc', 'fugitiveline', 'fzf', 'quickfix', 'tabline',
      \ 'term', 'undotree', 'vista', 'whitespace'
      \ ]

" Indent Guides
let g:indent_guides_guide_size            = 1
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_exclude_filetypes     = ['help', 'nerdtree', 'fzf', '__vista__']
let g:indent_guides_start_level           = 2

" Undotree
let g:undotree_WindowLayout       = 3
let g:undotree_SetFocusWhenToggle = 1
set undodir=~/.vim/undo
set undofile

let g:vista#renderer#enable_icon = 1
let g:vista_default_executive    = 'coc'
let g:vista_disable_statusline   = 1
let g:vista_echo_cursor_strategy = 'floating_win'
let g:vista_fzf_preview          = ['bottom:50%']
let g:vista_sidebar_width        = 40
let g:vista_rust_executive       = 'ctags'

" Other
let g:EditorConfig_exclude_patterns            = ['fugitive://.*']
let g:gitgutter_override_sign_column_highlight = 0
let g:hardtime_default_on                      = 1
let g:hardtime_ignore_buffer_patterns          = ['NERD.*', '__vista__']
let g:hardtime_maxcount                        = 5
let g:rooter_manual_only                       = 1
let g:rooter_patterns                          = ['Cargo.toml', '.git/']
let g:startify_change_to_dir                   = 1
let g:startify_fortune_use_unicode             = 1
let g:startify_session_persistence             = 1
let g:terraform_fmt_on_save                    = 1

" Helpers
command! Reload source ~/.vimrc
