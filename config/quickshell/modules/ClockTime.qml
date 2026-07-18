import QtQuick
import qs
import qs.components

BarPill {
    accent: Theme.sapphire
    text: Qt.formatDateTime(Time.now, "HH:mm")
}
