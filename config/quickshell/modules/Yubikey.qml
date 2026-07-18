import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// Streams JSON lines from ~/.local/bin/yubikey-touch-status; hidden when empty,
// restarted 60s after the process exits.
BarPill {
    id: root

    property string status: ""

    visible: status !== ""
    accent: Theme.peach
    text: status
    // script emits a key glyph (MDI)
    fontFamily: Theme.mdiFontFamily
    fontPixelSize: Theme.iconFontSize

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached(["xdg-terminal-exec", "--", "yay", "-Syu", "--devel"]);
    }

    Process {
        id: statusProcess
        command: [Quickshell.env("HOME") + "/.local/bin/yubikey-touch-status"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const trimmed = line.trim();
                if (trimmed === "") { root.status = ""; return; }
                try {
                    root.status = JSON.parse(trimmed).text ?? "";
                } catch (e) {
                    root.status = "";
                }
            }
        }
        onExited: restartTimer.start()
    }

    Timer {
        id: restartTimer
        interval: 60 * 1000
        onTriggered: statusProcess.running = true
    }
}
