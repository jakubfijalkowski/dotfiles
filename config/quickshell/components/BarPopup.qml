import Quickshell
import Quickshell.Hyprland
import QtQuick
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
    // Outline of the bubble; match it to the anchor pill's ring so the
    // popup reads as a scaled-up pill of the same module.
    property color ringColor: Theme.popupBorder
    default property alias contentData: contentSlot.data

    readonly property int padding: 12
    readonly property int neckHeight: 12
    readonly property int neckFlare: 14
    readonly property real cornerRadius: Theme.popupRadius
    readonly property int shadowMargin: 20

    function toggle() { open = !open }

    PopupWindow {
        id: popup

        // Even width, so centering on an even-width pill needs no rounding
        readonly property real bubbleWidth: 2 * Math.ceil((contentSlot.childrenRect.width + 2 * root.padding) / 2)
        readonly property real bubbleHeight: contentSlot.childrenRect.height + 2 * root.padding

        anchor.item: root.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        // Rise 2px into the pill: covers its bottom border so the pill
        // opens straight into the neck.
        anchor.rect.x: 0
        anchor.rect.y: 0
        anchor.rect.width: root.anchorItem.width
        anchor.rect.height: root.anchorItem.height - 2
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

            Canvas {
                id: bubble
                anchors.fill: parent

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()

                Connections {
                    target: root
                    function onRingColorChanged() { bubble.requestPaint() }
                }

                function css(c: color, a: real): string {
                    return `rgba(${Math.round(c.r * 255)}, ${Math.round(c.g * 255)}, ${Math.round(c.b * 255)}, ${a})`;
                }

                onPaint: {
                    const ctx = getContext("2d");
                    const t = root.neckHeight;
                    const m = root.shadowMargin;
                    const x0 = m + 0.5, y0 = t + 0.5;
                    const x1 = width - m - 0.5, y1 = height - m - 0.5;
                    const r = root.cornerRadius, f = root.neckFlare;
                    // Pill and bubble widths are kept even integers, so the
                    // compositor centers the popup on the pill exactly and
                    // the neck can simply sit at the bubble's center.
                    const cx = width / 2;
                    // Neck walls continue the pill's side borders exactly
                    // (the pill's bottom corners square off while open).
                    // The extra -0.25 offsets the AA phase difference between
                    // the canvas stroke and the pill's Rectangle border.
                    const neckHalf = Math.max(8,
                        Math.min(root.anchorItem.width / 2 - 0.75, (width - 2 * (r + f)) / 2));

                    ctx.reset();

                    // The walls stay straight through the 2px rise into the
                    // pill and the 2px of bar below it; the flare only starts
                    // once they clear the bar's bottom edge.
                    const s = 4;

                    // Bubble outline: open at the neck so no border line is
                    // drawn where the popup meets the bar.
                    ctx.beginPath();
                    ctx.moveTo(cx + neckHalf, 0);
                    ctx.lineTo(cx + neckHalf, s);
                    ctx.bezierCurveTo(cx + neckHalf, s + (y0 - s) * 0.7, cx + neckHalf + f * 0.4, y0, cx + neckHalf + f, y0);
                    ctx.lineTo(x1 - r, y0);
                    ctx.arcTo(x1, y0, x1, y0 + r, r);
                    ctx.lineTo(x1, y1 - r);
                    ctx.arcTo(x1, y1, x1 - r, y1, r);
                    ctx.lineTo(x0 + r, y1);
                    ctx.arcTo(x0, y1, x0, y1 - r, r);
                    ctx.lineTo(x0, y0 + r);
                    ctx.arcTo(x0, y0, x0 + r, y0, r);
                    ctx.lineTo(cx - neckHalf - f, y0);
                    ctx.bezierCurveTo(cx - neckHalf - f * 0.4, y0, cx - neckHalf, s + (y0 - s) * 0.7, cx - neckHalf, s);
                    ctx.lineTo(cx - neckHalf, 0);

                    const surface = Theme.popupBg;
                    ctx.shadowColor = "rgba(0, 0, 0, 0.55)";
                    ctx.shadowBlur = 12;
                    ctx.shadowOffsetY = 3;
                    ctx.fillStyle = css(surface, surface.a);
                    ctx.fill();
                    ctx.shadowColor = "transparent";
                    ctx.shadowBlur = 0;
                    ctx.shadowOffsetY = 0;
                    ctx.strokeStyle = css(root.ringColor, root.ringColor.a);
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            }

            Item {
                id: contentSlot
                x: root.shadowMargin + root.padding
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
