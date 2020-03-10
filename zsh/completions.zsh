zinit snippet "https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion"
zinit ice as"completion"
zinit snippet "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.zsh"
zinit ice as"completion"
zinit snippet "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.zsh"
zinit snippet "/usr/share/fzf/completion.zsh"
zinit snippet "/usr/share/fzf/key-bindings.zsh"

zinit ice wait"0" atinit"zpcompinit; zpcdreplay" lucid
zinit light zdharma/fast-syntax-highlighting
