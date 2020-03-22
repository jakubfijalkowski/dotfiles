# Configure completions.
zstyle ':completion:*'                  matcher-list    'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*:descriptions'     format          '[%d]'
zstyle ':completion:*'                  completer       _complete
zstyle ':completion:*:*:-subscript-:*'  tag-order       indexes parameters
zstyle ':completion:*'                  squeeze-slashes true
zstyle '*'                              single-ignored  show
zstyle ':completion:*:(rm|kill|diff):*' ignore-line     other
zstyle ':completion:*:rm:*'             file-patterns   '*:all-files'
zstyle ':completion::complete:*'        use-cache       on
zstyle ':completion::complete:*'        cache-path      ${XDG_CACHE_HOME:-$HOME/.cache}/zcompcache-$ZSH_VERSION

zinit snippet "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/pj/pj.plugin.zsh"
zinit snippet "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh"
zinit snippet "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/kubectl/kubectl.plugin.zsh"
zinit snippet "https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion"
zinit ice as"completion"
zinit snippet "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubectx.zsh"
zinit ice as"completion"
zinit snippet "https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/kubens.zsh"
zinit ice as"completion"
zinit snippet "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/terraform/_terraform"

zinit ice wait"0" atload"_zsh_autosuggest_start" lucid
zinit light zsh-users/zsh-autosuggestions
zinit ice wait"0" atinit"zpcompinit; zpcdreplay" lucid
zinit light zdharma/fast-syntax-highlighting
