import QtQuick
import qs

// A single bar module: rounded pill with centered text. Modules declare
// their accent color; the active Theme variant decides how it's drawn
// (solid fill, tonal container, glass, gradient or outline).
Rectangle {
    id: root

    property alias text: label.text
    property alias fontFamily: label.font.family
    property alias fontPixelSize: label.font.pixelSize
    // The module's color; `neutral` pills use surface tones instead
    property color accent: Theme.text
    property bool neutral: false
    // Bare modules (mpris) render text only, without a pill surface
    property bool bare: false
    property real minContentWidth: 0
    // modules with composite content (e.g. icon + text runs) override this
    property real contentWidth: label.implicitWidth
    property string tooltipText: ""
    property bool tooltipRich: false
    property alias tooltipTextPixelSize: tooltip.textPixelSize
    // Active-state overlay, e.g. while the module's popup is open
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
    // Even integer width keeps a module's popup centered on it exactly, since
    // xdg popups are positioned in whole pixels.
    implicitWidth: 2 * Math.round((Math.max(contentWidth, minContentWidth) + 2 * Theme.pillPaddingH) / 2)
    implicitHeight: Theme.pillHeight

    Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
    Behavior on border.color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Theme.alpha(Theme.text, root.highlighted ? 0.12 : 0)

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
        rich: root.tooltipRich
        show: mouseArea.containsMouse
    }
}
