import Quickshell.Hyprland
import QtQuick
import qs

// hyprland/workspaces: "{id}: {window icons}" pills, all outputs.
Item {
    id: root

    // window-rewrite: matched case-insensitively against the window class
    readonly property var windowRewrite: [
        ["google-chrome", "\u{F268}"],
        ["chromium", "\u{F268}"],
        ["brave-browser", "\u{F268}"],

        ["pavucontrol", "\u{F028}"],
        ["blueman-manager", "\u{F294}"],

        ["ghostty", "\u{F120}"],
        ["jetbrains-studio", "\u{F121}"],
        ["org.gnome.nautilus", "\u{F0C5}"],
        ["slack", "\u{F198}"],
        ["spotify", "\u{F1BC}"],
        ["code", "\u{F121}"],
        ["vscode", "\u{F121}"],
        ["1password", "\u{EB11}"],
        ["gedit", "\u{F1A7D}"],
        ["virt-manager", "\u{F4A9}"],
        ["obsidian", "\u{F219}"],
        ["cursor", "\u{F246}"]
    ]
    readonly property string windowRewriteDefault: "\u{F059}"

    function iconFor(windowClass: string): string {
        for (const [pattern, icon] of windowRewrite) {
            if (windowClass.match(new RegExp(pattern, "i")))
                return icon;
        }
        return windowRewriteDefault;
    }

    function windowsFor(ws): var {
        return ws.toplevels.values
            .map(t => iconFor(t.lastIpcObject?.class ?? ""));
    }

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.pillHeight

    // Toplevel IPC data (window class) is not always fetched eagerly;
    // refresh it on startup and whenever windows change.
    Component.onCompleted: Hyprland.refreshToplevels()

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            switch (event.name) {
            case "openwindow":
            case "closewindow":
            case "movewindowv2":
            case "windowtitlev2":
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
            model: [...Hyprland.workspaces.values]
                .filter(ws => ws.id > 0)
                .sort((a, b) => a.id - b.id)

            Rectangle {
                id: button
                required property var modelData

                readonly property var windowIcons: root.windowsFor(modelData)
                readonly property color labelColor: modelData.urgent ? Theme.crust
                    : modelData.focused ? Theme.wsActiveFg : Theme.text

                color: modelData.urgent ? Theme.alpha(Theme.yellow, 0.8)
                     : modelData.focused ? Theme.wsActiveBg
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

                    Text {
                        id: buttonLabel
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: button.labelColor
                        textFormat: Text.PlainText
                        text: button.modelData.id + ": "

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    }

                    Text {
                        anchors.baseline: buttonLabel.baseline
                        visible: button.windowIcons.length > 0
                        font.family: Theme.iconFontFamily
                        font.pixelSize: Theme.iconFontSize
                        color: button.labelColor
                        textFormat: Text.PlainText
                        text: button.windowIcons.join(" ")

                        Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: button.modelData.activate()
                }
            }
        }
    }
}
