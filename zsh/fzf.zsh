# Show '...' while completing. No `emulate -L zsh` to pick up dotglob if it's set.
FZF_COMPLETION_TRIGGER=''              # ctrl-t goes to fzf whenever possible

export FZF_DEFAULT_COMMAND='fd --type=f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type=d'
_fzf_compgen_path() { fd --type=f . "$1" }
_fzf_compgen_dir() { fd --type=d . "$1" }

zinit snippet /usr/share/fzf/completion.zsh
zinit snippet /usr/share/fzf/key-bindings.zsh
bindkey -r '^[c'                       # remove unwanted binding

FZF_TAB_PREFIX=                        # remove '·'
FZF_TAB_SHOW_GROUP=brief               # show group headers only for duplicate options
FZF_TAB_SINGLE_GROUP=()                # no colors and no header for a single group
FZF_TAB_CONTINUOUS_TRIGGER='alt-enter' # alt-enter to accept and trigger another completion
bindkey '\t' expand-or-complete        # fzf-tab reads it during initialization

zinit light Aloxaf/fzf-tab

# (experimental, may change in the future)
local extract="
# trim input(what you select)
in=\${\${\"\$(<{f})\"%\$'\0'*}#*\$'\0'}
# get ctxt for current completion(some thing before or after the current word)
local -A ctxt=(\"\${(@ps:\2:)CTXT}\")
"

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,cmd -w -w"
zstyle ':fzf-tab:complete:kill:argument-rest' extra-opts --preview=$extract'ps --pid=$in[(w)1] -o cmd --no-headers -w -w' --preview-window=down:3:wrap

# give a preview of directory by exa when completing cd
zstyle ':fzf-tab:complete:cd:*' extra-opts --preview=$extract'exa -1 --color=always ${~ctxt[hpre]}$in'
