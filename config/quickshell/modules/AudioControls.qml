import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import qs
import qs.components

// Content of the audio drawer: output + input volume with device selectors,
// and a collapsible per-application mixer. Values come from PipeWire; the
// default device is switched via `wpctl set-default`.
Column {
    id: root

    // Set by the parent drawer: true while it's open. Gates the PipeWire
    // node tracking so the shell doesn't keep every audio node's properties
    // synced while the drawer is closed (the Volume pill tracks the default
    // sink on its own).
    property bool active: false

    // Asks the parent drawer to close.
    signal closeRequested()
    // Emitted by the parent drawer when it opens — collapse every section so
    // the drawer always starts compact regardless of last session's state.
    signal opened()
    onOpened: {
        outCol.expanded = false;
        inCol.expanded = false;
        appCol.expanded = false;
    }

    readonly property int listWidth: 340

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    function mediaClass(n) {
        return n && n.properties ? (n.properties["media.class"] ?? "") : "";
    }

    // `n.audio` is truthy for audio nodes even before they're bound, but
    // `media.class` only populates once tracked — so track everything audio up
    // front and filter devices by the always-available isSink/isStream flags.
    readonly property var audioNodes: Pipewire.nodes.values.filter(n => n.audio)
    readonly property var outputs: audioNodes.filter(n => n.isSink && !n.isStream)
    readonly property var inputs: audioNodes.filter(n => !n.isSink && !n.isStream)
    readonly property var streams: audioNodes.filter(n => n.isStream && root.mediaClass(n) === "Stream/Output/Audio")

    PwObjectTracker {
        objects: root.active ? root.audioNodes : []
    }

    function nodeLabel(n) {
        if (!n) return "—";
        return n.description || n.nickname || n.name || "—";
    }

    // Resolve a stream node to a themed application icon path, or "" if none
    // is found (the entry then falls back to a monogram tile).
    function resolveIcon(node) {
        const p = node.properties ?? ({});
        return Icons.resolve([p["application.icon-name"], p["application.name"], node.name]);
    }

    spacing: 8

    // ---- Reusable pieces -------------------------------------------------

    component IconToggle: Rectangle {
        id: ic
        property string glyph: ""
        property color tint: Theme.flamingo
        property bool active: true
        signal activated()

        width: 30
        height: 30
        radius: 9
        color: Theme.chipBg(tint, active)
        border.width: 1
        border.color: Theme.chipBorder(tint, active)

        Behavior on color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 160; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            font.family: Theme.mdiFontFamily
            font.pixelSize: 17
            color: Theme.chipFg(ic.tint, ic.active)
            text: ic.glyph
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: ic.activated()
        }
    }

    // A device row inside an expanded selector.
    component DeviceOption: Rectangle {
        id: opt
        required property var node
        property color tint: Theme.flamingo
        property bool current: false

        // Match the inner column, not the full card, so the hover highlight
        // stays inside the card's border.
        width: parent ? parent.width : root.listWidth
        height: 28
        radius: Theme.cardRadius
        color: optMouse.containsMouse ? Theme.cardHoverBg : "transparent"

        Behavior on color { ColorAnimation { duration: 140; easing.type: Easing.InOutQuad } }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: optCheck.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.popupBodySize
            color: opt.current ? opt.tint : Theme.subtext1
            elide: Text.ElideRight
            text: root.nodeLabel(opt.node)
        }
        Text {
            id: optCheck
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            visible: opt.current
            font.family: Theme.mdiFontFamily
            font.pixelSize: 14
            color: opt.tint
            // nf-md-check
            text: "\u{F012C}"
        }

        MouseArea {
            id: optMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["wpctl", "set-default", String(opt.node.id)])
        }
    }

    // ---- Output ----------------------------------------------------------

    Rectangle {
        width: root.listWidth
        height: outCol.implicitHeight + 16
        radius: Theme.cardRadius
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        Column {
            id: outCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 6

            property bool expanded: false

            Row {
                width: parent.width
                spacing: 8

                IconToggle {
                    anchors.verticalCenter: parent.verticalCenter
                    tint: Theme.flamingo
                    active: !(root.sink?.audio?.muted ?? true)
                    glyph: (root.sink?.audio?.muted ?? true) ? "\u{F0581}" : "\u{F057E}" // volume-off / volume-high
                    onActivated: if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted
                }

                StyledSlider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 30 - 44 - 2 * parent.spacing
                    tint: Theme.flamingo
                    enabled: root.sink?.audio ?? false
                    value: root.sink?.audio?.volume ?? 0
                    onMoved: if (root.sink?.audio) root.sink.audio.volume = value
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: Theme.subtext1
                    text: Math.round((root.sink?.audio?.volume ?? 0) * 100) + "%"
                }
            }

            // Device selector header
            Rectangle {
                width: parent.width
                height: 26
                radius: Theme.cardRadius
                color: outHdrMouse.containsMouse ? Theme.cardHoverBg : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: outChevron.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    text: "Output · " + root.nodeLabel(root.sink)
                }
                Text {
                    id: outChevron
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 15
                    color: Theme.subtext0
                    text: outCol.expanded ? "\u{F0143}" : "\u{F0140}" // chevron-up / down
                }

                MouseArea {
                    id: outHdrMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: outCol.expanded = !outCol.expanded
                }
            }

            ExpandArea {
                expanded: outCol.expanded
                Repeater {
                    model: root.outputs
                    DeviceOption {
                        required property var modelData
                        node: modelData
                        tint: Theme.flamingo
                        current: modelData.id === (root.sink?.id ?? -1)
                    }
                }
            }
        }
    }

    // ---- Input -----------------------------------------------------------

    Rectangle {
        width: root.listWidth
        height: inCol.implicitHeight + 16
        radius: Theme.cardRadius
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        Column {
            id: inCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 6

            property bool expanded: false

            Row {
                width: parent.width
                spacing: 8

                IconToggle {
                    anchors.verticalCenter: parent.verticalCenter
                    tint: Theme.sapphire
                    active: !(root.source?.audio?.muted ?? true)
                    glyph: (root.source?.audio?.muted ?? true) ? "\u{F036D}" : "\u{F036C}" // mic-off / mic
                    onActivated: if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted
                }

                StyledSlider {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 30 - 44 - 2 * parent.spacing
                    tint: Theme.sapphire
                    enabled: root.source?.audio ?? false
                    value: root.source?.audio?.volume ?? 0
                    onMoved: if (root.source?.audio) root.source.audio.volume = value
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 44
                    horizontalAlignment: Text.AlignRight
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: Theme.subtext1
                    text: Math.round((root.source?.audio?.volume ?? 0) * 100) + "%"
                }
            }

            Rectangle {
                width: parent.width
                height: 26
                radius: Theme.cardRadius
                color: inHdrMouse.containsMouse ? Theme.cardHoverBg : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: inChevron.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.subtext0
                    elide: Text.ElideRight
                    text: "Input · " + root.nodeLabel(root.source)
                }
                Text {
                    id: inChevron
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 15
                    color: Theme.subtext0
                    text: inCol.expanded ? "\u{F0143}" : "\u{F0140}"
                }

                MouseArea {
                    id: inHdrMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: inCol.expanded = !inCol.expanded
                }
            }

            ExpandArea {
                expanded: inCol.expanded
                Repeater {
                    model: root.inputs
                    DeviceOption {
                        required property var modelData
                        node: modelData
                        tint: Theme.sapphire
                        current: modelData.id === (root.source?.id ?? -1)
                    }
                }
            }
        }
    }

    // ---- Per-app mixer (collapsible) ------------------------------------

    Rectangle {
        width: root.listWidth
        height: appCol.implicitHeight + 16
        radius: Theme.cardRadius
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder

        Column {
            id: appCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 8

            property bool expanded: false

            Rectangle {
                width: parent.width
                height: 26
                radius: Theme.cardRadius
                color: appHdrMouse.containsMouse ? Theme.cardHoverBg : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 15
                    color: Theme.mauve
                    // nf-md-application_cog / tune
                    text: "\u{F062E}"
                }
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 32
                    anchors.right: appChevron.left
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    font.weight: Font.DemiBold
                    color: Theme.text
                    text: "Applications · " + root.streams.length
                }
                Text {
                    id: appChevron
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 15
                    color: Theme.subtext0
                    text: appCol.expanded ? "\u{F0143}" : "\u{F0140}"
                }

                MouseArea {
                    id: appHdrMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: appCol.expanded = !appCol.expanded
                }
            }

            ExpandArea {
                expanded: appCol.expanded

                Text {
                    visible: root.streams.length === 0
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 4
                    bottomPadding: 6
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.subtext0
                    text: "Nothing is playing"
                }

                Repeater {
                    model: root.streams

                    Item {
                        id: appEntry
                        required property var modelData
                        width: appCol.width
                        height: appInner.implicitHeight + 8

                        readonly property string appName: {
                            const p = modelData.properties;
                            return (p && (p["application.name"] || p["node.name"])) || modelData.name || "App";
                        }

                        // Bigger left/right margins than the header, plus an app icon.
                        Row {
                            id: appInner
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Item {
                                id: appIconSlot
                                anchors.verticalCenter: parent.verticalCenter
                                width: 26
                                height: 26

                                Image {
                                    id: appImg
                                    anchors.fill: parent
                                    sourceSize.width: 52
                                    sourceSize.height: 52
                                    fillMode: Image.PreserveAspectFit
                                    source: root.resolveIcon(appEntry.modelData)
                                    visible: status === Image.Ready
                                }
                                // Monogram tile when the app has no themed icon.
                                Rectangle {
                                    anchors.fill: parent
                                    visible: appImg.status !== Image.Ready
                                    radius: 7
                                    color: Theme.alpha(Theme.mauve, 0.15)
                                    border.width: 1
                                    border.color: Theme.alpha(Theme.mauve, 0.4)

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        color: Theme.mauve
                                        text: (appEntry.appName.charAt(0) || "?").toUpperCase()
                                    }
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - appIconSlot.width - parent.spacing
                                spacing: 4

                                Text {
                                    width: parent.width
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupCaptionSize
                                    color: Theme.subtext1
                                    elide: Text.ElideRight
                                    text: appEntry.appName
                                }

                                Row {
                                    width: parent.width
                                    spacing: 8

                                    StyledSlider {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 44 - parent.spacing
                                        tint: Theme.mauve
                                        value: appEntry.modelData.audio.volume
                                        onMoved: appEntry.modelData.audio.volume = value
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 44
                                        horizontalAlignment: Text.AlignRight
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.popupBodySize
                                        color: Theme.subtext1
                                        text: Math.round(appEntry.modelData.audio.volume * 100) + "%"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- Footer ----------------------------------------------------------

    ActionButton {
        width: root.listWidth
        label: "Sound settings"
        tint: Theme.flamingo
        // nf-md-cog
        glyph: "\u{F0493}"
        onActivated: {
            Quickshell.execDetached(["uwsm", "app", "pavucontrol"]);
            root.closeRequested();
        }
    }
}
