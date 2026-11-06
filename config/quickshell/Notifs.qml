pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick
import qs

// Notification hub — owns the freedesktop server. Toasts stay transient (no
// control-center, nothing persisted to disk); alongside them a small in-memory
// ring of the most recent notifications is kept so the power drawer can page
// back through what just arrived. IPC:
// qs ipc call notifs {toggleDnd,dnd <on|off>,dismissAll,dismissLast,activateLast}.
Singleton {
    id: root

    // While true, incoming notifications are swallowed.
    property bool dnd: false
    // Fallback lifetime (ms) for a toast whose sender doesn't request one.
    readonly property int defaultTimeout: 10000

    // Own ListModel of live toasts, not the server's trackedNotifications:
    // removing a non-tail entry there rebuilds every delegate (flashes the
    // closed toast). Role `notification` holds the Notification object.
    ListModel { id: toasts }
    readonly property ListModel model: toasts
    readonly property int count: toasts.count

    // Recent-notification ring, newest first — plain field copies, not the live
    // Notification objects (those are freed once untracked). Feeds the power
    // drawer's history view only; capped, in-memory, gone on reload.
    ListModel { id: history }
    readonly property ListModel historyModel: history
    readonly property int maxHistory: 20
    // Bumped on every arrival; views paging the history jump back to newest.
    property int received: 0

    // Ask toast(s) to animate out — a specific Notification, or all when null.
    // `expire` reports the close to the sender as a timeout, not a dismissal.
    signal closeRequested(var target, bool expire)

    // Corner drawers share the toasts' corner: while any holds, the stack
    // hides and its timers pause.
    property var holders: []
    readonly property bool held: holders.length > 0
    function hold(owner, on: bool): void {
        const rest = holders.filter(h => h !== owner);
        if (on)
            rest.push(owner);
        holders = rest;
    }

    function toggleDnd(): void { root.dnd = !root.dnd; }
    function dismissAll(): void { root.closeRequested(null, false); }
    function dismissLast(): void {
        if (toasts.count > 0)
            root.closeRequested(toasts.get(toasts.count - 1).notification, false);
    }

    // Invoke a notification's default action — the same as clicking its toast.
    function activate(notif): void {
        if (!notif)
            return;
        const def = [...notif.actions].find(a => a.identifier === "default");
        if (def)
            root.invoke(notif, def);
        else
            root.closeRequested(notif, false);
    }
    function activateLast(): void {
        if (toasts.count > 0)
            root.activate(toasts.get(toasts.count - 1).notification);
    }

    // Run one of the sender's actions and follow the window it raises. The
    // toast starts closing first, so when a non-resident notification closes
    // itself on invoke, the exit is already under way.
    function invoke(notif, action): void {
        root.closeRequested(notif, false);
        Apps.followNextActivation();
        action.invoke();
    }

    // Drop a toast from the list (idempotent). Matches on the stable `id`:
    // ListModel.get() returns a fresh wrapper, so `===` never hits.
    function forget(notif): void {
        for (let i = 0; i < toasts.count; i++) {
            if (toasts.get(i).nid === notif.id) {
                toasts.remove(i);
                return;
            }
        }
    }

    NotificationServer {
        id: server

        // Own transient toasts, nothing persisted: advertise body/markup/images/
        // actions, no persistence, drop on reload.
        keepOnReload: false
        persistenceSupported: false
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false

        onNotification: notif => {
            // Record every arrival in history first (even DND-swallowed ones —
            // the drawer is where you catch up on what you missed). Store field
            // copies: the object is freed once it stops being tracked.
            history.insert(0, {
                appName: notif.appName || notif.desktopEntry || "Notification",
                desktopEntry: notif.desktopEntry || "",
                summary: notif.summary,
                body: notif.body,
                urgency: notif.urgency,
                // Inline image data is served from the live object and dies
                // with it; only file/URL images outlive the notification.
                iconSource: notif.image !== "" && !notif.image.startsWith("image://")
                    ? notif.image
                    : Icons.resolve([notif.appIcon, notif.desktopEntry, notif.appName], ""),
                // Epoch seconds (fits an int role; ms would overflow).
                time: Math.floor(Date.now() / 1000)
            });
            while (history.count > root.maxHistory)
                history.remove(history.count - 1);
            root.received++;

            // DND swallows the toast. Otherwise track it (keeps it alive while
            // shown) and add to the list; the toast calls forget() to drop it.
            if (root.dnd)
                return;
            notif.tracked = true;
            toasts.append({ notification: notif, nid: notif.id });
            // Over the cap, expire the oldest. Toasts still animating out count
            // too, so a burst doesn't close more than it must.
            for (let i = 0; i < toasts.count - Theme.notifMaxVisible; i++)
                root.closeRequested(toasts.get(i).notification, true);
        }
    }

    IpcHandler {
        target: "notifs"
        function toggleDnd(): void { root.toggleDnd(); }
        function dnd(state: string): void {
            root.dnd = (state === "on" || state === "true" || state === "1");
        }
        function dismissAll(): void { root.dismissAll(); }
        function dismissLast(): void { root.dismissLast(); }
        function activateLast(): void { root.activateLast(); }
    }
}
