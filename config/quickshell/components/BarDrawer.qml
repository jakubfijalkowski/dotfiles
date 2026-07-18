import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs
import "drawerShapes.js" as DrawerShapes

// A popup that flows out of the bar. Its top edge meets the bar and curves
// down into the body through concave fillets (a "notch" / dynamic-island
// look), so the bar and popup read as one continuous surface. No border.
// It opens like a shade: a top-anchored clip rolls its height open.
//
// API: anchorItem / open / toggle() + default content (EdgeDrawer mirrors
// it). A click anywhere outside the drawer — including on the bar or its
// pill — dismisses it via the focus grab.
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
    // Shape metrics + seam trim are shared style tokens (see Theme).
    readonly property int flareRadius: Theme.drawerFlareRadius
    readonly property int bottomRadius: Theme.drawerBottomRadius
    readonly property int sideMargin: Theme.drawerSideMargin
    readonly property int bottomMargin: Theme.drawerBottomMargin
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

        // Exact height the drawer body needs right now — tracks the live
        // content, incl. a section's expand/collapse animation, frame by frame.
        // The painted shape, the reveal clip and the input mask use this so the
        // body grows and shrinks smoothly, while the window itself stays a fixed
        // size (see implicitHeight).
        readonly property real contentHeight: Math.ceil(bodyHeight) + root.flareRadius + root.bottomMargin

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
        // Fixed height so the window NEVER resizes as the body expands or
        // collapses (resizing a Wayland surface to hug the body twitched the
        // whole drawer — the reason NotificationOverlay never resizes either).
        // The body reflows *within* this fixed surface and the mask below clips
        // the interactive/opaque area to it, so a click past the body still
        // falls outside the drawer and dismisses it. It can't be the full gap
        // below the bar, though: an xdg-popup whose bottom would pass the screen
        // edge gets slid up by the compositor, dragging its top over the bar, so
        // keep a bar-height of clearance above the screen bottom.
        implicitHeight: (Screens.primary ? Screens.primary.height : 1080) - 2 * Theme.barHeight

        // Restrict input (and the focus grab's notion of "inside") to the
        // revealed body; the transparent remainder below passes clicks through
        // and counts as outside, so the drawer dismisses.
        mask: Region {
            width: popup.width
            height: Math.ceil(popup.openProgress * popup.contentHeight)
        }

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
            // Track the live content height, not the surface (which may be held
            // larger mid-resize), so the body reveals and shrinks smoothly.
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

                    // Neon seam trim along the bar join (see drawerShapes.js
                    // for the rationale), clipped to the shape so it can't
                    // spill past the fillets.
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
