import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs

// A popup that flows out of the bar. Its top edge meets the bar and curves
// down into the body through concave fillets (a "notch" / dynamic-island
// look), so the bar and popup read as one continuous surface. No border.
// It opens like a shade: a top-anchored clip rolls its height open.
//
// Same API surface as BarPopup (anchorItem / anchorWindow / open / toggle()
// + default content), so modules can swap between the two.
Scope {
    id: root

    required property Item anchorItem
    // The window owning anchorItem; clicks on it won't dismiss the popup.
    property var anchorWindow: null
    property bool open: false
    // Fill colour — the same translucent surface as the bar, so the drawer
    // reads as the bar flowing out (relies on the Hyprland blur layer, which
    // must reach the popup via `blurpopups`, to gain body).
    property color surfaceColor: Theme.barBg
    default property alias contentData: contentSlot.data

    readonly property int padding: 14
    // Concave fillet radius where the body meets the bar.
    readonly property int flareRadius: 22
    // Convex bottom corner radius.
    readonly property int bottomRadius: 16
    // Overshoot/blur breathing room beside the flares and below the body.
    readonly property int sideMargin: 10
    readonly property int bottomMargin: 16
    // Distance below the pill's bottom to place the drawer's top edge. The
    // pill is centered in the bar, so ~2px drops the top to the bar's bottom
    // edge — the drawer flows from the bar without overlapping the pill.
    readonly property int topOffset: 2

    function toggle() { open = !open }

    PopupWindow {
        id: popup

        // Even width so the shape centers on an even-width pill without rounding
        readonly property real bodyWidth: 2 * Math.ceil((contentSlot.childrenRect.width + 2 * root.padding) / 2)
        readonly property real bodyHeight: contentSlot.childrenRect.height + 2 * root.padding

        anchor.item: root.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect.x: 0
        anchor.rect.width: root.anchorItem.width
        anchor.rect.y: 0
        // Top of the popup window sits `topOffset` below the pill's bottom,
        // i.e. at the bar's bottom edge, so the drawer clears the pill.
        anchor.rect.height: root.anchorItem.height + root.topOffset
        visible: root.open || reveal.height > 0.5
        color: "transparent"
        implicitWidth: Math.ceil(bodyWidth) + 2 * (root.flareRadius + root.sideMargin)
        implicitHeight: Math.ceil(bodyHeight) + root.flareRadius + root.bottomMargin

        // Content-resize morph — smooth, no spring.
        Behavior on implicitWidth {
            enabled: popup.visible
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }
        Behavior on implicitHeight {
            enabled: popup.visible
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        // Drawer reveal: a top-anchored clip whose height rolls open from 0 to
        // full (and back on close), so the panel slides out of the bar like a
        // shade — no scale, no spring.
        Item {
            id: reveal
            anchors.top: parent.top
            width: parent.width
            height: root.open ? parent.height : 0
            clip: true

            Behavior on height {
                NumberAnimation {
                    duration: root.open ? 300 : 220
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.open
                        ? [0.05, 0.7, 0.1, 1.0, 1, 1]   // M3 emphasized decelerate
                        : [0.3, 0.0, 0.8, 0.15, 1, 1]   // M3 emphasized accelerate
                }
            }

            Canvas {
                id: surface
                width: popup.width
                height: popup.height

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()

                Connections {
                    target: root
                    function onSurfaceColorChanged() { surface.requestPaint() }
                }

                function css(c: color): string {
                    return `rgba(${Math.round(c.r * 255)}, ${Math.round(c.g * 255)}, ${Math.round(c.b * 255)}, ${c.a})`;
                }

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();

                    const ms = root.sideMargin, mb = root.bottomMargin;
                    const rc = root.flareRadius, rb = root.bottomRadius;
                    const k = 0.5523; // cubic-bezier quarter-circle constant

                    const left = ms, right = width - ms;      // outer top corners, meet the bar
                    const bl = ms + rc, br = width - ms - rc;  // straight body sides
                    const top = 0, bottom = height - mb;

                    ctx.beginPath();
                    ctx.moveTo(left, top);
                    // top-left concave fillet: bar edge -> body side
                    ctx.bezierCurveTo(left + k * rc, top, bl, top + rc - k * rc, bl, top + rc);
                    ctx.lineTo(bl, bottom - rb);
                    ctx.arcTo(bl, bottom, bl + rb, bottom, rb);          // bottom-left convex
                    ctx.lineTo(br - rb, bottom);
                    ctx.arcTo(br, bottom, br, bottom - rb, rb);          // bottom-right convex
                    ctx.lineTo(br, top + rc);
                    // top-right concave fillet: body side -> bar edge
                    ctx.bezierCurveTo(br, top + rc - k * rc, right - k * rc, top, right, top);
                    ctx.closePath();

                    ctx.fillStyle = css(root.surfaceColor);
                    ctx.fill();
                }
            }

            Item {
                id: contentSlot
                x: root.sideMargin + root.flareRadius + root.padding
                y: root.flareRadius + root.padding
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
