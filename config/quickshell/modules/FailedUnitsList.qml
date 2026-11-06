import Quickshell
import QtQuick
import qs
import qs.components

// Failed-units drawer: one card per failed system/user unit, with a restart
// and a journal shortcut, plus a footer to clear the failed state. System
// units go through polkit (hyprpolkitagent prompts).
Column {
    id: root

    // [{ unit, description, sub, user }] from the pill's poll.
    property var units: []
    readonly property int systemCount: units.filter(u => !u.user).length
    readonly property int userCount: units.length - systemCount
    readonly property color accent: Theme.reallyRed
    readonly property int listWidth: 360

    signal closeRequested()
    // State changed underneath (restart / reset), so the pill should re-poll.
    signal actionTaken()

    function systemctl(user: bool, args: var): var {
        return ["systemctl", ...(user ? ["--user"] : []), ...args];
    }

    spacing: 6

    component IconButton: Rectangle {
        id: btn
        property string glyph: ""
        property color tint: Theme.subtext1
        signal activated()

        width: 26
        height: 26
        radius: 7
        color: btnMouse.containsMouse ? Theme.alpha(tint, 0.16) : "transparent"

        Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            font.family: Theme.mdiFontFamily
            font.pixelSize: 15
            color: btn.tint
            textFormat: Text.PlainText
            text: btn.glyph
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }

    DrawerHeader {
        width: root.listWidth
        glyph: "\u{F0028}"   // alert-circle
        tint: root.accent
        active: root.units.length > 0
        title: "Failed units"
        subtitle: {
            if (root.units.length === 0) return "Everything is running";
            const parts = [];
            if (root.systemCount > 0) parts.push(root.systemCount + " system");
            if (root.userCount > 0) parts.push(root.userCount + " user");
            return parts.join(" · ");
        }
    }

    Repeater {
        model: root.units

        Card {
            id: unitCard
            required property var modelData

            width: root.listWidth
            padding: 10

            Item {
                width: parent.width
                height: Math.max(info.implicitHeight, actions.height)

                Column {
                    id: info
                    anchors.left: parent.left
                    anchors.right: actions.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Row {
                        width: parent.width
                        spacing: 6

                        Text {
                            width: Math.min(implicitWidth, parent.width - scopeChip.width - parent.spacing)
                            elide: Text.ElideMiddle
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.popupBodySize
                            font.weight: Font.DemiBold
                            color: Theme.text
                            textFormat: Text.PlainText
                            text: unitCard.modelData.unit
                        }

                        Rectangle {
                            id: scopeChip
                            anchors.verticalCenter: parent.verticalCenter
                            width: scopeText.implicitWidth + 10
                            height: 16
                            radius: 4
                            color: Theme.chipBg(Theme.mauve, unitCard.modelData.user)
                            border.width: 1
                            border.color: Theme.chipBorder(Theme.mauve, unitCard.modelData.user)

                            Text {
                                id: scopeText
                                anchors.centerIn: parent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.popupMicroSize
                                font.weight: Font.DemiBold
                                color: Theme.chipFg(Theme.mauve, unitCard.modelData.user)
                                text: unitCard.modelData.user ? "user" : "system"
                            }
                        }
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.popupCaptionSize
                        color: Theme.subtext0
                        textFormat: Text.PlainText
                        text: unitCard.modelData.description
                    }
                }

                Row {
                    id: actions
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    IconButton {
                        glyph: "\u{F0EAF}"   // text-box-search-outline
                        onActivated: {
                            const u = unitCard.modelData;
                            Apps.launch(["xdg-terminal-exec", "--", "journalctl",
                                ...(u.user ? ["--user"] : []), "-xeu", u.unit]);
                            root.closeRequested();
                        }
                    }
                    IconButton {
                        glyph: "\u{F0709}"   // restart
                        tint: root.accent
                        onActivated: {
                            const u = unitCard.modelData;
                            Quickshell.execDetached(root.systemctl(u.user, ["restart", u.unit]));
                            root.actionTaken();
                        }
                    }
                }
            }
        }
    }

    ActionButton {
        visible: root.units.length > 0
        width: root.listWidth
        label: "Clear failed state"
        tint: root.accent
        glyph: "\u{F00E2}"   // broom
        onActivated: {
            if (root.userCount > 0)
                Quickshell.execDetached(root.systemctl(true, ["reset-failed"]));
            if (root.systemCount > 0)
                Quickshell.execDetached(root.systemctl(false, ["reset-failed"]));
            root.actionTaken();
        }
    }
}
