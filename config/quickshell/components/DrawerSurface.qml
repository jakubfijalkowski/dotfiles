import QtQuick
import qs
import "drawerShapes.js" as DrawerShapes

// The body BarDrawer and EdgeDrawer share: a 0→1 open progress, a top-anchored
// clip that rolls the body open like a shade, the painted outline + neon seam,
// and the content slot. The owning window only handles placement.
Item {
    id: root

    property bool open: false
    required property color accent
    // Fill: the bar's translucent surface (needs the Hyprland blur via `blurpopups`).
    property color surfaceColor: Theme.barBg
    // "bar" hangs below a pill; "corner" is hinged on the bar and the screen edge.
    property string edge: "bar"
    property int padding: 14
    default property alias contentData: contentSlot.data

    readonly property bool corner: edge === "corner"
    readonly property int flareRadius: Theme.drawerFlareRadius
    readonly property int sideMargin: Theme.drawerSideMargin
    // Even under a pill, so the shape centers on an even-width pill without rounding.
    readonly property real bodyWidth: {
        const w = contentSlot.childrenRect.width + 2 * padding;
        return corner ? Math.ceil(w) : 2 * Math.ceil(w / 2);
    }
    readonly property real bodyHeight: contentSlot.childrenRect.height + 2 * padding
    // Live body height (tracks content, incl. expand/collapse). The shape, clip
    // and the owner's input mask follow it; the window itself stays fixed-size,
    // since resizing the surface twitches the drawer.
    readonly property real contentHeight: Math.ceil(bodyHeight) + flareRadius + Theme.drawerBottomMargin
    readonly property real revealedHeight: openProgress * contentHeight
    // Still true while the close animation runs.
    readonly property bool shown: open || openProgress > 0.001

    // Separate from the size, so content resizes track directly.
    property real openProgress: open ? 1 : 0
    Behavior on openProgress {
        NumberAnimation {
            duration: root.open ? Theme.drawerOpenDuration : Theme.drawerCloseDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.open ? Theme.curveDecel : Theme.curveAccel
        }
    }

    Item {
        id: reveal
        width: parent.width
        height: root.revealedHeight
        clip: true

        Canvas {
            id: surface
            width: root.width
            height: root.contentHeight

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
                const shape = root.corner ? DrawerShapes.cornerPath : DrawerShapes.barPath;
                const seam = shape(ctx, width, height, root.flareRadius, Theme.drawerBottomRadius,
                                   root.sideMargin, Theme.drawerBottomMargin);
                ctx.fillStyle = DrawerShapes.css(root.surfaceColor);
                ctx.fill();
                // Clip so the trim can't spill past the fillets.
                ctx.clip();
                DrawerShapes.paintSeam(ctx, root.accent, seam[0], seam[1], 0, Theme);
            }
        }

        Item {
            id: contentSlot
            x: root.sideMargin + root.flareRadius + root.padding
            // A corner drawer's window already starts at the bar's bottom.
            y: (root.corner ? 0 : root.flareRadius) + root.padding
            width: childrenRect.width
            height: childrenRect.height
        }
    }
}
