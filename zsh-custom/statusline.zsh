export __IS_MUSIC_STATUSLINE_ENABLED=0
export __IS_AZURE_STATUSLINE_ENABLED=0

__statusline-music() {
    get-current-song
}

__statusline-azure-profile() {
    if [ -f $HOME/.azure/azureProfile.json ]; then
        echo -n "\uf0c2  $(jq '.subscriptions[] | select(.isDefault) | .name' \
            -r $HOME/.azure/azureProfile.json)"
    fi
}

refresh-right-statusline() {
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status)
    if [[ "$__IS_MUSIC_STATUSLINE_ENABLED" == "1" ]]; then
        POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(custom_music)
    fi
    if [[ "$__IS_AZURE_STATUSLINE_ENABLED" == "1" ]]; then
        POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(custom_azure)
    fi
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(time)
}


toggle-music-statusline() {
    if [[ "$__IS_MUSIC_STATUSLINE_ENABLED" == "0" ]]; then
        __IS_MUSIC_STATUSLINE_ENABLED=1
    else
        __IS_MUSIC_STATUSLINE_ENABLED=0
    fi
    refresh-right-statusline
}

toggle-azure-statusline() {
    if [[ "$__IS_AZURE_STATUSLINE_ENABLED" == "0" ]]; then
        __IS_AZURE_STATUSLINE_ENABLED=1
    else
        __IS_AZURE_STATUSLINE_ENABLED=0
    fi
    refresh-right-statusline
}

POWERLEVEL9K_CUSTOM_AZURE="__statusline-azure-profile"
POWERLEVEL9K_CUSTOM_AZURE_BACKGROUND="blue"
POWERLEVEL9K_CUSTOM_AZURE_FOREGROUND="000"

POWERLEVEL9K_CUSTOM_MUSIC="__statusline-music"
POWERLEVEL9K_CUSTOM_MUSIC_BACKGROUND="131"
POWERLEVEL9K_CUSTOM_MUSIC_FOREGROUND="000"
