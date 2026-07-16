import Quickshell
import QtQuick
import qs
import qs.components

// clock#time: "{:%H:%M}"
BarPill {
    accent: Theme.sapphire
    text: Qt.formatDateTime(clock.date, "HH:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
