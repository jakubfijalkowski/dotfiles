import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import qs
import qs.components

// tray: icon-size 16, spacing 8
Item {
    id: root

    implicitWidth: trayRow.implicitWidth + 2 * Theme.pillPaddingH
    implicitHeight: Theme.pillHeight
    visible: SystemTray.items.values.length > 0

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: SystemTray.items

            Rectangle {
                id: trayItem
                required property SystemTrayItem modelData

                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 16
                implicitHeight: 16
                radius: Theme.pillRadius
                // #tray > .needs-attention { background: @yellow }
                color: modelData.status === Status.NeedsAttention ? Theme.yellow : "transparent"

                IconImage {
                    anchors.fill: parent
                    source: trayItem.modelData.icon
                    // #tray > .passive { -gtk-icon-effect: dim }
                    opacity: trayItem.modelData.status === Status.Passive ? 0.5 : 1
                }

                QsMenuAnchor {
                    id: menuAnchor
                    menu: trayItem.modelData.menu
                    anchor.item: trayItem
                    anchor.edges: Edges.Bottom
                    anchor.gravity: Edges.Bottom
                }

                MouseArea {
                    id: trayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            if (trayItem.modelData.onlyMenu) menuAnchor.open();
                            else trayItem.modelData.activate();
                        } else if (mouse.button === Qt.RightButton && trayItem.modelData.hasMenu) {
                            menuAnchor.open();
                        } else if (mouse.button === Qt.MiddleButton) {
                            trayItem.modelData.secondaryActivate();
                        }
                    }
                }

                BarTooltip {
                    target: trayItem
                    show: trayMouse.containsMouse
                    text: trayItem.modelData.tooltipTitle || trayItem.modelData.title
                }
            }
        }
    }
}
