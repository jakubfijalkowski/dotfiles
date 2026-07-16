import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// custom/updates: ~/.local/bin/check-updates hourly, JSON {text, tooltip},
// hidden when empty. Waybar refreshed this via SIGRTMIN+1 (signal: 1);
// here use: qs ipc call updates refresh
BarPill {
    id: root

    property string status: ""
    property string tip: ""

    visible: status !== ""
    bg: Theme.yellow
    fg: Theme.crust
    text: status
    // the script emits "" (Arch logo, Symbols Nerd Font)
    fontFamily: Theme.iconFontFamily
    fontPixelSize: Theme.iconFontSize
    tooltipText: tip

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached(["xdg-terminal-exec", "--", "yay", "-Syu", "--devel"]);
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
    }
}
