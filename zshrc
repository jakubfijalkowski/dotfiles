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
if hash stack 2>/dev/null; then
    autoload -U +X bashcompinit && bashcompinit
    eval "$(stack --bash-completion-script "$(which stack)")"
fi

# Aliases
alias git="nocorrect noglob git"
alias yo="nocorrect yo"
alias stack="nocorrect stack"
alias dotnet="nocorrect dotnet"

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi
