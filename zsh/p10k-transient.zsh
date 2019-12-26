# Run this function from ~/.zshrc to enable transient kubernetes and/or azure
# prompt segments in Powerlevel10k.
#
# By default, Powerlevel10k displays the current kubernetes context whenever there
# is one. Likewise for the current azure subscription name.  This function changes
# this behavior so that these segments are shown only when the current (not yet
# executed) command in $BUFFER matches a specified pattern
#
# The function is controlled by two parameters:
#
#   TRANSIENT_PROMPT_KUBECONTEXT_CMD: command pattern that triggers the display of
#   kubecontext.
#
#   TRANSIENT_PROMPT_AZURE_CMD: command pattern that triggers the display of azure.
#
# Example configuration:
#
#   # Show kubecontext only when the current command is `kubectl` or `path/kubectl`.
#   TRANSIENT_PROMPT_KUBECONTEXT_CMD='(*/|)kubectl'
#
#   # Show azure only when the current command is `az`, `path/az`, `terraform`, or
#   # `path/terraform`.
#   TRANSIENT_PROMPT_AZURE_CMD='(*/|)(az|terraform)'
() {
  emulate -L zsh
  zmodload zsh/parameter

  function _transient-prompt-segment-wrap-widget() {
    local widget=$1
    local post=$2
    local prefix=transient-prompt-segment
    local orig=${prefix}-orig-${widget}

    case $widgets[$widget] in
      user:$prefix-*)
        ;;
      user:*)
        zle -N $orig ${widgets[$widget]#user:}
        ;;
      builtin)
        eval "function ${(q)orig}() { zle .${(q)widget} }"
        zle -N $orig
        ;;
    esac

    local wrapper=${prefix}-wrapper-${widget}
    eval "function ${(q)wrapper}() {
      local -i ret
      (( ! \${+widgets[${(q)orig}]} )) || zle ${(q)orig} -- \"\$@\" || ret=\$?
      ${(q)post} \"\$@\"
      return \$ret
    }"

    zle -N -- ${widget} $wrapper
  }

  function _transient-prompt-segment-on-buf-change() {
    emulate -L zsh
    unsetopt banghist

    [[ $BUFFER == $_transient_prompt_last_buffer ]] && return
    _transient_prompt_last_buffer=$BUFFER

    local cmd="${(Q)${(Az)BUFFER}[1]}"
    if (( $+aliases[$cmd] )); then
      if functions[_transient-prompt-segment-cmd]=${(q)cmd} 2>/dev/null; then
        cmd="${(Q)${(Az)functions[_transient-prompt-segment-cmd]}[1]}"
        unset 'functions[_transient-prompt-segment-cmd]'
      else
        cmd=
      fi
    fi

    [[ $cmd == $_transient_prompt_last_cmd ]] && return
    _transient_prompt_last_cmd=cmd

    if [[ -n $cmd && $cmd == ${~TRANSIENT_PROMPT_KUBECONTEXT_CMD} ]]; then
      p10k display '*/kubecontext'=show
    else
      p10k display '*/kubecontext'=hide
    fi

    if [[ -n $cmd && $cmd == ${~TRANSIENT_PROMPT_AZURE_CMD} ]]; then
      p10k display '*/azure'=show
    else
      p10k display '*/azure'=hide
    fi
  }

  function p10k-on-pre-prompt() {
    p10k display '*/(kubecontext|azure)'=hide
    typeset -g _transient_prompt_last_buffer=
    typeset -g _transient_prompt_last_cmd=
  }

  function _transient-prompt-segment-init() {
    emulate -L zsh

    if [[ -n $TRANSIENT_PROMPT_KUBECONTEXT_CMD || -n TRANSIENT_PROMPT_AZURE_CMD ]]; then
      local widget
      for widget in ${${(k)widgets}:#.*}; do
        _transient-prompt-segment-wrap-widget $widget _transient-prompt-segment-on-buf-change
      done
    fi

    add-zsh-hook -d precmd _transient-prompt-segment-init
    unfunction _transient-prompt-segment-init
    unfunction _transient-prompt-segment-wrap-widget
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd _transient-prompt-segment-init
  precmd_functions=(_transient-prompt-segment-init $precmd_functions)
}
