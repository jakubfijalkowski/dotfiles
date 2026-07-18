pragma Singleton
import Quickshell
import QtQuick

// The one shared SystemClock, for the clock pills and the calendar.
Singleton {
    readonly property date now: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
