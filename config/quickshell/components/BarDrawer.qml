import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs
import "drawerShapes.js" as DrawerShapes

// A popup that flows out of the bar: its top edge meets the bar and curves into
// the body through concave fillets. Opens like a shade — a top-anchored clip
// rolls its height open. API: anchorItem / open / toggle() + default content;
// a click outside dismisses it via the focus grab.
Scope {
    id: root

    required property Item anchorItem
    property bool open: false
    // Fill: the bar's translucent surface (needs the Hyprland blur via `blurpopups`).
    property color surfaceColor: Theme.barBg
    // Launching module's accent, painted along the seam where the drawer meets the bar.
    required property color accent
    default property alias contentData: contentSlot.data

    readonly property int padding: 14
    // Shape metrics + seam trim are shared style tokens (see Theme).
    readonly property int flareRadius: Theme.drawerFlareRadius
    readonly property int bottomRadius: Theme.drawerBottomRadius
    readonly property int sideMargin: Theme.drawerSideMargin
    readonly property int bottomMargin: Theme.drawerBottomMargin
    // Drop the top edge to the bar's bottom, so it clears the pill.
    readonly property int topOffset: 2

    function toggle() { open = !open }

    PopupWindow {
        id: popup

        // Even width so the shape centers on an even-width pill without rounding
        readonly property real bodyWidth: 2 * Math.ceil((contentSlot.childrenRect.width + 2 * root.padding) / 2)
        readonly property real bodyHeight: contentSlot.childrenRect.height + 2 * root.padding

        // Live body height (tracks content, incl. expand/collapse); the shape,
        // reveal clip and mask use it, while the window stays fixed (see implicitHeight).
        readonly property real contentHeight: Math.ceil(bodyHeight) + root.flareRadius + root.bottomMargin

        anchor.item: root.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect.x: 0
        anchor.rect.width: root.anchorItem.width
        anchor.rect.y: 0
        anchor.rect.height: root.anchorItem.height + root.topOffset
        visible: root.open || openProgress > 0.001
        color: "transparent"
        implicitWidth: Math.ceil(bodyWidth) + 2 * (root.flareRadius + root.sideMargin)
        // Fixed height so the surface never resizes as the body grows (that
        // twitches the drawer); the body reflows within it and the mask clips
        // input. Keep a bar-height clear of the screen bottom, or the compositor
        // slides the popup up over the bar.
        implicitHeight: (Screens.primary ? Screens.primary.height : 1080) - 2 * Theme.barHeight

        // Restrict input to the revealed body; clicks below pass through and count as outside.
        mask: Region {
            width: popup.width
            height: Math.ceil(popup.openProgress * popup.contentHeight)
        }

        // Reveal driven by a 0→1 progress, separate from size so resizes track directly.
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

        // Top-anchored clip whose height rolls 0→full, so the panel slides out
        // of the bar like a shade.
        Item {
            id: reveal
            anchors.top: parent.top
            width: parent.width
            // Track live content height, not the (possibly larger) surface.
            height: popup.openProgress * popup.contentHeight
            clip: true

            Canvas {
                id: surface
                width: popup.width
                height: popup.contentHeight

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Component.onCompleted: requestPaint()

                Connections {
                    target: root
                    function onSurfaceColorChanged() { surface.requestPaint() }
                    function onAccentChanged() { surface.requestPaint() }
                }

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();

                    const ms = root.sideMargin, mb = root.bottomMargin;
                    const rc = root.flareRadius, rb = root.bottomRadius;
                    const k = DrawerShapes.K;

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

                    ctx.fillStyle = DrawerShapes.css(root.surfaceColor);
                    ctx.fill();

                    // Neon seam along the bar join, clipped to the shape.
                    ctx.clip();
                    DrawerShapes.paintSeam(ctx, root.accent, left, right, top, Theme);
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
