DEFAULT_USER=fiolek
plugins=(git sublime zsh-syntax-highlighting ghc_path cabal debian archlinux)

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

# Autoloads - for plugins (mostly)
autoload -U regexp-replace

# Oh-my-zsh configuration
ZSH_THEME="agnoster"
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
alias yo="nocorrect yo"
alias stack="nocorrect stack"
alias dotnet="nocorrect dotnet"
alias whatismyip="dig +short myip.opendns.com @resolver1.opendns.com"
alias az="nocorrect az"

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi
