import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Effects
import qs

// Reusable popup bubble for bar modules. Instead of a plain caret it
// grows out of the anchor pill through a trumpet-flared "neck" tinted
// with the pill's color, so the popup reads as an extension of the bar.
// Opens with a springy scale from the neck; closes on outside click.
Scope {
    id: root

    required property Item anchorItem
    // The window owning anchorItem; clicks on it won't dismiss the popup
    // (lets the pill's own click handler toggle it instead).
    property var anchorWindow: null
    property bool open: false
    // Accent tinting the popup surface, and the pill color bled into the neck
    property color accent: Theme.blue
    property color neckColor: Theme.base
    default property alias contentData: contentSlot.data

    readonly property int padding: 12
    readonly property int neckHeight: 12
    readonly property int neckFlare: 14
    readonly property int cornerRadius: 14
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
        implicitHeight: Math.ceil(root.neckHeight + bubbleHeight) + root.shadowMargin

        // Morph smoothly when the content resizes (M3 fast-spatial)
        Behavior on implicitWidth {
            enabled: popup.visible
            NumberAnimation {
                duration: 350
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
            }
        }
        Behavior on implicitHeight {
            enabled: popup.visible
            NumberAnimation {
                duration: 350
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
            }
        }

        Item {
            id: wrapper
            anchors.fill: parent
            transformOrigin: Item.Top

            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.88

            // M3 expressive: effects curve for fade, spatial spring for scale
            Behavior on opacity {
                NumberAnimation {
                    duration: root.open ? 200 : 140
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: root.open ? 350 : 160
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.open
                        ? [0.42, 1.67, 0.21, 0.90, 1, 1]   // fast-spatial spring
                        : [0.3, 0, 0.8, 0.15, 1, 1]        // emphasized-accel out
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
                height: root.neckHeight + popup.bubbleHeight

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()

                Connections {
                    target: root
                    function onNeckColorChanged() { bubble.requestPaint() }
                    function onAccentChanged() { bubble.requestPaint() }
                }

                function css(c: color, a: real): string {
                    return `rgba(${Math.round(c.r * 255)}, ${Math.round(c.g * 255)}, ${Math.round(c.b * 255)}, ${a})`;
                }

                onPaint: {
                    const ctx = getContext("2d");
                    const t = root.neckHeight;
                    const x0 = 0.5, y0 = t + 0.5;
                    const x1 = width - 0.5, y1 = height - 0.5;
                    const r = root.cornerRadius, f = root.neckFlare;
                    const cx = width / 2;
                    // Neck mouth matches the anchor pill's width
                    const neckHalf = Math.min(root.anchorItem.width / 2, (width - 2 * (r + f)) / 2);

                    ctx.reset();

                    // Bubble outline: open at the neck so no border line is
                    // drawn where the popup meets the bar.
                    ctx.beginPath();
                    ctx.moveTo(cx + neckHalf, 0);
                    ctx.bezierCurveTo(cx + neckHalf, y0 * 0.7, cx + neckHalf + f * 0.4, y0, cx + neckHalf + f, y0);
                    ctx.lineTo(x1 - r, y0);
                    ctx.arcTo(x1, y0, x1, y0 + r, r);
                    ctx.lineTo(x1, y1 - r);
                    ctx.arcTo(x1, y1, x1 - r, y1, r);
                    ctx.lineTo(x0 + r, y1);
                    ctx.arcTo(x0, y1, x0, y1 - r, r);
                    ctx.lineTo(x0, y0 + r);
                    ctx.arcTo(x0, y0, x0 + r, y0, r);
                    ctx.lineTo(cx - neckHalf - f, y0);
                    ctx.bezierCurveTo(cx - neckHalf - f * 0.4, y0, cx - neckHalf, y0 * 0.7, cx - neckHalf, 0);

                    // Surface: near-opaque mantle, faintly tinted by the accent
                    const fill = ctx.createLinearGradient(0, 0, 0, height);
                    fill.addColorStop(0, css(Qt.tint(Theme.mantle, Qt.alpha(root.accent, 0.10)), 0.97));
                    fill.addColorStop(1, css(Theme.mantle, 0.97));
                    ctx.fillStyle = fill;
                    ctx.fill();
                    ctx.strokeStyle = css(Theme.surface1, 1);
                    ctx.lineWidth = 1;
                    ctx.stroke();

                    // Bleed the pill's color down through the neck so the
                    // popup looks attached to it.
                    ctx.save();
                    ctx.clip();
                    const bleed = ctx.createLinearGradient(0, 0, 0, t + 16);
                    bleed.addColorStop(0, css(root.neckColor, 0.9));
                    bleed.addColorStop(1, css(root.neckColor, 0));
                    ctx.fillStyle = bleed;
                    ctx.fillRect(cx - neckHalf - f, 0, 2 * (neckHalf + f), t + 16);
                    ctx.restore();
                }
            }

            Item {
                id: contentSlot
                x: bubble.x + root.padding
                y: root.neckHeight + root.padding
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
