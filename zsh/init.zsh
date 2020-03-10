setopt promptsubst
setopt interactivecomments
setopt long_list_jobs

autoload -U regexp-replace
autoload -U +X bashcompinit && bashcompinit

ZSH_CACHE_DIR="$HOME/.zinit/zsh-cache"
mkdir -p $ZSH_CACHE_DIR

# Zinit
if [ ! -e ~/.zinit/bin/zinit.zsh ]; then
    mkdir -p ~/.zinit/bin
    git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi
source ~/.zinit/bin/zinit.zsh

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

