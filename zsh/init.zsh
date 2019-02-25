# Init
setopt promptsubst
setopt interactivecomments
setopt long_list_jobs

autoload -U regexp-replace
autoload -U +X bashcompinit && bashcompinit

ZSH_CACHE_DIR="$HOME/.zplugin/zsh-cache"
mkdir -p $ZSH_CACHE_DIR

# Zplugin
if [ ! -e ~/.zplugin/bin/zplugin.zsh ]; then
    mkdir -p ~/.zplugin/bin
    git clone https://github.com/zdharma/zplugin.git ~/.zplugin/bin
fi
source ~/.zplugin/bin/zplugin.zsh

