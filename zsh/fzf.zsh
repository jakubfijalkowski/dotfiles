function _fd_base() {
  fd --max-depth=3 --follow --type=$1 ${@:2}
}

function _fd_filter() {
  # Special-case some of the usages
  case "$2" in
    '~'*)
      # Expand and then collapse `~` at the beginning of the search string and then re-check it
      local res="$(_fd_filter $1 "${2/#\~/$HOME}")"
      echo ${res//$HOME/\~}
      ;;
    (../)##(..)#)
      # Parent dir, handle manually as `dirname` fails to handle that correctly
      _fd_base $1 . $2
      ;;
    *.|.*|*/.[^/]#)
      # Search for hidden also
      _fd_base $1 --hidden . "$(dirname "$2")"
      ;;
    *)
      # All the rest
      _fd_base $1 . "$(dirname "$2")"
      ;;
  esac
}

function _files() {
    local tokens=(${(z)LBUFFER})
    [ "${LBUFFER[-1]}" = ' ' ] && tokens+=("")
    local query="${tokens[-1]}"
    local result=("${(@f)$(_fd_filter f "$query")}")
    compadd -a -f result
}
function _fzf_compgen_path() { _fs_base f . "$1" }

function _cd() {
    local tokens=(${(z)LBUFFER})
    [ "${LBUFFER[-1]}" = ' ' ] && tokens+=("")
    local query="${tokens[-1]}"
    local result=("${(@f)$(_fd_filter d "$query")}")
    compadd -a -f result
}
function _fzf_compgen_dir() { _fd_base d . "$1" }

export FZF_DEFAULT_COMMAND='_fd_base f'
export FZF_ALT_C_COMMAND='_fd_base d'

source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

bindkey '\t' expand-or-complete        # fzf-tab reads it during initialization
z4h source $ZSH_CACHE_DIR/Aloxaf/fzf-tab/fzf-tab.plugin.zsh

zstyle ':fzf-tab:*' show-group full
zstyle ':fzf-tab:*' single-group full
zstyle ':fzf-tab:*' prefix ''
zstyle ':fzf-tab:*' continuous-trigger 'alt-enter'

# Previews for some commands
local extract="
in=\${\${\"\$(<{f})\"%\$'\0'*}#*\$'\0'}
local -A ctxt=(\"\${(@ps:\2:)CTXT}\")
"
local sanitized_in='${~ctxt[hpre]}"${${in//\\ / }/#\~/$HOME}"'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always '$sanitized_in --preview-window=right:40%
zstyle ':fzf-tab:complete:exa:*' extra-opts --preview=$extract'exa -1 --color=always '$sanitized_in --preview-window=right:40%
zstyle ':fzf-tab:complete:vim:*' extra-opts --preview=$extract'bat --pager=never --color=always --line-range :30 '$sanitized_in --preview-window=right:70%
