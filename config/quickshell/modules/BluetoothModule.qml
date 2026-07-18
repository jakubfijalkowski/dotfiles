import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import QtQuick
import qs
import qs.components

// Bluetooth pill: click opens the device drawer (or: qs ipc call bluetooth toggle).
BarPill {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property bool connected: connectedDevices.length > 0

    text: {
        if (!adapter) return "";
        if (!adapter.enabled) return "\u{F00B2}";   // mdi bluetooth-off
        return connected ? "\u{F00B1}"              // mdi bluetooth-connect
                         : "\u{F294}";              // nf-fa-bluetooth
    }
    // disabled/connected use MDI, idle uses Symbols NF
    fontFamily: adapter && (!adapter.enabled || connected)
        ? Theme.mdiFontFamily : Theme.iconFontFamily
    fontPixelSize: Theme.iconFontSize
    accent: !adapter ? Theme.reallyRed : Theme.blue
    neutral: !devicePopup.open && adapter && !connected
    highlighted: devicePopup.open

    tooltipText: {
        if (devicePopup.open) return "";
        if (connected) {
            return connectedDevices
                .map(d => d.name + (d.batteryAvailable ? "\t" + Math.round(d.battery * 100) + "%" : ""))
                .join("\n");
        }
        return adapter ? adapter.name : "No bluetooth controller";
    }

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            devicePopup.toggle();
    }

    IpcHandler {
        target: "bluetooth"
        function toggle(): void { devicePopup.toggle(); }
        function connect(name: string): void {
            Bluetooth.devices.values.find(d => d.name === name)?.connect();
        }
        function disconnect(name: string): void {
            Bluetooth.devices.values.find(d => d.name === name)?.disconnect();
        }
    }

    BarDrawer {
        id: devicePopup
        anchorItem: root
        accent: root.accent

        onOpenChanged: if (open) deviceList.opened()

        BluetoothDeviceList {
            id: deviceList
            onCloseRequested: devicePopup.open = false
        }
    }
}
