pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

// Notification hub — owns the freedesktop notification server. Deliberately
// transient: there is no history and no control-center. An incoming
// notification is *tracked* only for as long as its toast is on
// screen (see NotificationOverlay / NotificationToast); once it times out or is
// dismissed it's dropped for good. State here is read by the bar's
// Notifications pill and by the toast overlay.
//
// Managing (see CLAUDE.md):
//   qs ipc call notifs toggleDnd      — flip do-not-disturb
//   qs ipc call notifs dnd <on|off>   — set it explicitly
//   qs ipc call notifs dismissAll     — slide every visible toast away
// Bind `dismissAll` (and optionally `toggleDnd`) to a key in Hyprland.
Singleton {
    id: root

    // Do-not-disturb: while true, incoming notifications are swallowed unshown.
    property bool dnd: false
    // Fallback lifetime (ms) for a toast whose sender doesn't request one.
    readonly property int defaultTimeout: 10000

    // Display list of live toasts. We keep our OWN ListModel rather than binding
    // the toast Repeater to the server's trackedNotifications: removing a
    // non-tail entry from that model makes the Repeater rebuild EVERY delegate,
    // which momentarily recreates the just-closed toast (a visible flash) and
    // re-animates the survivors. ListModel.remove(i) drops exactly one row.
    // Role `notification` holds the Notification object.
    ListModel { id: toasts }
    readonly property ListModel model: toasts
    readonly property int count: toasts.count

    // Ask toast(s) to animate themselves out: a specific Notification, or all
    // of them when `target` is null. The toasts own the exit animation, so this
    // is a request rather than a direct removal.
    signal closeRequested(var target)

    function toggleDnd(): void { root.dnd = !root.dnd; }
    function dismissAll(): void { root.closeRequested(null); }
    function dismissLast(): void {
        if (toasts.count > 0)
            root.closeRequested(toasts.get(toasts.count - 1).notification);
    }
    // Drop a toast from the display list (idempotent) — called by a toast once
    // its close animation has finished, or if the sender closes it out from
    // under us. Matches on the notification's stable `id`: ListModel.get() does
    // not return the same object wrapper, so a `===` object compare never hits.
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

        // We paint our own transient toasts and keep nothing on disk: advertise
        // body (+ markup) + images + actions, but no persistence, and drop
        // everything on config reload.
        keepOnReload: false
        persistenceSupported: false
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: false

        onNotification: notif => {
            // DND swallows it (the sender is told it closed). Otherwise track it
            // (keeps the object alive while its toast shows) and add it to our
            // display list; the toast calls forget() + expire()/dismiss() to drop
            // it again.
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
