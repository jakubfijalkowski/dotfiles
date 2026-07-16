import Quickshell
import QtQuick
import qs
import qs.components

// clock#time: "{:%H:%M}"
BarPill {
    bg: Theme.sapphire
    fg: Theme.crust
    text: Qt.formatDateTime(clock.date, "HH:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
