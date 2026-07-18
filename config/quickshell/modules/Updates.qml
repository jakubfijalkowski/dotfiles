import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// Pending-updates pill: runs ~/.local/bin/check-updates hourly (JSON
// {text, tooltip}), hidden when empty. Refresh via: qs ipc call updates refresh
BarPill {
    id: root

    property string status: ""
    property string tip: ""

    visible: status !== ""
    accent: Theme.yellow
    text: status
    // script emits the Arch glyph (Symbols NF)
    fontFamily: Theme.iconFontFamily
    fontPixelSize: Theme.iconFontSize
    // drawer already shows this in full
    tooltipText: updatesPopup.open ? "" : tip
    highlighted: updatesPopup.open

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            updatesPopup.toggle();
    }

    BarDrawer {
        id: updatesPopup
        anchorItem: root
        accent: root.accent

        onOpenChanged: if (open) updatesList.opened()

        UpdatesList {
            id: updatesList
            onCloseRequested: updatesPopup.open = false
        }
    }

    function parse(output: string) {
        const line = output.trim();
        if (line === "") { status = ""; tip = ""; return; }
        try {
            const parsed = JSON.parse(line);
            status = parsed.text ?? "";
            tip = parsed.tooltip ?? "";
        } catch (e) {
            console.warn("custom/updates: bad output:", line);
            status = "";
        }
    }

    Process {
        id: checkProcess
        command: [Quickshell.env("HOME") + "/.local/bin/check-updates"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Timer {
        interval: 3600 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProcess.running = true
    }

    IpcHandler {
        target: "updates"
        function refresh(): void { checkProcess.running = true; }
        function toggle(): void { updatesPopup.toggle(); }
    }
}
