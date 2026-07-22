import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import qs
import qs.components

// Tray icons: left click jumps to the app's window (switching workspace) via
// the wlr foreign-toplevel activate — the app's own activate() only sets the
// urgent hint under Hyprland, which doesn't navigate. Menu-only items open the
// menu instead; right click opens the item's dbusmenu as a themed drawer,
// middle click secondary-activates.
Item {
    id: root

    implicitWidth: trayRow.implicitWidth + 2 * Theme.pillPaddingH
    implicitHeight: Theme.pillHeight
    visible: SystemTray.items.values.length > 0

    // Find the app's window by matching the SNI id/title against toplevel
    // appIds (e.g. id "spotify-client" / "Slack_status_icon_1" ↔ appId
    // "spotify" / "slack"); loose both-ways so vendor-suffixed ids still hit.
    function focusApp(item: SystemTrayItem): void {
        const cands = [item.id, item.title]
            .filter(s => s)
            .map(s => s.toLowerCase());
        const keys = cands.concat(cands.map(s => (s.match(/[a-z0-9]+/) || [""])[0]))
            .filter(s => s);
        for (const tl of ToplevelManager.toplevels.values) {
            const app = (tl.appId || "").toLowerCase();
            if (app && keys.some(k => k === app || k.startsWith(app) || app.startsWith(k))) {
                tl.activate();
                return;
            }
        }
        // No mapped window (truly hidden in the tray) — let the app restore it.
        item.activate();
    }

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            id: repeater
            model: SystemTray.items

            // Full pill-height so the menu drawer meets the bar's bottom edge
            // like every other drawer; the icon sits centered within it.
            Item {
                id: trayItem
                required property SystemTrayItem modelData

                function toggleMenu() { menuDrawer.toggle() }

                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 16
                height: Theme.pillHeight

                Rectangle {
                    id: icon
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    radius: Theme.pillRadius
                    color: trayItem.modelData.status === Status.NeedsAttention ? Theme.yellow : "transparent"

                    IconImage {
                        anchors.fill: parent
                        source: trayItem.modelData.icon
                        opacity: trayItem.modelData.status === Status.Passive ? 0.5 : 1
                    }
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.modelData.onlyMenu) menuDrawer.toggle();
                            else root.focusApp(trayItem.modelData);
                        } else if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                            menuDrawer.toggle();
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        }
                    }
                }

                BarTooltip {
                    target: trayItem
                    show: trayMouse.containsMouse && !menuDrawer.open
                    text: trayItem.modelData.tooltipTitle || trayItem.modelData.title
                }

                BarDrawer {
                    id: menuDrawer
                    anchorItem: trayItem
                    accent: Theme.green

                    TrayMenu {
                        handle: trayItem.modelData.menu
                        tint: menuDrawer.accent
                        onCloseRequested: menuDrawer.open = false
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "tray"
        function menu(index: int): void {
            const item = repeater.itemAt(index);
            if (item) item.toggleMenu();
        }
    }
}
