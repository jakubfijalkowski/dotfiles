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
Plug 'ludovicchabant/vim-gutentags' " Automatic tagfile regeneration

Plug 'junegunn/fzf' " FZF (CtrlP replacement)
Plug 'junegunn/fzf.vim'

Plug 'SirVer/ultisnips' " Ultisnip
Plug 'honza/vim-snippets'

Plug 'roxma/nvim-yarp' " NCM2
Plug 'ncm2/ncm2'
Plug 'ncm2/ncm2-path'
Plug 'ncm2/ncm2-vim' | Plug 'Shougo/neco-vim'
Plug 'ncm2/ncm2-ultisnips'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': './install.sh'
    \ }

Plug 'sgur/vim-editorconfig'
Plug 'takac/vim-hardtime'
Plug 'Shougo/echodoc.vim'
Plug 'parsonsmatt/intero-neovim'
Plug 'machakann/vim-highlightedyank'
Plug 'mhinz/vim-startify'
Plug 'airblade/vim-rooter'
Plug 'godlygeek/tabular'

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

" File mgmt & panels
nnoremap <silent> <C-P> :Files<CR>
nnoremap <silent> <leader>p :BTags<CR>
nnoremap <silent> <leader><S-P> :Tags<CR>

nmap <silent> <F8> :NERDTreeToggle<CR>
nmap <silent> <F9> :TagbarToggle<CR>
nmap <silent> <F10> :UndotreeToggle<CR>

" NCM2, UltiSnips
autocmd User Ncm2PopupOpen set completeopt=noinsert,menuone,noselect
autocmd User Ncm2PopupClose set completeopt=menuone
autocmd TextChangedI * call ncm2#auto_trigger()
autocmd BufEnter * call ncm2#enable_for_buffer()

"  LanguageClient
nnoremap <silent> gd :call GoToDefinition()<CR>
nnoremap <silent> <F2> :call LanguageClient_contextMenu()<CR>
nnoremap <silent> <F3> :call LanguageClient_textDocument_rename()<CR>
nnoremap <silent> <F4> :call LanguageClient_textDocument_references()<CR>
nnoremap <silent> <leader>= :call LanguageClient_textDocument_formatting()<CR>
vnoremap <silent> <leader>= :call LanguageClient_textDocument_rangeFormatting()<CR>

map s <Plug>(easymotion-s)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

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
hi EasyMotionTarget ctermbg=none ctermfg=green
hi EasyMotionShade  ctermbg=none ctermfg=blue

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

" Gutentags
let g:gutentags_ctags_executable_haskell = expand('~/.vim/tools/hasktags_wrapper')
let g:gutentags_ctags_executable_rust    = expand('~/.vim/tools/rusty_tags')
let g:gutentags_cache_dir                = '~/.vim/tags'
let g:gutentags_define_advanced_commands = 1

" Tabular
let g:haskell_tabular = 1

" GitGutter
let g:gitgutter_override_sign_column_highlight = 0

" Neoterm
let g:neoterm_automap_keys = ''

" LanguageClient & NCM2
let g:LanguageClient_autoStart         = 1
let g:LanguageClient_autoStop          = 1
let g:LanguageClient_changeThrottle    = 0.5
let g:LanguageClient_hasSnippetSupport = 1
let g:LanguageClient_loggingLevel      = 'INFO'
let g:LanguageClient_serverCommands    = {
    \ 'haskell': ['hie-wrapper'],
    \ 'rust': ['rustup', 'run', 'stable', 'rls'] }

" UltiSnips
let g:UltiSnipsExpandTrigger       = "<Plug>(ultisnips_expand_or_jump)"
let g:UltiSnipsJumpForwardTrigger  = "<Plug>(ultisnips_expand_or_jump)"
let g:UltiSnipsJumpBackwardTrigger = "<Plug>(ultisnips_jump_back)"
let g:UltiSnipsMappingsToIgnore    = [ "SelectModeTab", "ShiftTab" ]

" Based on https://github.com/YaLTeR/dotfiles/blob/master/common/.config/nvim/init.vim#L491-L552
inoremap <silent> <expr> <Tab> InsertModeTab()
inoremap <silent> <Plug>(ultisnips_try_expand) <C-R>=UltiSnipsExpandOrJumpOrTab()<CR>
inoremap <silent> <S-Tab> <C-R>=ShiftTab()<CR>

" Echodoc
set cmdheight=2
let g:echodoc#enable_at_startup = 1

" Other
let g:hardtime_default_on = 1
let g:hardtime_maxcount = 3
let g:startify_session_persistence = 1
let g:startify_fortune_use_unicode = 1

" Helpers
command! Reload source ~/.vimrc

function! UltiSnipsExpandOrJumpOrTab()
  call UltiSnips#ExpandSnippetOrJump()
  if g:ulti_expand_or_jump_res > 0
    return ""
  else
    return "\<Tab>"
  endif
endfunction

function! InsertModeTab()
  let b:prevent_next_auto_hover = 1
  return ncm2_ultisnips#expand_or("\<Plug>(ultisnips_try_expand)")
endfunction

function! ShiftTab()
  let b:prevent_next_auto_hover = 1
  return UltiSnips#JumpBackwards()
endfunction

function! GoToDefinitionHandler(output)
  if has_key(a:output, 'error')
    call searchdecl(expand('<cword>'))
  endif
endfunction

function! GoToDefinition()
  call LanguageClient#textDocument_definition({'handle': v:true}, 'GoToDefinitionHandler')
endfunction
