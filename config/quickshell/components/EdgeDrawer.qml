import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs

// A drawer that flows out of the top-right corner — BarDrawer's counterpart,
// hinged on two edges: its top edge meets the bar, its right edge meets the
// screen edge. API mirrors BarDrawer (open / shown / toggle() + default
// content); pass `screen` to pin it to the bar's monitor.
Scope {
    id: root

    property var screen: null
    property bool open: false
    readonly property bool shown: body.shown
    property color surfaceColor: Theme.barBg
    required property color accent
    default property alias contentData: body.contentData

    function toggle() { open = !open }

    // Toasts share this corner; hide them while the drawer is out.
    onShownChanged: Notifs.hold(root, shown)
    Component.onDestruction: Notifs.hold(root, false)

    PanelWindow {
        id: win

        screen: root.screen
        // The bar-height margin drops the top to the bar's bottom; ignoring
        // exclusive zones keeps the bar's strip from pushing it down again.
        anchors {
            top: true
            right: true
        }
        margins.top: Theme.barHeight
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: body.shown
        implicitWidth: body.bodyWidth + body.flareRadius + body.sideMargin
        implicitHeight: (root.screen ? root.screen.height : 1080) - Theme.barHeight

        mask: Region {
            width: win.width
            height: Math.ceil(body.revealedHeight)
        }

        DrawerSurface {
            id: body
            anchors.fill: parent
            edge: "corner"
            padding: 16
            open: root.open
            accent: root.accent
            surfaceColor: root.surfaceColor
        }
    }

    HyprlandFocusGrab {
        active: root.open
        windows: [win]
        onCleared: root.open = false
    }
}
