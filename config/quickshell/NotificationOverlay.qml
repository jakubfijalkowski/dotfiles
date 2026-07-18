import Quickshell
import QtQuick
import qs
import qs.components

// Transient toast stack: a fixed-size layer surface pinned top-right below the
// bar. Toasts stack top-down (oldest on top) and reflow within the surface — it
// never resizes, which would twitch the stack. Only the toast area takes input
// (mask); shares the bar's `quickshell` namespace for the blur layerrules.
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

    // Only the stacked toasts take input; the empty area below is click-through.
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
