import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import qs

// Reusable popup bubble for bar modules. Renders below the anchor pill
// with a caret pointing at it, animates open from the caret, and closes
// when clicking anywhere outside.
Scope {
    id: root

    required property Item anchorItem
    // The window owning anchorItem; clicks on it won't dismiss the popup
    // (lets the pill's own click handler toggle it instead).
    property var anchorWindow: null
    property bool open: false
    default property alias contentData: contentSlot.data

    readonly property int padding: 10
    readonly property int caretHeight: 10
    readonly property int caretHalfWidth: 10
    readonly property int cornerRadius: 8
    readonly property int shadowMargin: 20

    function toggle() { open = !open }

    PopupWindow {
        id: popup

        readonly property real bubbleWidth: contentSlot.childrenRect.width + 2 * root.padding
        readonly property real bubbleHeight: contentSlot.childrenRect.height + 2 * root.padding

        anchor.item: root.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        visible: root.open || wrapper.opacity > 0.01
        color: "transparent"
        implicitWidth: Math.ceil(bubbleWidth) + 2 * root.shadowMargin
        implicitHeight: Math.ceil(root.caretHeight + bubbleHeight) + root.shadowMargin

        Item {
            id: wrapper
            anchors.fill: parent
            transformOrigin: Item.Top

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.86

            Behavior on opacity {
                NumberAnimation { duration: root.open ? 170 : 120; easing.type: Easing.OutQuad }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: root.open ? 260 : 140
                    easing.type: root.open ? Easing.OutBack : Easing.InQuad
                    easing.overshoot: 1.15
                }
            }

            MultiEffect {
                anchors.fill: bubble
                source: bubble
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.55)
                shadowBlur: 0.9
                shadowVerticalOffset: 3
            }

            Canvas {
                id: bubble
                x: root.shadowMargin
                width: popup.bubbleWidth
                height: root.caretHeight + popup.bubbleHeight

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()

                onPaint: {
                    const ctx = getContext("2d");
                    const x0 = 0.5, y0 = root.caretHeight + 0.5;
                    const x1 = width - 0.5, y1 = height - 0.5;
                    const r = root.cornerRadius, cx = width / 2, cw = root.caretHalfWidth;

                    ctx.reset();
                    ctx.beginPath();
                    ctx.moveTo(x0 + r, y0);
                    ctx.lineTo(cx - cw, y0);
                    ctx.lineTo(cx, 0.5);
                    ctx.lineTo(cx + cw, y0);
                    ctx.lineTo(x1 - r, y0);
                    ctx.arcTo(x1, y0, x1, y0 + r, r);
                    ctx.lineTo(x1, y1 - r);
                    ctx.arcTo(x1, y1, x1 - r, y1, r);
                    ctx.lineTo(x0 + r, y1);
                    ctx.arcTo(x0, y1, x0, y1 - r, r);
                    ctx.lineTo(x0, y0 + r);
                    ctx.arcTo(x0, y0, x0 + r, y0, r);
                    ctx.closePath();

                    ctx.fillStyle = Theme.alpha(Theme.mantle, 0.97);
                    ctx.fill();
                    ctx.strokeStyle = Theme.surface1;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            }

            Item {
                id: contentSlot
                x: bubble.x + root.padding
                y: root.caretHeight + root.padding
                width: childrenRect.width
                height: childrenRect.height
            }
        }
    }

    HyprlandFocusGrab {
        active: root.open
        windows: root.anchorWindow ? [popup, root.anchorWindow] : [popup]
        onCleared: root.open = false
    }
}
