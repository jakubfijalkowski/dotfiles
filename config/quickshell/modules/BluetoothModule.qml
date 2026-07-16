import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs
import qs.components

// bluetooth: "" / disabled "󰂲" / connected "", click opens blueman
BarPill {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property bool connected: connectedDevices.length > 0

    text: {
        if (!adapter) return "";
        if (!adapter.enabled) return "\u{F00B2}";
        return connected ? "\u{F294}" : "\u{F294}";
    }
    // format-disabled is an MDI glyph, the others come from Symbols NF
    fontFamily: adapter && !adapter.enabled ? Theme.mdiFontFamily : Theme.iconFontFamily
    fontPixelSize: Theme.iconFontSize
    bg: {
        if (!adapter) return Theme.reallyRed;
        return connected ? Theme.green : Theme.base;
    }
    fg: connected ? Theme.crust : Theme.text

    // tooltip-format-enumerate-connected: "{device_alias}\t{device_battery_percentage}%"
    tooltipText: {
        if (connected) {
            return connectedDevices
                .map(d => d.name + (d.batteryAvailable ? "\t" + Math.round(d.battery * 100) + "%" : ""))
                .join("\n");
        }
        return adapter ? adapter.name : "No bluetooth controller";
    }

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            Quickshell.execDetached(["blueman-manager"]);
    }
}
