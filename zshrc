if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source "$HOME/.zsh/init.zsh"

source "$HOME/.zsh/title.zsh"
source "$HOME/.zsh/widgets.zsh"
source "$HOME/.zsh/misc.zsh"
source "$HOME/.zsh/completions.zsh"
source "$HOME/.zsh/fzf.zsh"
source "$HOME/.zsh/p10k.zsh"

source $ZSH_CACHE_DIR/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source $ZSH_CACHE_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

source "$HOME/.zsh/keybindings.zsh"
source "$HOME/.zsh/options.zsh"

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi

