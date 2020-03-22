emulate zsh                    # restore default options just in case something messed them up

setopt ALWAYS_TO_END          # full completions move cursor to the end
setopt AUTO_CD                # `dirname` is equivalent to `cd dirname`
setopt AUTO_LIST              # automatically list choices on ambiguous completion.
setopt AUTO_MENU              # show completion menu on successive tab press
setopt AUTO_PARAM_SLASH       # if completed parameter is a directory, add a trailing slash
setopt AUTO_PUSHD             # `cd` pushes directories to the directory stack
setopt COMPLETE_IN_WORD       # complete from the cursor rather than from the end of the word
setopt C_BASES                # print hex/oct numbers as 0xFF/077 instead of 16#FF/8#77
setopt EXTENDED_GLOB          # more powerful globbing
setopt EXTENDED_HISTORY       # write timestamps to history
setopt HIST_EXPIRE_DUPS_FIRST # if history needs to be trimmed, evict dups first
setopt HIST_FIND_NO_DUPS      # don't show dups when searching history
setopt HIST_IGNORE_ALL_DUPS   # delete an old recorded event if a new event is a duplicate.
setopt HIST_IGNORE_DUPS       # don't add consecutive dups to history
setopt HIST_IGNORE_SPACE      # don't add commands starting with space to history
setopt HIST_SAVE_NO_DUPS      # do not write a duplicate event to the history file.
setopt HIST_VERIFY            # if a command triggers history expansion, show it instead of running
setopt INC_APPEND_HISTORY     # add commands to HISTFILE in order of execution
setopt INTERACTIVE_COMMENTS   # allow comments in command line
setopt LONG_LIST_JOBS         # list jobs in the long format by default.
setopt MULTIOS                # allow multiple redirections for the same fd
setopt NO_BG_NICE             # don't nice background jobs
setopt NO_FLOW_CONTROL        # disable start/stop characters in shell editor
setopt NO_MENU_COMPLETE       # do not autoselect the first completion entry
setopt PATH_DIRS              # perform path search even on command names with slashes
setopt PROMPT_SUBST           # enable parameter expansion in prompts
setopt PUSHD_IGNORE_DUPS      # ignore duplicates in pushd
setopt PUSHD_MINUS            # `d`
setopt PUSHD_SILENT           # do not print the directory stack after pushd or popd.
setopt PUSHD_TO_HOME          # push to home directory when no argument is given.
setopt RC_QUOTES              # allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
setopt SHARE_HISTORY          # write and import history on every command

autoload -U regexp-replace
autoload -U +X bashcompinit && bashcompinit

