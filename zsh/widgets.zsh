function my-expand-dot-to-parent-directory-path() {
    if [[ "$LBUFFER" = *.. ]]; then
        LBUFFER+='/..'
    else
        LBUFFER+='.'
    fi
}

function my-fzf-history-widget() {
  emulate -L zsh -o pipefail
  local preview='zsh -dfc "setopt extended_glob; echo - \${\${1#*[0-9] }## #}" -- {}'
  (( $+commands[bat] )) && preview+=' | bat -l bash --color always -pp'
  local selected
  selected="$(
    fc -rl 1 |
    awk '!_[substr($0, 8)]++' |
    fzf +m -n2..,.. --tiebreak=index --cycle --height=80% --preview-window=down:30%:wrap \
      --query=$LBUFFER --preview=$preview)"
  local -i ret=$?
  [[ -n "$selected" ]] && zle vi-fetch-history -n $selected
  zle .reset-prompt
  return ret
}

function my-redraw-prompt() {
  emulate -L zsh
  local f
  for f in chpwd $chpwd_functions precmd $precmd_functions; do
    (( $+functions[$f] )) && $f &>/dev/null
  done
  zle .reset-prompt
  zle -R
}
function my-cd-rotate() {
  emulate -L zsh
  while (( $#dirstack )) && ! pushd -q $1 &>/dev/null; do
    popd -q $1
  done
  if (( $#dirstack )); then
    my-redraw-prompt
  fi
}
function my-cd-back() { my-cd-rotate +1 }
function my-cd-forward() { my-cd-rotate -0 }
function my-cd-up() { cd .. && my-redraw-prompt }

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line

zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N my-cd-back
zle -N my-cd-forward
zle -N my-cd-up
zle -N my-fzf-history-widget
zle -N edit-command-line
zle -N my-expand-dot-to-parent-directory-path
