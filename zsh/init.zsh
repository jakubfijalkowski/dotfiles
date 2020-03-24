ZSH_CACHE_DIR="$HOME/.cache/zsh-cache"
mkdir -p $ZSH_CACHE_DIR

bindkey -e # switch to Emacs mode

export HISTFILE=~/.zsh_history                    # the path to the history file.
export HISTSIZE=1000000000                        # infinite command history
export SAVEHIST=1000000000                        # infinite command history

export PROMPT_EOL_MARK='%K{red} %k'               # mark the missing \n at the end of a comand output with a red block
export READNULLCMD=less                           # use `less` instead of the default `more`
export WORDCHARS=''                               # only alphanums make up words in word-based zle widgets
export ZLE_REMOVE_SUFFIX_CHARS=''                 # don't eat space when typing '|' after a tab completion
export zle_highlight=('paste:none')               # disable highlighting of text pasted into the command line

export ZSH_HIGHLIGHT_MAXLENGTH=1024               # don't colorize long command lines (slow)
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets) # main syntax highlighting plus matching brackets
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1            # disable a very slow obscure feature

export MANPAGER="sh -c 'col -bx | bat -l man -p'" # use bat as pager for man
