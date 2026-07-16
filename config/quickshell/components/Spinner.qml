import QtQuick
import qs

// Small rotating arc used as a busy indicator.
Item {
    id: root

    property color color: Theme.text
    property real lineWidth: 2

    implicitWidth: 14
    implicitHeight: 14

    Canvas {
        id: arc
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            ctx.strokeStyle = root.color;
            ctx.lineWidth = root.lineWidth;
            ctx.lineCap = "round";
            ctx.beginPath();
            ctx.arc(width / 2, height / 2, (width - root.lineWidth) / 2, 0, Math.PI * 1.5);
            ctx.stroke();
        }
        Component.onCompleted: requestPaint()
    }

    RotationAnimator on rotation {
        from: 0
        to: 360
        duration: 900
        loops: Animation.Infinite
        running: root.visible
    }
}
