import Quickshell
import QtQuick
import qs
import qs.modules

// Top bar on the primary monitor (Screens), replicating the waybar layout.
PanelWindow {
    id: bar

    screen: Screens.primary

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
