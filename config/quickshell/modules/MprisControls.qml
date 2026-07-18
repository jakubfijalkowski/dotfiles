import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Effects
import qs
import qs.components

// Mpris drawer: album art, track metadata, seek bar and transport row. A chip
// row picks the player when more than one is active.
Column {
    id: root

    // Player being controlled (may be null).
    property var player: null
    // Players worth listing in the picker.
    property var players: []
    // True while the drawer is open; gates the position poll.
    property bool active: false
    onActiveChanged: if (active) syncPosition()

    // Pin a player by dbusName; "" follows the most active.
    signal selectRequested(string id)
    signal closeRequested()
    signal opened()
    onOpened: entrance.restart()

    readonly property color accent: Theme.mauve
    readonly property int listWidth: 320
    readonly property int artSize: 200

    // Position isn't pushed by MPRIS; poll it while playing. Kept local so a
    // user drag isn't fought.
    property real positionNow: 0
    function syncPosition() { if (player) positionNow = player.position; }
    onPlayerChanged: syncPosition()

    function fmtTime(sec) {
        if (!isFinite(sec) || sec < 0) sec = 0;
        const s = Math.floor(sec);
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" + r : r);
    }

    spacing: 8

    Timer {
        interval: 500
        repeat: true
        running: root.active && (root.player?.isPlaying ?? false)
        onTriggered: root.syncPosition()
    }

    // A round transport control; toggles get an active tint, plain ones only
    // light on hover.
    component TButton: Rectangle {
        id: tb
        property string glyph: ""
        property int glyphSize: 20
        property real dim: 34
        property bool enabled: true
        property bool active: false
        property color tint: root.accent
        signal activated()

        width: dim
        height: dim
        radius: dim / 2
        opacity: enabled ? 1 : 0.35
        color: active ? Theme.alpha(tint, 0.15)
             : tbMouse.containsMouse && enabled ? Theme.cardHoverBg
             : "transparent"

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            font.family: Theme.mdiFontFamily
            font.pixelSize: tb.glyphSize
            color: tb.active ? tb.tint : (tb.enabled ? Theme.text : Theme.overlay0)
            text: tb.glyph

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        }

        MouseArea {
            id: tbMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: tb.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (tb.enabled) tb.activated()
        }
    }

    // Player picker (only with more than one active player)
    Flow {
        width: root.listWidth
        spacing: 6
        visible: root.players.length > 1

        Repeater {
            model: root.players

            Rectangle {
                id: chip
                required property var modelData
                readonly property bool current: modelData === root.player
                readonly property string name: modelData.identity || modelData.dbusName || "Player"

                height: 26
                width: chipRow.implicitWidth + 20
                radius: 13
                color: current ? Theme.chipBg(root.accent, true)
                     : chipMouse.containsMouse ? Theme.cardHoverBg : Theme.cardBg
                border.width: 1
                border.color: current ? Theme.chipBorder(root.accent, true) : Theme.cardBorder

                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                Row {
                    id: chipRow
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 7
                        height: 7
                        radius: 3.5
                        color: chip.modelData.isPlaying ? Theme.green
                             : chip.modelData.playbackState === MprisPlaybackState.Paused ? Theme.yellow
                             : Theme.overlay0
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.popupBodySize
                        color: chip.current ? root.accent : Theme.subtext1
                        text: chip.name
                    }
                }

                MouseArea {
                    id: chipMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selectRequested(chip.modelData.dbusName)
                }
            }
        }
    }

    Rectangle {
        id: card
        width: root.listWidth
        height: cardCol.implicitHeight + 20
        radius: Theme.cardRadius
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        // Subtle entrance: lift + fade the whole card when the drawer opens.
        opacity: 0
        transform: Translate { id: cardShift; y: 0 }
        SequentialAnimation {
            id: entrance
            PropertyAction { target: card; property: "opacity"; value: 0 }
            PropertyAction { target: cardShift; property: "y"; value: 8 }
            ParallelAnimation {
                NumberAnimation { target: card; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation {
                    target: cardShift; property: "y"; to: 0; duration: 320
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
                }
            }
        }

        Column {
            id: cardCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 12

            // Album art — large and centered
            Item {
                id: artFrame
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.artSize
                height: root.artSize

                Image {
                    id: artImg
                    anchors.fill: parent
                    source: root.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: 2 * root.artSize
                    sourceSize.height: 2 * root.artSize
                    cache: true
                    asynchronous: true
                    visible: false
                    layer.enabled: true
                }
                Rectangle {
                    id: artMask
                    anchors.fill: parent
                    radius: 14
                    visible: false
                    layer.enabled: true
                }
                MultiEffect {
                    anchors.fill: parent
                    source: artImg
                    maskEnabled: true
                    maskSource: artMask
                    visible: artImg.status === Image.Ready
                }
                // Fallback tile when the player exposes no art.
                Rectangle {
                    anchors.fill: parent
                    visible: artImg.status !== Image.Ready
                    radius: 14
                    color: Theme.alpha(root.accent, 0.12)
                    border.width: 1
                    border.color: Theme.alpha(root.accent, 0.4)

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.mdiFontFamily
                        font.pixelSize: 64
                        color: root.accent
                        // nf-md-music
                        text: "\u{F0387}"
                    }
                }
            }

            // Metadata — centered below the cover
            Column {
                width: parent.width
                spacing: 3

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupTitleSize
                    font.weight: Font.DemiBold
                    color: Theme.text
                    elide: Text.ElideRight
                    text: root.player?.trackTitle || "Nothing playing"
                }
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    visible: text.length > 0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: Theme.subtext1
                    elide: Text.ElideRight
                    text: root.player?.trackArtist ?? ""
                }
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    visible: text.length > 0
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    text: root.player?.trackAlbum ?? ""
                }
            }

            // Seek bar + times (only when the player reports a length)
            Column {
                width: parent.width
                spacing: 2
                visible: (root.player?.lengthSupported ?? false) && (root.player?.length ?? 0) > 0

                StyledSlider {
                    id: seek
                    width: parent.width
                    tint: root.accent
                    trackThickness: 4
                    handleDiameter: 12
                    hideHandleWhenDisabled: true
                    from: 0
                    to: Math.max(1, root.player?.length ?? 1)
                    enabled: root.player?.canSeek ?? false
                    value: root.positionNow

                    // Poll drives the value except while the user is scrubbing.
                    Connections {
                        target: root
                        function onPositionNowChanged() { if (!seek.pressed) seek.value = root.positionNow; }
                    }
                    onPressedChanged: {
                        if (!pressed && (root.player?.canSeek ?? false))
                            root.player.position = value;
                    }
                }

                Row {
                    width: parent.width

                    Text {
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.popupMicroSize
                        color: Theme.subtext0
                        text: root.fmtTime(seek.pressed ? seek.value : root.positionNow)
                    }
                    Item { width: parent.width - 2 * 40; height: 1 }
                    Text {
                        width: 40
                        horizontalAlignment: Text.AlignRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.popupMicroSize
                        color: Theme.subtext0
                        text: root.fmtTime(root.player?.length ?? 0)
                    }
                }
            }

            // Transport
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                TButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.player?.shuffleSupported ?? false
                    dim: 30
                    glyphSize: 17
                    glyph: "\u{F049D}" // nf-md-shuffle
                    active: root.player?.shuffle ?? false
                    onActivated: if (root.player) root.player.shuffle = !root.player.shuffle
                }

                TButton {
                    anchors.verticalCenter: parent.verticalCenter
                    dim: 38
                    glyphSize: 22
                    glyph: "\u{F04AE}" // nf-md-skip-previous
                    enabled: root.player?.canGoPrevious ?? false
                    onActivated: root.player?.previous()
                }

                // Big play/pause
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 48
                    height: 48
                    radius: 24
                    color: playMouse.containsMouse ? Theme.alpha(root.accent, 0.22) : Theme.alpha(root.accent, 0.14)
                    border.width: 1
                    border.color: Theme.alpha(root.accent, 0.7)
                    opacity: (root.player?.canTogglePlaying ?? false) ? 1 : 0.35

                    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.mdiFontFamily
                        font.pixelSize: 26
                        color: root.accent
                        // pause when playing, play otherwise
                        text: (root.player?.isPlaying ?? false) ? "\u{F03E4}" : "\u{F040A}"
                    }

                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: (root.player?.canTogglePlaying ?? false) ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: if (root.player?.canTogglePlaying ?? false) root.player.togglePlaying()
                    }
                }

                TButton {
                    anchors.verticalCenter: parent.verticalCenter
                    dim: 38
                    glyphSize: 22
                    glyph: "\u{F04AD}" // nf-md-skip-next
                    enabled: root.player?.canGoNext ?? false
                    onActivated: root.player?.next()
                }

                TButton {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: root.player?.loopSupported ?? false
                    dim: 30
                    glyphSize: 17
                    readonly property int loop: root.player?.loopState ?? MprisLoopState.None
                    active: loop !== MprisLoopState.None
                    // repeat-off / repeat / repeat-once
                    glyph: loop === MprisLoopState.Track ? "\u{F0458}"
                         : loop === MprisLoopState.Playlist ? "\u{F0456}"
                         : "\u{F0457}"
                    onActivated: {
                        if (!root.player) return;
                        const next = { [MprisLoopState.None]: MprisLoopState.Playlist,
                                       [MprisLoopState.Playlist]: MprisLoopState.Track,
                                       [MprisLoopState.Track]: MprisLoopState.None };
                        root.player.loopState = next[root.player.loopState] ?? MprisLoopState.None;
                    }
                }
            }
        }
    }
}
