pragma Singleton
import Quickshell
import QtQuick

// One shared wall clock for everything that shows the time or date (clock
// pills, calendar), so the shell runs a single SystemClock.
Singleton {
    readonly property date now: clock.date

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
