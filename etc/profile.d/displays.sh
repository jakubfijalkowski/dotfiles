#!/usr/bin/env zsh

if [[ $(xrandr | grep 'DP-1-1') ]]; then
    # Nvidia
    typeset -g DISPLAY_CONFIG_PRIMARY='DP-1-1'
    typeset -g DISPLAY_CONFIG_SECONDARY='eDP-1-1'
else
    # Intel (modesetting)
    typeset -g DISPLAY_CONFIG_PRIMARY='DP-1'
    typeset -g DISPLAY_CONFIG_SECONDARY='eDP-1'
fi

sed -i "s/screens.primary:.\+/screens.primary: $DISPLAY_CONFIG_PRIMARY/" .Xresources
sed -i "s/screens.secondary:.\+/screens.secondary: $DISPLAY_CONFIG_SECONDARY/" .Xresources
