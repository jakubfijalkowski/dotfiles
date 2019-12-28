#!/bin/sh

if [ "$(xrandr | grep 'DP-1-1')" != "" ]; then
    # Nvidia
    DISPLAY_CONFIG_PRIMARY='DP-1-1'
    DISPLAY_CONFIG_SECONDARY='eDP-1-1'
else
    # Intel (modesetting)
    DISPLAY_CONFIG_PRIMARY='DP-1'
    DISPLAY_CONFIG_SECONDARY='eDP-1'
fi

sed -i "s/screens.primary:.\+/screens.primary: $DISPLAY_CONFIG_PRIMARY/" $HOME/.Xresources
sed -i "s/screens.secondary:.\+/screens.secondary: $DISPLAY_CONFIG_SECONDARY/" $HOME/.Xresources
xrdb $HOME/.Xresources
