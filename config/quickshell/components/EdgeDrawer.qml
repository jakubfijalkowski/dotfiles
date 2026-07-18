import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs
import "drawerShapes.js" as DrawerShapes

// A drawer that flows out of the TOP-RIGHT CORNER — the counterpart to
// BarDrawer, sharing its "dynamic-island" look but hinged on two edges instead
// of one: its top edge meets the bar and its right edge meets the right screen
// edge, so it reads as the bar and the screen edge flowing together into a
// panel. The two free corners curve away through concave fillets (top-left:
// bar -> left side; bottom-right: screen edge -> bottom) with a convex
// bottom-left. No border — depth comes from the translucent fill under blur.
// It opens like a shade: a top-anchored clip rolls its height open, so the
// panel drops down out of the bar. Content-sized (width + height follow it).
//
// API mirrors BarDrawer (open / toggle() + default content). Pass
// `screen` to pin it to the bar's monitor; a click anywhere outside the drawer
// (including on the bar) dismisses it through the focus grab.
Scope {
    id: root

    property var screen: null
    property bool open: false
    // Fill colour — the bar's translucent crust, so the drawer reads as the bar
    // flowing out (relies on the Hyprland blur reaching the popup via
    // `blurpopups` to gain body).
    property color surfaceColor: Theme.barBg
    // Launching module's accent, laid along the seam where the drawer meets
    // the bar (see onPaint), so the drawer reads as the pill's colour flowing
    // out — matching BarDrawer.
    required property color accent
    default property alias contentData: contentSlot.data

    readonly property int padding: 16
    // Shape metrics + seam trim are shared style tokens (see Theme).
    readonly property int flareRadius: Theme.drawerFlareRadius
    readonly property int bottomRadius: Theme.drawerBottomRadius
    readonly property int sideMargin: Theme.drawerSideMargin
    readonly property int bottomMargin: Theme.drawerBottomMargin
    // Top edge sits at the bar's bottom, so the drawer flows from the bar.
    readonly property int topEdge: Theme.barHeight

    function toggle() { open = !open }

    PanelWindow {
        id: win

        readonly property real bodyWidth: contentSlot.childrenRect.width + 2 * root.padding
        readonly property real bodyHeight: contentSlot.childrenRect.height + 2 * root.padding

        screen: root.screen
        // Pin to the top-right corner; the right edge is flush with the screen
        // (no right margin), the top with the bar. Ignore exclusive zones so the
        // window anchors to the true screen top (topEdge then lands the shape at
        // the bar's bottom) rather than being pushed below the bar's zone.
        anchors {
            top: true
            right: true
        }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        visible: root.open || win.openProgress > 0.001
        implicitWidth: Math.ceil(bodyWidth) + root.flareRadius + root.sideMargin
        implicitHeight: root.topEdge + Math.ceil(bodyHeight) + root.flareRadius + root.bottomMargin

        // Open/close reveal driven by a 0->1 progress, kept separate from size so
        // that resizing tracks implicitWidth/Height directly instead of a second
        // animation chasing a moving target. Shade-style motion like BarDrawer:
        // M3 emphasized decelerate in, accelerate out — no spring.
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

        // Reveal: a top-anchored clip whose height rolls open from 0 to full (and
        // back on close), so the panel drops down out of the bar like a shade —
        // no scale, no spring. Height = progress x full, so once open it equals
        // the window height and resizes track it instantly.
        Item {
            id: reveal
            anchors.top: parent.top
            width: parent.width
            height: win.openProgress * parent.height
            clip: true

            Item {
                id: full
                // Anchored to the fixed top edge so it stays put in window space
                // while the clip's bottom edge sweeps down over it.
                anchors.top: parent.top
                width: win.width
                height: win.height

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

                        const topY = root.topEdge;         // top edge, meets the bar
                        const rightX = width;              // right edge, meets the screen
                        const bodyLeft = ms + rc;          // straight left body side
                        const bodyBottom = height - mb - rc;
                        // The right edge runs rc past the body bottom before it
                        // fillets in, mirroring how the top runs rc past the left
                        // side before it fillets down.
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

                        // Neon seam trim along the top edge where the drawer
                        // meets the bar (see drawerShapes.js), clipped to the
                        // shape so it can't spill past the fillets. The top
                        // edge runs ms..rightX at topY.
                        ctx.clip();
                        DrawerShapes.paintSeam(ctx, root.accent, ms, rightX, topY, Theme);
                    }
                }

                Item {
                    id: contentSlot
                    // bodyLeft (= sideMargin + flareRadius) + padding; y clears the bar.
                    x: root.sideMargin + root.flareRadius + root.padding
                    y: root.topEdge + root.padding
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
