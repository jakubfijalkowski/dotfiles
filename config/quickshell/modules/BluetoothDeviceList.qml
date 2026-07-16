import Quickshell
import Quickshell.Bluetooth
import QtQuick
import qs
import qs.components

// Content of the bluetooth popup: header with adapter toggle, device
// cards with connect/disconnect controls, and a settings footer.
Column {
    id: root

    // Emitted by the parent when the popup opens (replays card entrances)
    signal opened()
    // Asks the parent popup to close (e.g. after launching settings)
    signal closeRequested()

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool adapterOn: adapter?.enabled ?? false
    readonly property var devices: [...Bluetooth.devices.values]
        .filter(d => d.paired || d.trusted || d.bonded)
        .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
    readonly property int connectedCount: devices.filter(d => d.connected).length
    readonly property int listWidth: 260

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

    function batteryColor(level: real): color {
        if (level > 0.5) return Theme.green;
        if (level > 0.25) return Theme.yellow;
        if (level > 0.1) return Theme.peach;
        return Theme.red;
    }

    spacing: 4

    component Toggle: Rectangle {
        id: toggle

        property bool checked: false
        signal toggled()

        width: 38
        height: 20
        radius: height / 2
        color: checked ? Theme.blue : Theme.surface1

        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        Rectangle {
            width: 14
            height: 14
            radius: 7
            y: 3
            x: toggle.checked ? toggle.width - width - 3 : 3
            color: toggle.checked ? Theme.crust : Theme.overlay1

            Behavior on x {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
                }
            }
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.toggled()
        }
    }

    // Header: icon badge, title + status line, adapter power toggle
    Item {
        width: root.listWidth
        height: 40

        Rectangle {
            id: headerBadge
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 9
            color: root.adapterOn ? Theme.blue : Theme.surface1

            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

            Text {
                anchors.centerIn: parent
                font.family: Theme.mdiFontFamily
                font.pixelSize: 17
                color: root.adapterOn ? Theme.crust : Theme.subtext0
                // nf-md-bluetooth
                text: "\u{F00AF}"

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            }
        }

        Column {
            anchors.left: headerBadge.right
            anchors.leftMargin: 10
            anchors.right: powerToggle.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
                color: Theme.text
                text: "Bluetooth"
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: 11
                color: Theme.subtext0
                text: {
                    if (!root.adapterOn) return "Off";
                    if (root.devices.length === 0) return "No known devices";
                    let s = root.devices.length + (root.devices.length === 1 ? " device" : " devices");
                    if (root.connectedCount > 0) s += " · " + root.connectedCount + " connected";
                    return s;
                }
            }
        }

        Toggle {
            id: powerToggle
            anchors.right: parent.right
            anchors.rightMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            checked: root.adapterOn
            onToggled: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
        }
    }

    Item { width: 1; height: 2 }

    // Empty state
    Column {
        visible: root.devices.length === 0
        width: root.listWidth
        topPadding: 10
        bottomPadding: 12
        spacing: 6

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Theme.mdiFontFamily
            font.pixelSize: 24
            color: Theme.overlay0
            text: "\u{F00B2}"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: Theme.fontFamily
            font.pixelSize: 12
            color: Theme.subtext0
            text: "Pair devices with blueman"
        }
    }

    Repeater {
        // ScriptModel diffs by object identity, so cards persist (and
        // entrance animations don't replay) when the list re-sorts.
        model: ScriptModel { values: root.devices }

        Rectangle {
            id: deviceCard
            required property BluetoothDevice modelData
            required property int index

            readonly property bool connecting: modelData.state === BluetoothDeviceState.Connecting
            readonly property bool disconnecting: modelData.state === BluetoothDeviceState.Disconnecting
            readonly property bool busy: connecting || disconnecting
            readonly property bool isConnected: modelData.connected
            readonly property string statusText: {
                if (connecting) return "Connecting…";
                if (disconnecting) return "Disconnecting…";
                if (isConnected) return "Connected";
                return "";
            }

            // Entrance progress, staggered per card when the popup opens
            property real entrance: 1

            width: root.listWidth
            height: statusText !== "" ? 48 : 40
            radius: 10
            color: isConnected ? Theme.alpha(Theme.green, 0.14)
                 : cardMouse.containsMouse && root.adapterOn ? Theme.alpha(Theme.surface1, 0.6)
                 : Theme.alpha(Theme.surface0, 0.45)
            border.width: 1
            border.color: isConnected ? Theme.alpha(Theme.green, 0.4)
                        : Theme.alpha(Theme.surface1, 0.5)
            opacity: (root.adapterOn ? 1 : 0.4) * entrance

            Behavior on height {
                NumberAnimation {
                    duration: 350
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
                }
            }
            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
            Behavior on border.color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

            // Staggered entrance when the popup opens
            transform: Translate { id: cardShift; y: 0 }

            Connections {
                target: root
                function onOpened() { enter.restart() }
            }

            SequentialAnimation {
                id: enter
                PropertyAction { target: deviceCard; property: "entrance"; value: 0 }
                PropertyAction { target: cardShift; property: "y"; value: 10 }
                PauseAnimation { duration: 40 + deviceCard.index * 50 }
                ParallelAnimation {
                    NumberAnimation {
                        target: deviceCard
                        property: "entrance"
                        to: 1
                        duration: 200
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
                    }
                    NumberAnimation {
                        target: cardShift
                        property: "y"
                        to: 0
                        duration: 350
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
                    }
                }
            }

            MouseArea {
                id: cardMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.adapterOn
                cursorShape: !deviceCard.isConnected && !deviceCard.busy
                    ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (!deviceCard.isConnected && !deviceCard.busy)
                        deviceCard.modelData.connect();
                }
            }

            // Device-type icon chip
            Rectangle {
                id: iconChip
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 28
                height: 28
                radius: 8
                color: deviceCard.isConnected ? Theme.green
                     : cardMouse.containsMouse && root.adapterOn && !deviceCard.busy ? Theme.alpha(Theme.blue, 0.85)
                     : Theme.surface1

                Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 16
                    color: deviceCard.isConnected
                        || (cardMouse.containsMouse && root.adapterOn && !deviceCard.busy)
                        ? Theme.crust : Theme.subtext1
                    text: root.deviceIcon(deviceCard.modelData.icon)

                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }
                }
            }

            Column {
                anchors.left: iconChip.right
                anchors.leftMargin: 10
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
                    text: deviceCard.modelData.name || deviceCard.modelData.deviceName
                }

                Row {
                    spacing: 6

                    Text {
                        visible: deviceCard.statusText !== ""
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        color: deviceCard.isConnected && !deviceCard.busy ? Theme.green : Theme.sapphire
                        text: deviceCard.statusText
                    }

                    // Battery badge
                    Rectangle {
                        visible: deviceCard.isConnected && deviceCard.modelData.batteryAvailable
                        anchors.verticalCenter: parent.verticalCenter
                        width: batteryLabel.implicitWidth + 10
                        height: 14
                        radius: 7
                        color: Theme.alpha(root.batteryColor(deviceCard.modelData.battery), 0.25)

                        Text {
                            id: batteryLabel
                            anchors.centerIn: parent
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            color: root.batteryColor(deviceCard.modelData.battery)
                            text: Math.round(deviceCard.modelData.battery * 100) + "%"
                        }
                    }
                }
            }

            Item {
                id: sideSlot
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24

                Spinner {
                    anchors.centerIn: parent
                    visible: deviceCard.busy
                    color: Theme.sapphire
                }

                Rectangle {
                    anchors.fill: parent
                    visible: deviceCard.isConnected && !deviceCard.busy
                    radius: height / 2
                    color: disconnectMouse.containsMouse
                        ? Theme.alpha(Theme.red, 0.35) : Theme.alpha(Theme.surface1, 0.6)

                    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

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
                        onClicked: deviceCard.modelData.disconnect()
                    }
                }
            }
        }
    }

    Item { width: 1; height: 2 }

    // Footer: open the full manager
    Rectangle {
        width: root.listWidth
        height: 30
        radius: 10
        color: footerMouse.containsMouse ? Theme.alpha(Theme.blue, 0.3) : Theme.alpha(Theme.blue, 0.15)

        Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

        Row {
            anchors.centerIn: parent
            spacing: 7

            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.mdiFontFamily
                font.pixelSize: 13
                color: Theme.blue
                // nf-md-cog
                text: "\u{F0493}"
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontFamily
                font.pixelSize: 12
                color: Theme.blue
                text: "Bluetooth settings"
            }
        }

        MouseArea {
            id: footerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Quickshell.execDetached(["blueman-manager"]);
                root.closeRequested();
            }
        }
    }
}
