import Quickshell.Bluetooth
import QtQuick
import qs
import qs.components

// Content of the bluetooth popup: header with a power toggle and a list
// of known devices with connect/disconnect controls.
Column {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool adapterOn: adapter?.enabled ?? false
    readonly property var devices: [...Bluetooth.devices.values]
        .filter(d => d.paired || d.trusted || d.bonded)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property int listWidth: 250

    function deviceIcon(icon: string): string {
        if (!icon) return "\u{F00AF}";                                        // bluetooth
        if (icon.includes("headset") || icon.includes("headphones")) return "\u{F02CB}"; // headphones
        if (icon.includes("mouse")) return "\u{F037D}";
        if (icon.includes("keyboard")) return "\u{F030C}";
        if (icon.includes("phone")) return "\u{F011C}";
        if (icon.includes("audio-card") || icon.includes("speaker")) return "\u{F04C3}";
        if (icon.includes("gaming")) return "\u{F0296}";
        if (icon.includes("watch")) return "\u{F0565}";
        if (icon.includes("computer")) return "\u{F0322}";
        return "\u{F00AF}";
    }

    spacing: 2

    component Toggle: Rectangle {
        id: toggle

        property bool checked: false
        signal toggled()

        width: 34
        height: 18
        radius: height / 2
        color: checked ? Theme.green : Theme.surface1

        Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            y: 2
            x: toggle.checked ? toggle.width - width - 2 : 2
            color: toggle.checked ? Theme.crust : Theme.overlay1

            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.toggled()
        }
    }

    // Header: title + adapter power toggle
    Item {
        width: root.listWidth
        height: 30

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
            color: Theme.text
            text: "Bluetooth"
        }

        Toggle {
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            checked: root.adapterOn
            onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
        }
    }

    Rectangle {
        width: root.listWidth
        height: 1
        color: Theme.alpha(Theme.surface1, 0.7)
    }

    Item { width: 1; height: 3 }

    // Empty state
    Column {
        visible: root.devices.length === 0
        width: root.listWidth
        topPadding: 8
        bottomPadding: 10
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Theme.mdiFontFamily
            font.pixelSize: 22
            color: Theme.subtext0
            text: "\u{F00B2}"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.subtext0
            text: "No paired devices"
        }
    }

    Repeater {
        model: root.devices

        Rectangle {
            id: deviceRow
            required property BluetoothDevice modelData

            readonly property bool connecting: modelData.state === BluetoothDeviceState.Connecting
            readonly property bool disconnecting: modelData.state === BluetoothDeviceState.Disconnecting
            readonly property bool busy: connecting || disconnecting
            readonly property string statusText: {
                if (connecting) return "Connecting…";
                if (disconnecting) return "Disconnecting…";
                if (modelData.connected) {
                    return "Connected" + (modelData.batteryAvailable
                        ? " · " + Math.round(modelData.battery * 100) + "%" : "");
                }
                return "";
            }
            readonly property color statusColor: modelData.connected && !busy
                ? Theme.green : Theme.sapphire

            width: root.listWidth
            height: statusText !== "" ? 44 : 36
            radius: 6
            color: modelData.connected ? Theme.alpha(Theme.green, 0.12)
                 : rowMouse.containsMouse && root.adapterOn ? Theme.alpha(Theme.surface1, 0.55)
                 : "transparent"
            opacity: root.adapterOn ? 1 : 0.4

            Behavior on height { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.adapterOn
                cursorShape: !deviceRow.modelData.connected && !deviceRow.busy
                    ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (!deviceRow.modelData.connected && !deviceRow.busy)
                        deviceRow.modelData.connect();
                }
            }

            // Device-type icon chip
            Rectangle {
                id: iconChip
                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                height: 26
                radius: 6
                color: deviceRow.modelData.connected
                    ? Theme.alpha(Theme.green, 0.9) : Theme.surface0

                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 15
                    color: deviceRow.modelData.connected ? Theme.crust : Theme.subtext1
                    text: root.deviceIcon(deviceRow.modelData.icon)

                    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                }
            }

            Column {
                anchors.left: iconChip.right
                anchors.leftMargin: 9
                anchors.right: sideSlot.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                spacing: 1

                Text {
                    width: parent.width
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.text
                    elide: Text.ElideRight
                    text: deviceRow.modelData.name || deviceRow.modelData.deviceName
                }

                Text {
                    width: parent.width
                    visible: deviceRow.statusText !== ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    color: deviceRow.statusColor
                    elide: Text.ElideRight
                    text: deviceRow.statusText
                }
            }

            Item {
                id: sideSlot
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22

                Spinner {
                    anchors.centerIn: parent
                    visible: deviceRow.busy
                    color: Theme.sapphire
                }

                Rectangle {
                    anchors.fill: parent
                    visible: deviceRow.modelData.connected && !deviceRow.busy
                    radius: height / 2
                    color: disconnectMouse.containsMouse
                        ? Theme.alpha(Theme.red, 0.35) : Theme.alpha(Theme.surface1, 0.5)

                    Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                    Text {
                        anchors.centerIn: parent
                        font.family: Theme.mdiFontFamily
                        font.pixelSize: 13
                        color: disconnectMouse.containsMouse ? Theme.red : Theme.subtext1
                        // nf-md-close
                        text: "\u{F0156}"
                    }

                    MouseArea {
                        id: disconnectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: deviceRow.modelData.disconnect()
                    }
                }
            }
        }
    }
}
