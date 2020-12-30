source /usr/share/LS_COLORS/dircolors.sh

alias cat='bat'
alias grep='rg --crlf -L'

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
alias tv="terraform validate"
alias tg="terragrunt"

alias k="kubectl"
alias kc="kubectx"
alias kns="kubens"

alias gsm="git switchto master"

alias ls="exa -lh --git"
alias lsa="exa -lah --git"
alias lst="exa --tree -L2"
alias lsT="exa --tree -L"

function take() {
  mkdir -p $@ && cd ${@:$#}
}

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

function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}
