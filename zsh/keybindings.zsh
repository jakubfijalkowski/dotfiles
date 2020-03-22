bindkey -e

# Source: https://github.com/romkatv/zsh4humans/blob/master/.zshrc

# If someone switches our terminal to application mode (smkx), translate keys to make
# them appear the same as in raw mode (rmkx).
bindkey -s '^[OH' '^[[H'  # home
bindkey -s '^[OF' '^[[F'  # end
bindkey -s '^[OA' '^[[A'  # up
bindkey -s '^[OB' '^[[B'  # down
bindkey -s '^[OD' '^[[D'  # left
bindkey -s '^[OC' '^[[C'  # right

# TTY sends different key codes. Translate them to regular.
bindkey -s '^[[1~' '^[[H'  # home
bindkey -s '^[[4~' '^[[F'  # end

# Do nothing on pageup and pagedown. Better than printing '~'.
bindkey -s '^[[5~' ''
bindkey -s '^[[6~' ''

bindkey '^[[D'    backward-char                          # left       move cursor one char backward
bindkey '^[[C'    forward-char                           # right      move cursor one char forward
bindkey '^[[A'    up-line-or-beginning-search            # up         prev cmd in global history
bindkey '^[[B'    down-line-or-beginning-search          # down       next cmd in global history
bindkey '^[[H'    beginning-of-line                      # home       go to the beginning of line
bindkey '^[[F'    end-of-line                            # end        go to the end of line
bindkey '^?'      backward-delete-char                   # bs         delete one char backward
bindkey '^[[3~'   delete-char                            # delete     delete one char forward
bindkey '^[[1;5C' forward-word                           # ctrl+right go forward one word
bindkey '^[[1;5D' backward-word                          # ctrl+left  go backward one word
bindkey '^H'      backward-kill-word                     # ctrl+bs    delete previous word
bindkey '^[[3;5~' kill-word                              # ctrl+del   delete next word
bindkey '^K'      kill-line                              # ctrl+k     delete line after cursor
bindkey '^J'      backward-kill-line                     # ctrl+j     delete line before cursor
bindkey '^N'      kill-buffer                            # ctrl+n     delete all lines
bindkey '^_'      undo                                   # ctrl+/     undo
bindkey '^\'      redo                                   # ctrl+\     redo
bindkey '^[[1;5A' up-line-or-beginning-search            # ctrl+up    prev cmd in global history
bindkey '^[[1;5B' down-line-or-beginning-search          # ctrl+down  next cmd in global history
bindkey '^[[1;3D' my-cd-back                             # alt+left   cd into the prev directory
bindkey '^[[1;3C' my-cd-forward                          # alt+right  cd into the next directory
bindkey '^[[1;3A' my-cd-up                               # alt+up     cd ..
bindkey '^[[1;3B' fzf-cd-widget                          # alt+down   fzf cd
bindkey '^T'      fzf-completion                         # ctrl+t     fzf file completion
bindkey '^R'      my-fzf-history-widget                  # ctrl+r     fzf history
bindkey '.'       my-expand-dot-to-parent-directory-path # .          change ... to ../..

bindkey '\C-x\C-e' edit-command-line # in-$EDITOR cmd edit
