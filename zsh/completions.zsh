autoload -Uz compinit
compinit -d ${XDG_CACHE_HOME:-~/.cache}/.zcompdump-$ZSH_VERSION
autoload -Uz bashcompinit
bashcompinit

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

# Use only folders for `exa` completions
compdef _cd exa

z4h source $ZSH_CACHE_DIR/az.completion
z4h source $ZSH_CACHE_DIR/git.plugin.zsh
z4h source $ZSH_CACHE_DIR/pj.plugin.zsh
z4h source $ZSH_CACHE_DIR/kubectl.plugin.zsh
