# Source: https://github.com/romkatv/zsh4humans/blob/master/.zshrc

# When a command is running, display it in the terminal title.
function my-set-term-title-preexec() {
  emulate -L zsh
  print -rn -- $'\e]0;'${(V)1}$'\a' >$TTY
}
# When no command is running, display the current directory in the terminal title.
function my-set-term-title-precmd() {
  emulate -L zsh
  print -rn -- $'\e]0;'${(V%):-"%~"}$'\a' >$TTY
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec my-set-term-title-preexec
add-zsh-hook precmd my-set-term-title-precmd
my-set-term-title-precmd
