export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
alias fzf='fzf --preview-window down:3 --preview "head -n 3 {}" --bind "ctrl-y:execute-silent(echo $PWD/{} | xsel -b)+abort,alt-y:execute(cat {})+abort"'
