import QtQuick
import qs
import qs.components

// Notification pill: left-click toggles do-not-disturb, right-click dismisses
// all toasts (or: qs ipc call notifs {toggleDnd,dismissAll}).
BarPill {
    id: root

    readonly property bool dnd: Notifs.dnd
    readonly property int count: Notifs.count

    text: dnd ? "\u{F0A93}"              // bell-off
        : count > 0 ? "\u{F116B}"        // bell with badge
        : "\u{F009C}"                    // bell-outline
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
