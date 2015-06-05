export ZSH=/home/fiolek/.oh-my-zsh

# Autoloads - for plugins (mostly)
autoload -U regexp-replace

# Oh-my-zsh configuration
ZSH_THEME="agnoster"
ENABLE_CORRECTION="true"
ZSH_CUSTOM=~/.zsh-custom
DEFAULT_USER=fiolek
plugins=(git sublime zsh-syntax-highlighting ghc_path cabal)

# Shell configuraion
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export LANG=en_US.UTF-8
export EDITOR='vim'

source $ZSH/oh-my-zsh.sh

# Aliases

alias git="nocorrect git"
alias cabal="nocorrect cabal"

# Custom initialization
#  Configure GHC and Cabal
ghc_path::use_stable_ghc
