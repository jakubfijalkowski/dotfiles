zinit snippet /usr/share/LS_COLORS/dircolors.sh
zinit ice depth=1
zinit light romkatv/archive

alias whatismyip="curl -4 ifconfig.co/ip"
alias whatismyipv6="curl -6 ifconfig.co/ip"
alias open=xdg-open

alias dotnet="nocorrect dotnet"
alias az="nocorrect az"

alias gso="git switchto"

alias t="terraform"
alias tp="terraform plan"
alias tpt="terraform plan -target"
alias tpo="terraform plan -out"
alias ta="terraform apply"

alias k="kubectl"
alias kc="kubectx"
alias kns="kubens"
alias kgn="kubectl get nodes"
alias kdn="kubectl describe node"

alias gsm="git switchto master"

alias fzf='fzf --preview-window down:3 --preview "head -n 3 {}" --bind "ctrl-y:execute-silent(echo $PWD/{} | xsel -b)+abort,alt-y:execute(cat {})+abort"'

if type exa &> /dev/null; then
    alias ls="exa -lh --git"
    alias lsa="exa -lah --git"
    alias lst="exa --tree -L2"
    alias lsT="exa --tree -L"
fi

function take() {
  mkdir -p $@ && cd ${@:$#}
}

alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'

alias -- -='cd -'
alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -10
  fi
}
compdef _dirs d
