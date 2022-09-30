if (( $+commands[atuin] )); then
  export ATUIN_NOBIND=1
  eval "$(atuin init zsh)"
  bindkey '^r' _atuin_search_widget
fi
