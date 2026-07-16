import Quickshell.Services.Mpris
import QtQuick
import qs
import qs.components

// mpris: " {dynamic}" / paused "⏸ {dynamic}", dynamic-order [artist, title]
BarPill {
    id: root

    bare: true

    // status-icons from config.jsonc; playing/stopped have no icon there
    readonly property var statusIcons: ({
        "playing": "",
        "paused": "\u{23F8}",
        "stopped": ""
    })

    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        if (players.length === 0) return null;
        return players.find(p => p.isPlaying) ?? players[0];
    }

    readonly property string dynamic: {
        if (!player) return "";
        return [player.trackArtist, player.trackTitle]
            .filter(part => part && part.length > 0)
            .join(" - ");
    }

    visible: player !== null
    text: {
        if (!player) return "";
        const status = player.playbackState === MprisPlaybackState.Paused ? "paused"
                     : player.playbackState === MprisPlaybackState.Stopped ? "stopped"
                     : "playing";
        const icon = statusIcons[status];
        // format: " {dynamic}" / format-paused: "{status_icon} {dynamic}"
        return icon + " " + dynamic;
    }

    onClicked: mouse => {
        if (!player) return;
        if (mouse.button === Qt.LeftButton && player.canTogglePlaying) player.togglePlaying();
        else if (mouse.button === Qt.RightButton && player.canGoNext) player.next();
        else if (mouse.button === Qt.MiddleButton && player.canGoPrevious) player.previous();
    }
}
