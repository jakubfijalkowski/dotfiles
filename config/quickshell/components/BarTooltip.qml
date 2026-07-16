import Quickshell
import QtQuick
import qs

// Hover tooltip shown below a bar item.
Scope {
    id: root

    required property Item target
    property bool show: false
    property string text: ""
    // Rich (pango-like markup) content, used by the calendar tooltip
    property bool rich: false
    property int textPixelSize: Theme.fontSize

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

            Text {
                id: label
                anchors.centerIn: parent
                font.family: Theme.fontFamily
                font.pixelSize: root.textPixelSize
                color: Theme.text
                textFormat: root.rich ? Text.RichText : Text.PlainText
                text: root.text
            }
        }
    }
}
