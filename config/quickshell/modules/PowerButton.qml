import Quickshell.Io
import QtQuick
import QtQuick.Effects
import qs
import qs.components

// Power button: a bare power glyph in the bar (same look as before) that opens
// the power drawer on click. It glows in its accent on hover and stays lit
// while the drawer is open. Also: qs ipc call power toggle.
Item {
    id: root

    readonly property color accent: Theme.red
    readonly property bool active: drawer.open
    readonly property bool lit: mouse.containsMouse || active

    // nf-fa-power_off (Symbols Nerd Font), the glyph the shutdown button used.
    readonly property string glyph: "\u{F011}"

    // Even integer width keeps the pill row on whole pixels (see BarPill).
    implicitWidth: 2 * Math.round((iconLabel.implicitWidth + 2 * Theme.pillPaddingH) / 2)
    implicitHeight: Theme.pillHeight

    // Accent-coloured blurred copy behind the crisp glyph — the neon glow.
    Text {
        id: glowSource
        anchors.centerIn: parent
        font.family: Theme.iconFontFamily
        font.pixelSize: Theme.powerIconFontSize
        text: root.glyph
        color: root.accent
        textFormat: Text.PlainText
        visible: false
    }
    MultiEffect {
        source: glowSource
        anchors.fill: glowSource
        blurEnabled: true
        blur: 1.0
        blurMax: 14
        opacity: root.lit ? (root.active ? 0.95 : 0.65) : 0
        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.InOutQuad } }
    }

    Text {
        id: iconLabel
        anchors.centerIn: parent
        font.family: Theme.iconFontFamily
        font.pixelSize: Theme.powerIconFontSize
        text: root.glyph
        textFormat: Text.PlainText
        color: root.lit ? root.accent : Theme.text

        Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: drawer.toggle()
    }

    BarTooltip {
        target: root
        show: mouse.containsMouse && !drawer.open
        text: "Power"
    }

    IpcHandler {
        target: "power"
        function toggle(): void { drawer.toggle(); }
    }

    EdgeDrawer {
        id: drawer
        screen: Screens.primary
        accent: root.accent

        onOpenChanged: if (open) menu.opened()

        PowerMenu {
            id: menu
            active: drawer.open
            onCloseRequested: drawer.open = false
        }
    }
}
