import Quickshell
import QtQuick
import qs

// Hover tooltip shown below a bar item.
Scope {
    id: root

    required property Item target
    property bool show: false
    property string text: ""

    onShowChanged: {
        if (show && text !== "") delay.restart();
        else { delay.stop(); popup.visible = false; }
    }
    onTextChanged: {
        if (text === "") { delay.stop(); popup.visible = false; }
    }

    Timer {
        id: delay
        interval: 500
        onTriggered: popup.visible = true
    }

    PopupWindow {
        id: popup
        anchor.item: root.target
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        color: "transparent"
        implicitWidth: Math.ceil(body.implicitWidth) + 2
        implicitHeight: Math.ceil(body.implicitHeight) + 2

        Rectangle {
            id: body
            anchors.centerIn: parent
            implicitWidth: label.implicitWidth + 26
            implicitHeight: label.implicitHeight + 14
            color: Theme.popupBg
            border.color: Theme.popupBorder
            border.width: 1
            radius: Math.min(Theme.popupRadius, 10)

            // Fade in once the window maps; hide is instant (the window unmaps first).
            opacity: popup.visible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
                }
            }

            Text {
                id: label
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: Theme.text
                textFormat: Text.PlainText
                text: root.text
            }
        }
    }
}
