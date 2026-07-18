import Quickshell.Io
import QtQuick
import qs
import qs.components

// Count of failed systemd units (system + user); hidden when none.
BarPill {
    id: root

    property int nrFailed: 0

    visible: nrFailed > 0
    accent: Theme.reallyRed
    text: "✗ " + nrFailed

    Process {
        id: checkProcess
        command: ["sh", "-c",
            "echo $(( $(systemctl list-units --state=failed --plain --no-legend 2>/dev/null | wc -l) + " +
            "$(systemctl --user list-units --state=failed --plain --no-legend 2>/dev/null | wc -l) ))"]
        stdout: StdioCollector {
            onStreamFinished: root.nrFailed = parseInt(text.trim()) || 0
        }
    }

    Timer {
        interval: 30 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProcess.running = true
    }
}
