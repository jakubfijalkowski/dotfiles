import QtQuick
import qs

// Clickable row that toggles an ExpandArea below it: label, chevron, and an
// optional leading glyph. `strong` styles it as a section title rather than a
// caption.
Rectangle {
    id: root

    property bool expanded: false
    property string text: ""
    property string glyph: ""
    property color glyphColor: Theme.subtext0
    property bool strong: false
    signal toggled()

    width: parent ? parent.width : 0
    height: 26
    radius: Theme.cardRadius
    color: mouse.containsMouse ? Theme.cardHoverBg : "transparent"

    Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }

    Text {
        id: lead
        visible: root.glyph !== ""
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.mdiFontFamily
        font.pixelSize: 15
        color: root.glyphColor
        textFormat: Text.PlainText
        text: root.glyph
    }
    Text {
        anchors.left: parent.left
        anchors.leftMargin: lead.visible ? 32 : 8
        anchors.right: chevron.left
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.fontFamily
        font.pixelSize: root.strong ? Theme.popupBodySize : Theme.popupCaptionSize
        font.weight: root.strong ? Font.DemiBold : Font.Normal
        color: root.strong ? Theme.text : Theme.subtext0
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: root.text
    }
    Text {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        font.family: Theme.mdiFontFamily
        font.pixelSize: 15
        color: Theme.subtext0
        text: root.expanded ? "\u{F0143}" : "\u{F0140}" // chevron-up / down
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
