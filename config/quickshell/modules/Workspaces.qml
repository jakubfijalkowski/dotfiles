import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs

// Workspace pills across all outputs ("{id}: {window icons}"), each window
// shown as its themed desktop icon resolved from the window class.
Item {
    id: root

    // Fallback when a window class has no themed icon.
    readonly property string fallbackGlyph: "\u{F059}"
    readonly property int iconSize: 17

    function windowsFor(ws): var {
        return ws.toplevels.values
            .map(t => t.lastIpcObject?.class ?? "");
    }

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.pillHeight

    // Window class isn't fetched eagerly — refresh on startup and whenever the
    // window set changes. Title changes are ignored (they fire constantly and
    // can't alter a class).
    Component.onCompleted: Hyprland.refreshToplevels()

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            switch (event.name) {
            case "openwindow":
            case "closewindow":
            case "movewindowv2":
                Hyprland.refreshToplevels();
                break;
            }
        }
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.moduleSpacing

        Repeater {
            // ScriptModel diffs by identity, so pills persist across list
            // changes instead of every delegate rebuilding.
            model: ScriptModel {
                values: [...Hyprland.workspaces.values]
                    .filter(ws => ws.id > 0)
                    .sort((a, b) => a.id - b.id)
            }

            Rectangle {
                id: button
                required property var modelData

                readonly property var windowClasses: root.windowsFor(modelData)
                readonly property color labelColor: modelData.urgent ? Theme.crust
                    : modelData.focused ? Theme.wsActiveFg : Theme.text

                color: modelData.urgent ? Theme.alpha(Theme.yellow, 0.8)
                     : modelData.focused ? Theme.wsActiveBg
                     : wsMouse.containsMouse ? Theme.cardHoverBg
                     : Theme.wsIdleBg
                border.width: modelData.focused && Theme.wsActiveBorder.a > 0 ? 1 : 0
                border.color: modelData.focused ? Theme.wsActiveBorder : "transparent"
                radius: Theme.wsRadius
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: Math.max(content.implicitWidth, 13) + 14
                implicitHeight: Theme.pillHeight - 3

                Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                Row {
                    id: content
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        id: buttonLabel
                        height: root.iconSize
                        verticalAlignment: Text.AlignVCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: button.labelColor
                        textFormat: Text.PlainText
                        text: button.modelData.id + ":"

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    }

                    Repeater {
                        model: button.windowClasses

                        Item {
                            id: iconSlot
                            required property string modelData
                            width: root.iconSize
                            height: root.iconSize

                            Image {
                                id: iconImg
                                anchors.fill: parent
                                source: Icons.resolve(iconSlot.modelData, "application-x-executable")
                                sourceSize.width: 2 * root.iconSize
                                sourceSize.height: 2 * root.iconSize
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                                asynchronous: true
                                cache: true
                                visible: status === Image.Ready
                            }

                            // Fallback glyph when no themed icon resolves.
                            Text {
                                anchors.centerIn: parent
                                visible: iconImg.status !== Image.Ready
                                font.family: Theme.iconFontFamily
                                font.pixelSize: Theme.iconFontSize
                                color: button.labelColor
                                textFormat: Text.PlainText
                                text: root.fallbackGlyph
                            }
                        }
                    }
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: button.modelData.activate()
                }
            }
        }
    }
}
