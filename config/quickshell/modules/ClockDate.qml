import Quickshell.Io
import QtQuick
import qs
import qs.components

// clock#date: "{:L%d %B %y}". Left click (or: qs ipc call calendar toggle)
// opens the calendar drawer; wheel shifts its month and middle click resets
// it, matching the gestures inside the drawer itself.
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

    // Drops down from the top-right corner (flush with the bar + right edge),
    // like BarDrawer, holding the full calendar view.
    EdgeDrawer {
        id: calendarDrawer
        screen: Screens.primary
        accent: root.accent

        // Reset to the current month each time the drawer opens.
        onOpenChanged: if (open) calendarView.reset()

        CalendarView {
            id: calendarView
            accent: root.accent
        }
    }
}
