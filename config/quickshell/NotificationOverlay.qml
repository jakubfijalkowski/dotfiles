import Quickshell
import QtQuick
import qs
import qs.components

// Transient toast stack: a layer surface pinned to the top-right corner, just
// below the bar. Every live notification (Notifs.model) gets a NotificationToast
// stacked top-down — oldest on top, newest at the bottom — so when the top one
// times out first the rest slide up.
//
// The surface is a FIXED size — it spans the whole height below the bar and
// never resizes as toasts come and go; they reflow *within* it. Resizing the
// layer surface per toast (even as one discrete snap) makes the whole stack
// twitch on screen, so we simply never resize it. Only the actual toast area
// takes pointer input (mask), so the empty space below passes clicks through;
// the window is mapped only while at least one toast is showing. It shares the
// bar's `quickshell` namespace, so the Hyprland blur / no-anim layerrules reach
// it (blur skips the transparent area via ignorealpha).
PanelWindow {
    id: overlay

    screen: Screens.primary

    anchors {
        top: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    margins.top: Theme.barHeight + Theme.notifEdgeGap
    margins.right: Theme.notifEdgeGap
    color: "transparent"

    implicitWidth: Theme.notifWidth
    implicitHeight: Math.max(200, (screen ? screen.height : 1080) - (Theme.barHeight + Theme.notifEdgeGap))
    visible: Notifs.count > 0

    // Only the stacked toasts are interactive; the empty lower area is
    // click-through (tracks the stack's height as toasts come, go and reflow).
    mask: Region {
        width: Theme.notifWidth
        height: Math.ceil(stack.childrenRect.height)
    }

    Column {
        id: stack
        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width

        Repeater {
            model: Notifs.model

            NotificationToast {
                required property var notification   // ListModel role
                notif: notification
            }
        }
    }
}
