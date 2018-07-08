if [ -e ~/.local/zshrc-override ]; then
    source ~/.local/zshrc-override
    return 0
fi

plugins=(gitfast zsh-syntax-highlighting)

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

# Autoloads - for plugins (mostly)
autoload -U regexp-replace
autoload -U +X bashcompinit && bashcompinit

# Oh-my-zsh & powerlevel9k configuration
source ~/.zsh-custom/statusline.zsh

POWERLEVEL9K_MODE='nerdfont-complete'

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_to_unique'
POWERLEVEL9K_SHORTEN_DELIMITER=''

POWERLEVEL9K_PROMPT_ON_NEWLINE=true

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
refresh-right-statusline

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

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi
