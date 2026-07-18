pragma Singleton
import Quickshell

// The monitor the shell lives on; every window resolves its screen through here.
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
