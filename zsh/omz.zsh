omz_load=()
function omz_lib() {
    omz_load+="lib/$1.zsh"
}

function omz_plugin() {
    omz_load+=plugins/$1/$1.plugin.zsh
}

omz_lib git
omz_lib completion
omz_lib correction
omz_lib directories
omz_lib grep
omz_lib history
omz_lib key-bindings
omz_lib spectrum
omz_lib termsupport
omz_lib theme-and-appearance

omz_plugin git
omz_plugin pj
omz_plugin stack
omz_plugin terraform
omz_plugin kubectl

zplugin ice multisrc"$omz_load" atload"touch stub.sh" pick"stub.sh" blockf \
  compile"(lib|plugins)/**/*.zsh"
zplugin light robbyrussell/oh-my-zsh

