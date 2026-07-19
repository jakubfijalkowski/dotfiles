import QtQuick
import qs
import qs.components

// Only surfaces while do-not-disturb is on; click to re-enable notifications
// (or: qs ipc call notifs toggleDnd). Hidden entirely otherwise — it grows
// open on show and collapses on the exact time-reverse of that grow.
BarPill {
    id: root

    readonly property bool shown: Notifs.dnd

    clip: true
    visible: width > 0
    width: 0

    text: "\u{F0A93}"                   // bell-off
    fontFamily: Theme.mdiFontFamily
    fontPixelSize: Theme.iconFontSize
    accent: Theme.peach

    tooltipText: "Do not disturb — notifications hidden\nClick to re-enable"

    onClicked: Notifs.toggleDnd()

    states: State {
        name: "shown"
        when: root.shown
        PropertyChanges { target: root; width: root.implicitWidth }
    }

    transitions: [
        // Smooth decelerate grow…
        Transition {
            to: "shown"
            NumberAnimation {
                property: "width"
                duration: Theme.transitionDuration
                easing.type: Easing.OutCubic
            }
        },
        // …and its exact time-reverse (accelerate) collapsing away.
        Transition {
            from: "shown"
            NumberAnimation {
                property: "width"
                duration: Theme.transitionDuration
                easing.type: Easing.InCubic
            }
        }
    ]
}
