import Quickshell
import QtQuick
import qs
import qs.modules

// Top bar on DP-1, replicating the waybar layout.
PanelWindow {
    id: bar

    screen: {
        for (const s of Quickshell.screens) {
            if (s.name === "DP-1") return s;
        }
        return Quickshell.screens[0] ?? null;
    }

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.barBg
        border.width: 1
        border.color: Theme.barBorder
    }

    Workspaces {
        anchors.left: parent.left
        anchors.leftMargin: 3
        anchors.verticalCenter: parent.verticalCenter
    }

    MprisModule {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.moduleSpacing

        Yubikey {}
        Updates {}
        FailedUnits {}
        BluetoothModule {}
        Volume {}
        ClockDate {}
        ClockTime {}
        Notifications {}
        TrayModule {}
        PowerGroup {}
    }
}
