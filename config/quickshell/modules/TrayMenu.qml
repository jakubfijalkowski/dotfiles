import Quickshell
import Quickshell.Widgets
import QtQuick
import qs
import qs.components

// One level of a tray icon's dbusmenu, drawn as themed rows so the menu can
// live in a BarDrawer instead of a QApplication platform menu. Submenus
// expand inline (this file recurses via Loader) rather than cascading.
Column {
    id: root

    property QsMenuHandle handle
    property color tint: Theme.green
    signal closeRequested()

    readonly property int rowHeight: 26
    // Indicator/icon gutters are reserved per level, so mixed menus keep
    // their labels aligned.
    readonly property var entries: opener.children ? opener.children.values : []
    readonly property bool anyChecks: entries.some(e => !e.isSeparator && e.buttonType !== QsMenuButtonType.None)
    readonly property bool anyIcons: entries.some(e => !e.isSeparator && e.icon !== "")

    width: 230
    spacing: 2

    QsMenuOpener {
        id: opener
        menu: root.handle
    }

    Repeater {
        model: opener.children

        Column {
            id: entry
            required property QsMenuEntry modelData

            property bool expanded: false
            // Relay open/close so lazily-populated submenus get their
            // AboutToShow.
            onExpandedChanged: {
                if (expanded) { sub.active = true; modelData.opened(); }
                else modelData.closed();
            }

            width: root.width

            Item {
                visible: entry.modelData.isSeparator
                width: parent.width
                height: 7

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 12
                    height: 1
                    color: Theme.alpha(Theme.overlay0, 0.4)
                }
            }

            Rectangle {
                visible: !entry.modelData.isSeparator
                width: parent.width
                height: root.rowHeight
                radius: 6
                color: rowMouse.containsMouse ? Theme.cardHoverBg : "transparent"

                Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                Row {
                    id: lead
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 7

                    Rectangle {
                        readonly property bool checked: entry.modelData.checkState === Qt.Checked
                        readonly property bool radio: entry.modelData.buttonType === QsMenuButtonType.RadioButton

                        visible: root.anyChecks
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        radius: radio ? 7 : 4
                        color: Theme.chipBg(root.tint, checked)
                        border.width: entry.modelData.buttonType === QsMenuButtonType.None ? 0 : 1
                        border.color: Theme.chipBorder(root.tint, checked)

                        Rectangle {
                            anchors.centerIn: parent
                            visible: parent.radio && parent.checked
                            width: 6
                            height: 6
                            radius: 3
                            color: root.tint
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !parent.radio && parent.checked
                            font.family: Theme.mdiFontFamily
                            font.pixelSize: 11
                            color: root.tint
                            text: "\u{F012C}" // mdi check
                        }
                    }

                    Item {
                        visible: root.anyIcons
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16

                        IconImage {
                            anchors.fill: parent
                            visible: entry.modelData.icon !== ""
                            source: entry.modelData.icon
                        }
                    }
                }

                Text {
                    anchors.left: lead.right
                    anchors.leftMargin: (root.anyChecks || root.anyIcons) ? 7 : 0
                    anchors.right: parent.right
                    anchors.rightMargin: entry.modelData.hasChildren ? 26 : 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: entry.modelData.enabled ? Theme.text : Theme.overlay0
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    text: entry.modelData.text
                }

                Text {
                    visible: entry.modelData.hasChildren
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 15
                    color: Theme.subtext0
                    text: entry.expanded ? "\u{F0143}" : "\u{F0140}" // chevron-up / down
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: entry.modelData.enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (entry.modelData.hasChildren) {
                            entry.expanded = !entry.expanded;
                        } else {
                            entry.modelData.triggered();
                            root.closeRequested();
                        }
                    }
                }
            }

            ExpandArea {
                expanded: entry.expanded

                Loader {
                    id: sub
                    x: 12
                    width: entry.width - 12
                    active: false
                    source: "TrayMenu.qml"
                    onLoaded: {
                        item.handle = entry.modelData;
                        item.tint = root.tint;
                        item.closeRequested.connect(root.closeRequested);
                    }
                }
            }
        }
    }
}
