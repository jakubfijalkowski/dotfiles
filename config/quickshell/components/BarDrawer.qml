import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs

// A popup that flows out of the bar. Its top edge meets the bar and curves
// down into the body through concave fillets (a "notch" / dynamic-island
// look), so the bar and popup read as one continuous surface. No border.
// It opens like a shade: a top-anchored clip rolls its height open.
//
// Same API surface as BarPopup (anchorItem / open / toggle() + default
// content), so modules can swap between the two. A click anywhere outside the
// drawer — including on the bar or its pill — dismisses it via the focus grab.
Scope {
    id: root

    required property Item anchorItem
    property bool open: false
    // Fill colour — the same translucent surface as the bar, so the drawer
    // reads as the bar flowing out (relies on the Hyprland blur layer, which
    // must reach the popup via `blurpopups`, to gain body).
    property color surfaceColor: Theme.barBg
    // Launching module's accent, laid along the seam where the drawer meets
    // the bar (see onPaint) so the drawer reads as the pill's colour flowing
    // out — the bar's outline language.
    required property color accent
    default property alias contentData: contentSlot.data

    readonly property int padding: 14
    // Concave fillet radius where the body meets the bar.
    readonly property int flareRadius: 22
    // Seam trim along the top edge: a crisp accent core plus a soft glow that
    // bleeds down into the body.
    readonly property real seamLine: 1.5
    readonly property real seamLineAlpha: 0.9
    readonly property real seamGlow: 10
    readonly property real seamGlowAlpha: 0.28
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
        visible: root.open || openProgress > 0.001
        color: "transparent"
        implicitWidth: Math.ceil(bodyWidth) + 2 * (root.flareRadius + root.sideMargin)
        implicitHeight: Math.ceil(bodyHeight) + root.flareRadius + root.bottomMargin

        // Open/close reveal driven by a 0→1 progress, kept separate from the
        // size so that resizing (expanding a section) tracks implicitHeight
        // directly instead of a second animation chasing a moving target.
        property real openProgress: root.open ? 1 : 0
        Behavior on openProgress {
            NumberAnimation {
                duration: root.open ? 300 : 220
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.open
                    ? [0.05, 0.7, 0.1, 1.0, 1, 1]   // M3 emphasized decelerate
                    : [0.3, 0.0, 0.8, 0.15, 1, 1]   // M3 emphasized accelerate
            }
        }

        // No resize animation: when content changes (expanding a section) the
        // window snaps to fit so nothing slides around. Only open/close is
        // animated, via openProgress below.

        // Drawer reveal: a top-anchored clip whose height rolls open from 0 to
        // full (and back on close), so the panel slides out of the bar like a
        // shade — no scale, no spring. Height = progress × full, so once open
        // it equals the window height and resizes track it instantly.
        Item {
            id: reveal
            anchors.top: parent.top
            width: parent.width
            height: popup.openProgress * parent.height
            clip: true

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

                    // Neon seam trim. The top edge is two independently-blurred
                    // surfaces meeting, which leaves a faint mismatch line.
                    // Rather than hide it, own it: lay the accent along the join
                    // — a soft glow bleeding into the body plus a crisp core — so
                    // the intentional line dominates the accidental one and the
                    // drawer reads as the pill's colour flowing out. Reuse the
                    // shape as a clip so the trim can't spill past the fillets.
                    ctx.clip();
                    const a = root.accent;
                    const argb = `${Math.round(a.r * 255)}, ${Math.round(a.g * 255)}, ${Math.round(a.b * 255)}`;
                    const glow = ctx.createLinearGradient(0, top, 0, top + root.seamGlow);
                    glow.addColorStop(0, `rgba(${argb}, ${root.seamGlowAlpha})`);
                    glow.addColorStop(1, `rgba(${argb}, 0)`);
                    ctx.fillStyle = glow;
                    ctx.fillRect(left, top, right - left, root.seamGlow);
                    ctx.fillStyle = `rgba(${argb}, ${root.seamLineAlpha})`;
                    ctx.fillRect(left, top, right - left, root.seamLine);
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
        windows: [popup]
        onCleared: root.open = false
    }
}
