pragma Singleton
import Quickshell

// The monitor the shell lives on. Every window (bar, toast overlay, edge
// drawers) resolves its screen through here so the choice has one home.
Singleton {
    readonly property string primaryName: "DP-1"

    readonly property var primary: {
        for (const s of Quickshell.screens) {
            if (s.name === primaryName)
                return s;
        }
        return Quickshell.screens[0] ?? null;
    }
}
