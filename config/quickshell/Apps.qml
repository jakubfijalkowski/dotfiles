pragma Singleton
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

// Launching apps and finding/focusing their windows, shared by the tray, the
// notification toasts and the power drawer's history.
Singleton {
    id: root

    // uwsm-app gives each launch its own systemd scope, so apps neither die
    // with nor get billed to the shell's own scope.
    function launch(command: var): void {
        Quickshell.execDetached(["uwsm-app", "--", ...command]);
    }
    function launchEntry(entry: var): void {
        launch([entry.id + ".desktop"]);
    }

    // Name fragments too generic to identify an app on their own (reverse-DNS
    // prefixes, SNI id suffixes).
    readonly property var genericParts: ["org", "com", "net", "dev", "app", "desktop",
        "client", "status", "icon", "tray", "indicator", "github", "kde", "gnome"]

    function keysOf(s: string): var {
        const low = s.toLowerCase();
        const parts = low.split(/[^a-z0-9]+/)
            .filter(p => p.length >= 3 && !genericParts.includes(p));
        return [low, ...parts];
    }

    // Match free-form names (SNI id/title, desktop entry, app name) against
    // window appIds, e.g. "Slack_status_icon_1" ↔ "Slack", "chrome" ↔
    // "google-chrome". Exact fragment hits win over prefix hits.
    function findWindow(candidates: var): var {
        // No Array.flatMap in this JS engine.
        const keys = [].concat(...candidates.filter(c => c).map(c => keysOf(String(c))));
        if (keys.length === 0)
            return null;
        const windows = ToplevelManager.toplevels.values
            .filter(tl => tl.appId)
            .map(tl => ({ tl: tl, keys: keysOf(tl.appId) }));
        const exact = windows.find(w => w.keys.some(a => keys.includes(a)));
        if (exact)
            return exact.tl;
        const prefix = windows.find(w => w.keys.some(a => keys.some(k => k.startsWith(a) || a.startsWith(k))));
        return prefix ? prefix.tl : null;
    }

    // The foreign-toplevel activate switches workspace too; an app's own
    // activation only sets the urgent hint under Hyprland.
    function focus(candidates: var): bool {
        const tl = findWindow(candidates);
        if (tl)
            tl.activate();
        return tl !== null;
    }

    // Arm before invoking a notification action: the sender raises its window
    // async, which Hyprland only marks urgent, so jump to the first window that
    // turns urgent shortly after. Waiting for the event (not a fixed delay)
    // copes with slow senders and ignores windows that were urgent already.
    function followNextActivation(): void {
        followWindow.restart();
    }

    Timer {
        id: followWindow
        interval: 1500
    }

    Connections {
        target: Hyprland
        enabled: followWindow.running

        function onRawEvent(event) {
            if (event.name !== "urgent")
                return;
            followWindow.stop();
            const addr = event.data.replace(/^0x/, "");
            const hit = Hyprland.toplevels.values.find(t => String(t.address).replace(/^0x/, "") === addr);
            if (hit && hit.wayland)
                hit.wayland.activate();
            else
                Hyprland.dispatch("hl.dsp.focus({ window = 'address:0x" + addr + "' })");
        }
    }
}
