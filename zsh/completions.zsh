zplugin snippet "https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion"
zplugin ice as"completion"
zplugin snippet "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.zsh"
zplugin ice as"completion"
zplugin snippet "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.zsh"
zplugin snippet "/usr/share/fzf/completion.zsh"
zplugin snippet "/usr/share/fzf/key-bindings.zsh"

zplugin ice wait"0" atinit"zpcompinit; zpcdreplay" lucid
zplugin light zdharma/fast-syntax-highlighting
