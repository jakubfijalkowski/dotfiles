import Quickshell.Io
import QtQuick
import qs
import qs.components

// Date pill: left-click opens the calendar drawer (or: qs ipc call calendar
// toggle), wheel shifts the month, middle-click resets it.
BarPill {
    id: root

    accent: Theme.teal
    text: Time.now.toLocaleDateString(Theme.dateLocale, "dd MMMM yy")
    highlighted: calendarDrawer.open

    onWheelUp: calendarView.shiftMonth(-1)
    onWheelDown: calendarView.shiftMonth(1)
    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) calendarDrawer.toggle();
        else if (mouse.button === Qt.MiddleButton) calendarView.reset();
    }

    IpcHandler {
        target: "calendar"
        function toggle(): void { calendarDrawer.toggle(); }
    }

    EdgeDrawer {
        id: calendarDrawer
        screen: Screens.primary
        accent: root.accent

        onOpenChanged: if (open) calendarView.reset()

        CalendarView {
            id: calendarView
            accent: root.accent
        }
    }
}
