zplugin ice lucid
zplugin snippet 'https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion'

zplugin ice wait'0' atinit'zpcompinit; zpcdreplay' lucid
zplugin light zdharma/fast-syntax-highlighting
