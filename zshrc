if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "$HOME/.zsh/init.zsh"

source "$HOME/.zsh/omz.zsh"
source "$HOME/.zsh/powerlevel9k.zsh"
source "$HOME/.zsh/misc.zsh"
source "$HOME/.zsh/completions.zsh"

source "$HOME/.zsh/functions.zsh"
source "$HOME/.zsh/utils.zsh"
source "$HOME/.zsh/alias.zsh"
source "$HOME/.zsh/fzf.zsh"

source "$HOME/.zsh/machine.zsh"

