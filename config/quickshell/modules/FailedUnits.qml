import Quickshell.Io
import QtQuick
import qs
import qs.components

// Count of failed systemd units (system + user); hidden when none. Click opens
// the list (or: qs ipc call units toggle).
BarPill {
    id: root

    // [{ unit, description, sub, user }], system units first.
    property var units: []
    readonly property int nrFailed: units.length

    // Kept up while the drawer rolls shut, so it doesn't lose its anchor.
    visible: nrFailed > 0 || drawer.shown
    accent: Theme.reallyRed
    text: "✗ " + nrFailed
    highlighted: drawer.open

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            drawer.toggle();
    }

    function refresh() {
        if (!checkProcess.running)
            checkProcess.running = true;
    }

    // The marker splits the two lists, so a failing user query can't pass
    // for the system one.
    function parse(text: string) {
        const [sys, usr] = text.split("@@USER@@");
        const read = (chunk, user) => {
            try {
                return JSON.parse(chunk.trim() || "[]").map(u => ({
                    unit: u.unit,
                    description: u.description || "",
                    sub: u.sub || "",
                    user: user
                }));
            } catch (e) {
                console.warn("failed-units: bad systemctl output:", chunk);
                return [];
            }
        };
        units = [...read(sys ?? "", false), ...read(usr ?? "", true)];
    }

    Process {
        id: checkProcess
        command: ["sh", "-c",
            "systemctl list-units --state=failed -o json 2>/dev/null; echo; echo @@USER@@; " +
            "systemctl --user list-units --state=failed -o json 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Timer {
        interval: 30 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Restarts and resets land asynchronously (and may wait on a polkit
    // prompt), so re-poll a little later and once more after that.
    Timer {
        id: settle
        interval: 2000
        repeat: true
        property int left: 0
        onTriggered: {
            root.refresh();
            if (--left <= 0)
                stop();
        }
    }

    BarDrawer {
        id: drawer
        anchorItem: root
        accent: root.accent

        onOpenChanged: if (open) root.refresh()

        FailedUnitsList {
            units: root.units
            onCloseRequested: drawer.open = false
            onActionTaken: {
                settle.left = 3;
                settle.restart();
            }
        }
    }

    IpcHandler {
        target: "units"
        function toggle(): void { if (root.visible) drawer.toggle(); }
        function refresh(): void { root.refresh(); }
    }
}
