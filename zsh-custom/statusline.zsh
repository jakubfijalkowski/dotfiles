__music-ctrl-extract() {
    sed -E 's/.+"(.+)"/\1/'
}

export __IS_MUSIC_STATUSLINE_ENABLED=1
export __IS_AZURE_STATUSLINE_ENABLED=0

__statusline-music() {
    local playback=''
    local song=''
    if [[ `systemctl --user is-active mpd` == 'active' ]]; then
        playback=$(mpc status | sed -n 2p | sed -E 's/(\[.+\])?.+/\1/')
        song=$(mpc current --format '%artist% - %title%')
        if [ -z "$playback" ]; then
            playback='stopped'
        else
            playback=${playback:1:-1}
        fi
    elif pidof -x spotify > /dev/null; then
        local metadata=$(dbus-send \
            --print-reply \
            --session \
            --dest=org.mpris.MediaPlayer2.spotify \
            /org/mpris/MediaPlayer2 \
            org.freedesktop.DBus.Properties.GetAll \
            string:org.mpris.MediaPlayer2.Player)
        local title=$(echo $metadata | sed -n '/xesam:title/{n;p}' | \
            __music-ctrl-extract)
        local artist=$(echo $metadata | sed -n '/xesam:artist/{n;n;p}' | \
            __music-ctrl-extract)
        playback=$(echo $metadata | sed -n '/PlaybackStatus/{n;p}' | __music-ctrl-extract)
        song="$artist - $title"
    fi

    if [ ! -z "$song" ]; then
        if [[ $playback == 'playing' || $playback == "Playing" ]]; then
            echo -n "\uf01d $song"
        elif [[ $playback == 'paused' || $playback == "Paused" ]]; then
            echo -n "\uf28c $song"
        fi
    fi
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
