plugins=(git zsh-syntax-highlighting debian archlinux hab)

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

# Autoloads - for plugins (mostly)
autoload -U regexp-replace
autoload -U +X bashcompinit && bashcompinit

# Oh-my-zsh & powerlevel9k configuration
source ~/.zsh-custom/statusline.zsh

POWERLEVEL9K_CUSTOM_AZURE="statusline-azure-profile"
POWERLEVEL9K_CUSTOM_AZURE_BACKGROUND="blue"
POWERLEVEL9K_CUSTOM_AZURE_FOREGROUND="000"

POWERLEVEL9K_CUSTOM_MUSIC="statusline-music"
POWERLEVEL9K_CUSTOM_MUSIC_BACKGROUND="131"
POWERLEVEL9K_CUSTOM_MUSIC_FOREGROUND="000"

POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
POWERLEVEL9K_SHORTEN_STRATEGY='truncate_from_right'
POWERLEVEL9K_SHORTEN_DELIMITER=''

POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status custom_music custom_azure time)

ZSH_THEME="powerlevel9k/powerlevel9k"
ZSH_CUSTOM=~/.zsh-custom
ENABLE_CORRECTION="true"

# Shell configuraion
export LANG="en_US.UTF-8"
export EDITOR="vim"

source $ZSH/oh-my-zsh.sh

# Aliases
alias git="nocorrect noglob git"
alias stack="nocorrect stack"
alias dotnet="nocorrect dotnet"
alias whatismyip="drill A myip.opendns.com @resolver1.opendns.com | grep IN | tac | head -n 1 | cut -d $'\t' -f5"
alias whatismyipv6="drill -6 AAAA myip.opendns.com @resolver1.opendns.com | grep IN | tac | head -n 1 | cut -d $'\t' -f5"
alias az="nocorrect az"

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi
