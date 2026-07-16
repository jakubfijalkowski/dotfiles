import Quickshell
import QtQuick
import qs
import qs.components

// group/group-power: drawer that expands leftwards on hover
// (transition-left-to-right: false, 500ms), 13pt labels.
Item {
    id: root

    readonly property bool expanded: hoverHandler.hovered

    implicitWidth: groupRow.implicitWidth
    implicitHeight: Theme.pillHeight

    HoverHandler { id: hoverHandler }

    component PowerButton: Item {
        id: button

        property alias icon: buttonLabel.text
        property alias iconFamily: buttonLabel.font.family
        property string tooltip: ""
        required property var command

        // Integer width so pills to the left keep whole-pixel positions
        implicitWidth: Math.round(buttonLabel.implicitWidth + 2 * Theme.pillPaddingH)
        implicitHeight: Theme.pillHeight

        Text {
            id: buttonLabel
            anchors.centerIn: parent
            font.family: Theme.mdiFontFamily
            // #group-power label { font-size: 13pt } (17.33px in pango)
            font.pixelSize: Theme.powerIconFontSize
            color: Theme.text
            textFormat: Text.PlainText
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Quickshell.execDetached(button.command)
        }

        BarTooltip {
            target: button
            show: buttonMouse.containsMouse
            text: button.tooltip
        }
    }

    Row {
        id: groupRow
        anchors.verticalCenter: parent.verticalCenter
        // small gap between the drawer and the power button
        spacing: 3

        Item {
            id: drawer
            clip: true
            width: root.expanded ? drawerRow.implicitWidth : 0
            height: root.implicitHeight
            anchors.verticalCenter: parent.verticalCenter

            Behavior on width {
                NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
            }

            Row {
                id: drawerRow
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                PowerButton { icon: "\u{F0709}"; tooltip: "Reboot"; command: ["reboot"] }
                PowerButton { icon: "\u{F0341}"; tooltip: "Lock"; command: ["hyprlock"] }
                PowerButton { icon: "\u{F05FC}"; tooltip: "Logout"; command: ["hyprctl", "dispatch", "exit"] }
            }
        }

        PowerButton {
            icon: "\u{F011}"
            iconFamily: Theme.iconFontFamily
            tooltip: "Shutdown"
            command: ["shutdown", "now"]
        }
    }
}
