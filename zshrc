DEFAULT_USER=fiolek
plugins=(git sublime zsh-syntax-highlighting ghc_path cabal debian archlinux)

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.cabal/bin:$HOME/.local/bin:$PATH"

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

# Aliases

alias git="nocorrect git"
alias cabal="nocorrect cabal"
alias stack="nocorrect stack"
alias pacaur="pacaur --domain aur4.archlinux.org"
