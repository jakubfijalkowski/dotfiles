import QtQuick
import qs

// A bar module pill: rounded, centered text, accent-colored via Theme.
Rectangle {
    id: root

    property alias text: label.text
    property alias fontFamily: label.font.family
    property alias fontPixelSize: label.font.pixelSize
    // Module color; neutral pills use surface tones instead
    property color accent: Theme.text
    property bool neutral: false
    // Bare pills render text only, without a surface
    property bool bare: false
    property real minContentWidth: 0
    // Modules with composite content (icon + text runs) override this
    property real contentWidth: label.implicitWidth
    property string tooltipText: ""
    // Active overlay, e.g. while the popup is open
    property bool highlighted: false

    // Effective colors, exposed for popups that bleed the pill color
    readonly property color bg: bare ? "transparent" : Theme.pillBg(accent, neutral)
    readonly property color fg: bare ? Theme.text : Theme.pillFg(accent, neutral)

    signal clicked(var mouse)
    signal wheelUp()
    signal wheelDown()

    color: bg
    radius: Theme.pillRadius
    border.width: !bare && Theme.pillBorder(accent, neutral).a > 0 ? 1 : 0
    border.color: bare ? "transparent" : Theme.pillBorder(accent, neutral)
    // Even integer width keeps the popup centered exactly (xdg popups are
    // placed in whole pixels).
    implicitWidth: 2 * Math.round((Math.max(contentWidth, minContentWidth) + 2 * Theme.pillPaddingH) / 2)
    implicitHeight: Theme.pillHeight

    Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }

    // Faint hover lift, stronger while the popup is open.
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Theme.alpha(Theme.text,
            root.highlighted ? 0.12 : mouseArea.containsMouse ? 0.05 : 0)

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
    }

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
        show: mouseArea.containsMouse
    }
}
