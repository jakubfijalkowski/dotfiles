plugins=(git zsh-syntax-highlighting debian archlinux)

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

# Autoloads - for plugins (mostly)
autoload -U regexp-replace

# Oh-my-zsh & powerlevel9k configuration

azure_profile() {
    if [ -f $HOME/.azure/azureProfile.json ]; then
        local color="%F{000}"
        local pname=$(cat $HOME/.azure/azureProfile.json | \
            jq '.subscriptions[] | select(.isDefault) | .name' -r)
        echo -n "\uf0c2  $pname"
    fi
}
POWERLEVEL9K_CUSTOM_AZURE="azure_profile"
POWERLEVEL9K_CUSTOM_AZURE_BACKGROUND="blue"
POWERLEVEL9K_CUSTOM_AZURE_FOREGROUND="000"

POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status custom_azure command_execution_time load time)
POWERLEVEL9K_SHOW_CHANGESET=true
POWERLEVEL9K_CHANGESET_HASH_LENGTH="4"
POWERLEVEL9K_VCS_COMMIT_ICON='\uf321 '
ZSH_THEME="powerlevel9k/powerlevel9k"
ENABLE_CORRECTION="true"
ZSH_CUSTOM=~/.zsh-custom

# Shell configuraion
export LANG="en_US.UTF-8"
export EDITOR="vim"

source $ZSH/oh-my-zsh.sh

# Completions
autoload -U +X bashcompinit && bashcompinit

# Aliases
alias git="nocorrect noglob git"
alias stack="nocorrect stack"
alias dotnet="nocorrect dotnet"
alias whatismyip="dig +short myip.opendns.com @resolver1.opendns.com"
alias az="nocorrect az"

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi
