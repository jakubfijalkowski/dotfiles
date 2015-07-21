if [[ $OS != "Windows_NT" ]]; then
    DEFAULT_USER=fiolek
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
    plugins=(git sublime zsh-syntax-highlighting ghc_path cabal debian archlinux)
else
    DEFAULT_USER=Jakub
    plugins=(git sublime ghc_path cabal)

    export MSYSTEM="MSYS"
    export MSYS="winsymlinks:nativestrict"
    export MSYSCON="mintty.exe"

    unsetopt PROMPT_SP
fi

export ZSH="/home/${DEFAULT_USER}/.oh-my-zsh"
export PATH="/home/${DEFAULT_USER}/.cabal/bin:$PATH"

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
