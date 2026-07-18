import QtQuick
import QtQuick.Controls
import qs

// The shared slider look: a slim tinted track with a round knob outlined in
// crust. Audio levels use the defaults; the mpris seek bar runs slightly
// slimmer and hides its knob while seeking isn't possible.
Slider {
    id: root

    property color tint: Theme.flamingo
    property int trackThickness: 5
    property int handleDiameter: 14
    property bool hideHandleWhenDisabled: false

    from: 0
    to: 1
    implicitHeight: handleDiameter + 4

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: root.trackThickness
        radius: Math.ceil(height / 2)
        color: Theme.alpha(Theme.surface2, 0.6)

        Rectangle {
            width: root.position * parent.width
            height: parent.height
            radius: parent.radius
            color: root.tint
        }
    }
    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.handleDiameter
        height: root.handleDiameter
        radius: root.handleDiameter / 2
        color: root.tint
        border.width: 2
        border.color: Theme.crust
        visible: !root.hideHandleWhenDisabled || root.enabled
    }
}
