import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import qs
import qs.components

// mpris: a bare pill showing the active player's track. Left click opens a
// controls drawer, right click toggles play/pause, middle click skips ahead.
// The pill stays visible while paused (it no longer falls back to a stopped,
// empty player), and can be driven via: qs ipc call mpris toggle|playpause|…
BarPill {
    id: root

    bare: true
    accent: Theme.mauve
    highlighted: drawer.open

    readonly property var allPlayers: Mpris.players.values

    // How "worth showing" a player is: prefer one that's playing, then one
    // that's merely paused, then one that at least carries a track title.
    // A stopped, title-less player (e.g. an idle browser tab) ranks 0 and is
    // never auto-picked — which is what used to blank the pill on pause.
    function playerRank(p) {
        if (!p) return -1;
        if (p.isPlaying) return 3;
        if (p.playbackState === MprisPlaybackState.Paused) return 2;
        if (p.trackTitle && p.trackTitle.length > 0) return 1;
        return 0;
    }

    // Players offered in the drawer's picker: everything with real content.
    readonly property var activePlayers: allPlayers.filter(p => root.playerRank(p) >= 1)

    // dbusName of the player the user pinned in the drawer; "" means follow
    // whatever is most active.
    property string selectedId: ""

    readonly property MprisPlayer player: {
        if (selectedId) {
            const pinned = allPlayers.find(p => p.dbusName === selectedId);
            if (pinned && root.playerRank(pinned) >= 1) return pinned;
        }
        let best = null, bestRank = 0;
        for (const p of allPlayers) {
            const r = root.playerRank(p);
            if (r > bestRank) { bestRank = r; best = p; }
        }
        return best;
    }

    readonly property bool paused: player?.playbackState === MprisPlaybackState.Paused

    readonly property string dynamic: {
        if (!player) return "";
        return [player.trackArtist, player.trackTitle]
            .filter(part => part && part.length > 0)
            .join(" - ");
    }

    visible: player !== null
    contentWidth: content.implicitWidth

    // Icon (Symbols/MDI run) + track text (Iosevka run), mirroring how
    // Volume composes its pill so the track can elide at a sane max width.
    Row {
        id: content
        anchors.centerIn: parent
        spacing: 5

        Text {
            id: glyph
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.mdiFontFamily
            font.pixelSize: Theme.iconFontSize
            // playing → music note, paused → pause bars
            text: root.paused ? "\u{F03E4}" : "\u{F0387}"
            color: root.paused ? Theme.overlay1 : root.accent

            Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: trackLabel
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 300)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: root.paused ? Theme.subtext0 : Theme.text
            textFormat: Text.PlainText
            elide: Text.ElideRight
            text: root.dynamic

            Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
        }
    }

    onClicked: mouse => {
        if (!player) return;
        if (mouse.button === Qt.LeftButton) drawer.toggle();
        else if (mouse.button === Qt.RightButton && player.canTogglePlaying) player.togglePlaying();
        else if (mouse.button === Qt.MiddleButton && player.canGoNext) player.next();
    }

    IpcHandler {
        target: "mpris"
        function toggle(): void { drawer.toggle(); }
        function playpause(): void { if (root.player?.canTogglePlaying) root.player.togglePlaying(); }
        function next(): void { if (root.player?.canGoNext) root.player.next(); }
        function previous(): void { if (root.player?.canGoPrevious) root.player.previous(); }
    }

    BarDrawer {
        id: drawer
        anchorItem: root
        accent: root.accent

        onOpenChanged: if (open) controls.opened()

        MprisControls {
            id: controls
            player: root.player
            players: root.activePlayers
            onSelectRequested: id => root.selectedId = id
            onCloseRequested: drawer.open = false
        }
    }
}
