import QtQuick
import qs

// Tinted outline button for drawer footers; brightens on hover, width set by
// the caller.
Rectangle {
    id: root

    property string label: ""
    property string glyph: ""
    property color tint: Theme.yellow
    signal activated()

    height: 30
    radius: Theme.cardRadius
    color: mouse.containsMouse ? Theme.alpha(tint, 0.15) : Theme.alpha(tint, 0.06)
    border.width: 1
    border.color: Theme.alpha(tint, 0.6)

    Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.InOutQuad } }

    Row {
        anchors.centerIn: parent
        spacing: 7

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
            font.family: Theme.mdiFontFamily
            font.pixelSize: 14
            color: root.tint
            text: root.glyph
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.popupBodySize
            color: root.tint
            text: root.label
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
