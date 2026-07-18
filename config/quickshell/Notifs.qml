pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

// Notification hub — owns the freedesktop server. Deliberately transient: no
// history, no control-center; a notification is tracked only while its toast
// shows. IPC: qs ipc call notifs {toggleDnd,dnd <on|off>,dismissAll,dismissLast}.
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

    // Ask toast(s) to animate out — a specific Notification, or all when null.
    signal closeRequested(var target)

    function toggleDnd(): void { root.dnd = !root.dnd; }
    function dismissAll(): void { root.closeRequested(null); }
    function dismissLast(): void {
        if (toasts.count > 0)
            root.closeRequested(toasts.get(toasts.count - 1).notification);
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
            // DND swallows it. Otherwise track it (keeps it alive while shown)
            // and add to the list; the toast calls forget() to drop it.
            if (root.dnd)
                return;
            notif.tracked = true;
            toasts.append({ notification: notif, nid: notif.id });
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
    }
}
