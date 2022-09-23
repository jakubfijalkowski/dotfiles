source "$HOME/.zsh/init.zsh"

source "$HOME/.zsh/title.zsh"
source "$HOME/.zsh/widgets.zsh"
source "$HOME/.zsh/completions.zsh"
source "$HOME/.zsh/misc.zsh"
source "$HOME/.zsh/fzf.zsh"
source "$HOME/.zsh/p10k.zsh"

z4h source $ZSH_CACHE_DIR/zsh-users/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
z4h source $ZSH_CACHE_DIR/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

source "$HOME/.zsh/keybindings.zsh"
source "$HOME/.zsh/options.zsh"

# Per-machine config
if [ -e ~/.local/zshrc ]; then
    source ~/.local/zshrc
fi

