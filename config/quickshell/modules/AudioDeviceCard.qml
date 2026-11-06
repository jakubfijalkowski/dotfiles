import Quickshell
import QtQuick
import qs
import qs.components

// One direction of the audio drawer (output or input): mute + volume of the
// default device, and a selector over every device of that kind. The default
// is switched via `wpctl set-default`.
Card {
    id: root

    required property var node      // the current default device
    required property var nodes     // every device of this kind
    required property string kind   // "Output" / "Input"
    property color tint: Theme.flamingo
    property string glyphOn: ""
    property string glyphOff: ""
    property bool expanded: false

    readonly property bool muted: node?.audio?.muted ?? true

    function nodeLabel(n) {
        if (!n) return "—";
        return n.description || n.nickname || n.name || "—";
    }

    padding: 8

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

        Behavior on color { ColorAnimation { duration: Theme.stateDuration; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: Theme.stateDuration; easing.type: Easing.InOutQuad } }

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

    // A device row inside the expanded selector.
    component DeviceOption: Rectangle {
        id: opt
        required property var node
        property bool current: false

        // Match the inner column so the hover highlight stays inside the card border.
        width: parent ? parent.width : 0
        height: 28
        radius: Theme.cardRadius
        color: optMouse.containsMouse ? Theme.cardHoverBg : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: optCheck.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.popupBodySize
            color: opt.current ? root.tint : Theme.subtext1
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
            color: root.tint
            text: "\u{F012C}" // check
        }

        MouseArea {
            id: optMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["wpctl", "set-default", String(opt.node.id)])
        }
    }

    Column {
        width: parent.width
        spacing: 6

        Row {
            width: parent.width
            spacing: 8

            IconToggle {
                anchors.verticalCenter: parent.verticalCenter
                tint: root.tint
                active: !root.muted
                glyph: root.muted ? root.glyphOff : root.glyphOn
                onActivated: if (root.node?.audio) root.node.audio.muted = !root.node.audio.muted
            }

            StyledSlider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 30 - 44 - 2 * parent.spacing
                tint: root.tint
                enabled: root.node?.audio ?? false
                value: root.node?.audio?.volume ?? 0
                onMoved: if (root.node?.audio) root.node.audio.volume = value
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                horizontalAlignment: Text.AlignRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.popupBodySize
                color: Theme.subtext1
                text: Math.round((root.node?.audio?.volume ?? 0) * 100) + "%"
            }
        }

        ExpandHeader {
            text: root.kind + " · " + root.nodeLabel(root.node)
            expanded: root.expanded
            onToggled: root.expanded = !root.expanded
        }

        ExpandArea {
            expanded: root.expanded

            Repeater {
                model: root.nodes

                DeviceOption {
                    required property var modelData
                    node: modelData
                    current: modelData.id === (root.node?.id ?? -1)
                }
            }
        }
    }
}
