import QtQuick
import qs

// A drawer's title row: tinted glyph badge, title + status line, and an
// optional trailing control (default content, vertically centred on the right).
Item {
    id: root

    property string glyph: ""
    property string glyphFamily: Theme.mdiFontFamily
    property int glyphSize: 15
    property color tint: Theme.text
    // Dims the badge, e.g. while the device it stands for is off.
    property bool active: true
    property string title: ""
    property string subtitle: ""
    default property alias trailing: trailingSlot.data

    implicitHeight: 34

    Rectangle {
        id: badge
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30
        radius: 9
        color: Theme.chipBg(root.tint, root.active)
        border.width: 1
        border.color: Theme.chipBorder(root.tint, root.active)

        Behavior on color { ColorAnimation { duration: Theme.stateDuration; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: Theme.stateDuration; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            font.family: root.glyphFamily
            font.pixelSize: root.glyphSize
            color: Theme.chipFg(root.tint, root.active)
            textFormat: Text.PlainText
            text: root.glyph

            Behavior on color { ColorAnimation { duration: Theme.stateDuration; easing.type: Easing.InOutQuad } }
        }
    }

    Column {
        anchors.left: badge.right
        anchors.leftMargin: 10
        anchors.right: trailingSlot.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        Text {
            width: parent.width
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
            color: Theme.text
            textFormat: Text.PlainText
            text: root.title
        }
        Text {
            width: parent.width
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.popupCaptionSize
            color: Theme.subtext0
            textFormat: Text.PlainText
            text: root.subtitle
        }
    }

    Item {
        id: trailingSlot
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
