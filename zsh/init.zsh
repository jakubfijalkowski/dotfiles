ZSH_CACHE_DIR="$HOME/.zinit/zsh-cache"
mkdir -p $ZSH_CACHE_DIR

# Zinit
if [ ! -e ~/.zinit/bin/zinit.zsh ]; then
    mkdir -p ~/.zinit/bin
    git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

autoload -Uz compinit bashcompinit
compinit -d ${XDG_CACHE_HOME:-~/.cache}/.zcompdump-$ZSH_VERSION
bashcompinit

bindkey -e

HISTFILE=~/.zsh_history                    # The path to the history file.
HISTSIZE=1000000000                        # infinite command history
SAVEHIST=1000000000                        # infinite command history

PROMPT_EOL_MARK='%K{red} %k'               # mark the missing \n at the end of a comand output with a red block
READNULLCMD=less                           # use `less` instead of the default `more`
WORDCHARS=''                               # only alphanums make up words in word-based zle widgets
ZLE_REMOVE_SUFFIX_CHARS=''                 # don't eat space when typing '|' after a tab completion
zle_highlight=('paste:none')               # disable highlighting of text pasted into the command line

ZSH_HIGHLIGHT_MAXLENGTH=1024               # don't colorize long command lines (slow)
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets) # main syntax highlighting plus matching brackets
ZSH_AUTOSUGGEST_MANUAL_REBIND=1            # disable a very slow obscure feature
