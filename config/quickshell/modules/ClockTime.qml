import QtQuick
import qs
import qs.components

// clock#time: "{:%H:%M}"
BarPill {
    accent: Theme.sapphire
    text: Qt.formatDateTime(Time.now, "HH:mm")
}
