import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs
import "drawerShapes.js" as DrawerShapes

// A drawer that flows out of the top-right corner — BarDrawer's counterpart,
// hinged on two edges: its top edge meets the bar, its right edge meets the
// screen edge. Content-sized, opens like a shade (a top-anchored clip rolls its
// height open). API mirrors BarDrawer (open / toggle() + default content); pass
// `screen` to pin it to the bar's monitor; a click outside dismisses it.
Scope {
    id: root

    property var screen: null
    property bool open: false
    // Fill: the bar's translucent surface (needs the Hyprland blur via `blurpopups`).
    property color surfaceColor: Theme.barBg
    // Launching module's accent, painted along the seam where the drawer meets the bar.
    required property color accent
    default property alias contentData: contentSlot.data

    readonly property int padding: 16
    // Shape metrics + seam trim are shared style tokens (see Theme).
    readonly property int flareRadius: Theme.drawerFlareRadius
    readonly property int bottomRadius: Theme.drawerBottomRadius
    readonly property int sideMargin: Theme.drawerSideMargin
    readonly property int bottomMargin: Theme.drawerBottomMargin

    function toggle() { open = !open }

    PanelWindow {
        id: win

        readonly property real bodyWidth: contentSlot.childrenRect.width + 2 * root.padding
        readonly property real bodyHeight: contentSlot.childrenRect.height + 2 * root.padding

        // Live body height (tracks content); the shape, reveal clip and mask use
        // it, while the window stays fixed (see implicitHeight).
        readonly property real contentHeight: Math.ceil(bodyHeight) + root.flareRadius + root.bottomMargin

        screen: root.screen
        // Pin to the top-right corner, right edge flush with the screen. A
        // bar-height top margin drops the top to the bar's bottom so it clears
        // the bar. Ignore exclusive zones so the bar's strip doesn't push it
        // down again.
        anchors {
            top: true
            right: true
        }
        margins.top: Theme.barHeight
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: root.open || win.openProgress > 0.001
        implicitWidth: Math.ceil(bodyWidth) + root.flareRadius + root.sideMargin
        // Fixed height (bar's bottom to the screen bottom) so the surface never
        // resizes as the body grows (that twitches the drawer); the body reflows
        // within it and the mask clips input.
        implicitHeight: (root.screen ? root.screen.height : 1080) - Theme.barHeight

        // Restrict input to the revealed body; clicks below pass through and count as outside.
        mask: Region {
            width: win.width
            height: Math.ceil(win.openProgress * win.contentHeight)
        }

        // Reveal driven by a 0→1 progress, separate from size so resizes track directly.
        property real openProgress: root.open ? 1 : 0
        Behavior on openProgress {
            NumberAnimation {
                duration: root.open ? 360 : 240
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.open
                    ? [0.05, 0.7, 0.1, 1.0, 1, 1]   // M3 emphasized decelerate
                    : [0.3, 0.0, 0.8, 0.15, 1, 1]   // M3 emphasized accelerate
            }
        }

        // Top-anchored clip whose height rolls 0→full, so the panel drops out of
        // the bar like a shade.
        Item {
            id: reveal
            anchors.top: parent.top
            width: parent.width
            // Track live content height, not the (possibly larger) surface.
            height: win.openProgress * win.contentHeight
            clip: true

            Item {
                id: full
                // Anchored to the fixed top edge so it stays put while the clip sweeps down.
                anchors.top: parent.top
                width: win.width
                height: win.contentHeight

                Canvas {
                    id: surface
                    anchors.fill: parent

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

                        const topY = 0;                    // window top now sits at the bar's bottom
                        const rightX = width;              // right edge, meets the screen
                        const bodyLeft = ms + rc;          // straight left body side
                        const bodyBottom = height - mb - rc;
                        // Right edge runs rc past the body bottom before it fillets in.
                        const rightBottom = height - mb;

                        ctx.beginPath();
                        ctx.moveTo(ms, topY);                              // top-left flare, top point (on the bar)
                        ctx.lineTo(rightX, topY);                          // top edge along the bar to the screen corner
                        ctx.lineTo(rightX, rightBottom);                   // down the right edge (screen)
                        // bottom-right concave fillet: screen edge -> bottom
                        ctx.bezierCurveTo(rightX, rightBottom - k * rc, rightX - rc + k * rc, bodyBottom, rightX - rc, bodyBottom);
                        ctx.lineTo(bodyLeft + rb, bodyBottom);             // bottom edge (free)
                        ctx.arcTo(bodyLeft, bodyBottom, bodyLeft, bodyBottom - rb, rb); // bottom-left convex
                        ctx.lineTo(bodyLeft, topY + rc);                   // up the left side (free)
                        // top-left concave fillet: left side -> bar
                        ctx.bezierCurveTo(bodyLeft, topY + rc - k * rc, ms + k * rc, topY, ms, topY);
                        ctx.closePath();

                        ctx.fillStyle = DrawerShapes.css(root.surfaceColor);
                        ctx.fill();

                        // Neon seam along the top edge (ms..rightX at topY), clipped to the shape.
                        ctx.clip();
                        DrawerShapes.paintSeam(ctx, root.accent, ms, rightX, topY, Theme);
                    }
                }

                Item {
                    id: contentSlot
                    // bodyLeft + padding; the window starts at the bar's bottom, so y is just padding.
                    x: root.sideMargin + root.flareRadius + root.padding
                    y: root.padding
                    width: childrenRect.width
                    height: childrenRect.height
                }
            }
        }
    }

    HyprlandFocusGrab {
        active: root.open
        windows: [win]
        onCleared: root.open = false
    }
}
