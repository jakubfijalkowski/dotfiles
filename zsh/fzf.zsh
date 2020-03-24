export FZF_DEFAULT_COMMAND='fd --max-depth=3 --type=f'
export FZF_ALT_C_COMMAND='fd --max-depth=3 --type=d'

function _fs_filter() {
  # Special-case some of the usages
  case "$2" in
    '~'*)
      # Expand and then collapse `~` at the beginning of the search string
      local res="$(fd --max-depth=3 --type=$1 . "$(dirname "${2/#\~/$HOME}")")"
      echo ${res//$HOME/\~}
      ;;
    ..|../)
      fd --max-depth=3 --type=$1 . ..
      ;;
    *)
      fd --max-depth=3 --type=$1 . "$(dirname "$2")"
      ;;
  esac
}
function _fs_select() {
  fd --max-depth=3 --type=$1 . $2
}
function _files() {
    local tokens=(${(z)LBUFFER})
    [ "${LBUFFER[-1]}" = ' ' ] && tokens+=("")
    local query="${tokens[-1]}"
    local result=("${(@f)$(_fs_filter f "$query")}")
    compadd -a -f result
}
function _fzf_compgen_path() { _fs_select f "$1" }

function _cd() {
    local tokens=(${(z)LBUFFER})
    [ "${LBUFFER[-1]}" = ' ' ] && tokens+=("")
    local query="${tokens[-1]}"
    local result=("${(@f)$(_fs_filter d "$query")}")
    compadd -a -f result
}
function _fzf_compgen_dir() { _fs_select d "$1" }

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

bindkey '\t' expand-or-complete        # fzf-tab reads it during initialization
source $ZSH_CACHE_DIR/fzf-tab/fzf-tab.plugin.zsh

zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' single-group full
zstyle ':fzf-tab:*' prefix ''

# Previews for some commands
local extract="
in=\${\${\"\$(<{f})\"%\$'\0'*}#*\$'\0'}
local -A ctxt=(\"\${(@ps:\2:)CTXT}\")
"
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always ${~ctxt[hpre]}"${${in//\\ / }/#\~/$HOME}"'
zstyle ':fzf-tab:complete:vim:*' extra-opts --preview=$extract'bat --pager=never --color=always --line-range :30 ${~ctxt[hpre]}"${in//\\ / }"' --preview-window=right:70%
