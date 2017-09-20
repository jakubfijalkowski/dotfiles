plugins=(git zsh-syntax-highlighting debian archlinux)

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

# Autoloads - for plugins (mostly)
autoload -U regexp-replace

source ~/.local/share/fonts/*.sh

# Oh-my-zsh configuration
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator history)
POWERLEVEL9K_MODE='awesome-fontconfig'
ZSH_THEME="powerlevel9k/powerlevel9k"
ENABLE_CORRECTION="true"
ZSH_CUSTOM=~/.zsh-custom

# Shell configuraion
export LANG="en_US.UTF-8"
export EDITOR="vim"

source $ZSH/oh-my-zsh.sh

# Completions
autoload -U +X bashcompinit && bashcompinit

if hash az 2>/dev/null; then
    source "$HOME/.local/lib/azure-cli/az.completion"
fi
if hash stack 2>/dev/null; then
    eval "$(stack --bash-completion-script "$(which stack)")"
fi

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
