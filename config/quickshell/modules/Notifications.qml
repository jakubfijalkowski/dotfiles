import QtQuick
import qs
import qs.components

// Notification state + control. There is no persistent panel — notifications
// pop as transient toasts in the top-right corner (see NotificationOverlay).
// This pill reflects the state and drives it:
//   left-click  → toggle do-not-disturb
//   right-click → dismiss every visible toast
// (Equivalently: qs ipc call notifs {toggleDnd,dismissAll}.)
BarPill {
    id: root

    readonly property bool dnd: Notifs.dnd
    readonly property int count: Notifs.count

    // MDI glyphs (supplementary plane → Material Design Icons font).
    text: dnd ? "\u{F0A93}"              // bell-off — do-not-disturb
        : count > 0 ? "\u{F116B}"        // bell with badge — toasts showing
        : "\u{F009C}"                    // bell-outline — idle
    fontFamily: Theme.mdiFontFamily
    fontPixelSize: Theme.iconFontSize
    accent: dnd ? Theme.peach : Theme.mauve
    neutral: !dnd && count === 0

    tooltipText: dnd
        ? "Do not disturb — notifications hidden\nClick to re-enable"
        : count > 0
            ? count + (count === 1 ? " notification" : " notifications") + "\nRight-click to dismiss all"
            : "Notifications on\nClick for do-not-disturb"

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            Notifs.toggleDnd();
        else if (mouse.button === Qt.RightButton)
            Notifs.dismissAll();
    }
}
