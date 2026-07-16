import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// custom/notifications: swaync-client -swb subscription
BarPill {
    id: root

    property string alt: "none"
    property string tip: ""

    readonly property var icons: ({
        "notification": "\u{F116B}",
        "none": "\u{F009C}",
        "dnd-notification": "\u{F00A0}",
        "dnd-none": "\u{F0A93}",
        "inhibited-notification": "\u{F009B}",
        "inhibited-none": "\u{F0A91}",
        "dnd-inhibited-notification": "\u{F009B}",
        "dnd-inhibited-none": "\u{F0A91}"
    })
    readonly property bool hasNotifications: !alt.endsWith("none")

    text: icons[alt] ?? ""
    fontFamily: Theme.mdiFontFamily
    fontPixelSize: Theme.iconFontSize
    accent: Theme.mauve
    neutral: !hasNotifications
    tooltipText: tip

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
        else if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
    }

    Process {
        id: subscribeProcess
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    const parsed = JSON.parse(line);
                    root.alt = parsed.alt ?? "none";
                    root.tip = parsed.tooltip ?? "";
                } catch (e) {}
            }
        }
        onExited: retryTimer.start()
    }

    Timer {
        id: retryTimer
        interval: 2000
        onTriggered: subscribeProcess.running = true
    }
}
