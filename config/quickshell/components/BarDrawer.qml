import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs

// A popup that flows out of the bar below its pill: its top edge meets the bar
// and curves into the body through concave fillets, and it opens like a shade.
// API: anchorItem / open / toggle() + default content; a click outside
// dismisses it via the focus grab.
Scope {
    id: root

    required property Item anchorItem
    property bool open: false
    // Still true while the close animation runs, for owners that must keep
    // the anchor and content around until the drawer is gone.
    readonly property bool shown: body.shown
    property color surfaceColor: Theme.barBg
    // Launching module's accent, painted along the seam where the drawer meets the bar.
    required property color accent
    default property alias contentData: body.contentData

    // Drop the top edge to the bar's bottom, so it clears the pill.
    readonly property int topOffset: 2

    function toggle() { open = !open }

    PopupWindow {
        id: popup

        anchor.item: root.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect.x: 0
        anchor.rect.width: root.anchorItem.width
        anchor.rect.y: 0
        anchor.rect.height: root.anchorItem.height + root.topOffset
        visible: body.shown
        color: "transparent"
        implicitWidth: body.bodyWidth + 2 * (body.flareRadius + body.sideMargin)
        // Keep a bar-height clear of the screen bottom, or the compositor
        // slides the popup up over the bar.
        implicitHeight: (Screens.primary ? Screens.primary.height : 1080) - 2 * Theme.barHeight

        // Input only on the revealed body; clicks below pass through and count as outside.
        mask: Region {
            width: popup.width
            height: Math.ceil(body.revealedHeight)
        }

        DrawerSurface {
            id: body
            anchors.fill: parent
            edge: "bar"
            open: root.open
            accent: root.accent
            surfaceColor: root.surfaceColor
        }
    }

    HyprlandFocusGrab {
        active: root.open
        windows: [popup]
        onCleared: root.open = false
    }
}
