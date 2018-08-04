__music-ctrl-extract() {
    sed -E 's/.+"(.+)"/\1/'
}

get-current-song() {
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

print-current-song() {
    echo $(get-current-song)
}
