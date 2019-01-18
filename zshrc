if [ -e ~/.local/zshrc-override ]; then
    source ~/.local/zshrc-override
    return 0
fi

plugins=(gitfast docker zsh-syntax-highlighting)

export ZSH="$HOME/.oh-my-zsh"

# Autoloads - for plugins (mostly)
autoload -U regexp-replace
autoload -U +X bashcompinit && bashcompinit

# Oh-my-zsh & powerlevel9k configuration
POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_SHORTEN_STRATEGY='truncate_with_folder_marker'
POWERLEVEL9K_SHORTEN_DELIMITER=''
POWERLEVEL9K_SHORTEN_FOLDER_MARKER='.git'
POWERLEVEL9K_DIR_PATH_ABSOLUTE=true

POWERLEVEL9K_PROMPT_ON_NEWLINE=true

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

ZSH_THEME="powerlevel9k/powerlevel9k"
ZSH_CUSTOM=~/.zsh-custom
ENABLE_CORRECTION="true"

# Shell configuraion
export LANG="en_US.utf8"
export LC_ALL="en_US.utf8"

export EDITOR="vim"

source $ZSH/oh-my-zsh.sh

# Disable corrections/globs (missing completions)
alias git="nocorrect noglob git"
alias stack="nocorrect stack"
alias dotnet="nocorrect dotnet"
alias az="nocorrect az"

# Utils
alias whatismyip="drill A myip.opendns.com @resolver1.opendns.com | grep IN | tac | head -n 1 | cut -d $'\t' -f5"
alias whatismyipv6="drill -6 AAAA myip.opendns.com @resolver1.opendns.com | grep IN | tac | head -n 1 | cut -d $'\t' -f5"
alias open=xdg-open

# ls -> exa
if type exa &> /dev/null; then
    alias ls='exa -lh --git'
    alias lsa='exa -lah --git'
    alias lst='exa --tree -L2'
    alias lsT='exa --tree -L'
fi

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi
