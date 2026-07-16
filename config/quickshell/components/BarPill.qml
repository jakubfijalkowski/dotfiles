import QtQuick
import qs

// A single bar module: rounded pill with centered text.
Rectangle {
    id: root

    property alias text: label.text
    property alias fontFamily: label.font.family
    property alias fontPixelSize: label.font.pixelSize
    property color bg: "transparent"
    property color fg: Theme.text
    property real minContentWidth: 0
    // modules with composite content (e.g. icon + text runs) override this
    property real contentWidth: label.implicitWidth
    property string tooltipText: ""
    property bool tooltipRich: false
    property alias tooltipTextPixelSize: tooltip.textPixelSize

    signal clicked(var mouse)
    signal wheelUp()
    signal wheelDown()

    color: bg
    radius: Theme.pillRadius
    implicitWidth: Math.max(contentWidth, minContentWidth) + 2 * Theme.pillPaddingH
    implicitHeight: Theme.pillHeight

    Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }

    Text {
        id: label
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.fg
        textFormat: Text.PlainText

        Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) root.wheelUp();
            else if (wheel.angleDelta.y < 0) root.wheelDown();
        }
    }

    BarTooltip {
        id: tooltip
        target: root
        text: root.tooltipText
        rich: root.tooltipRich
        show: mouseArea.containsMouse
    }
}
