import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs

// Reusable popup bubble for bar modules: a rounded-rectangle surface that
// opens just below its anchor pill. Opens with a springy scale from the top
// edge (so it reads as dropping out of the pill); closes on outside click.
Scope {
    id: root

    required property Item anchorItem
    // The window owning anchorItem; clicks on it won't dismiss the popup
    // (lets the pill's own click handler toggle it instead).
    property var anchorWindow: null
    property bool open: false
    // Outline of the bubble; match it to the anchor pill's ring so the
    // popup reads as belonging to the same module.
    property color ringColor: Theme.popupBorder
    default property alias contentData: contentSlot.data

    readonly property int padding: 12
    readonly property real cornerRadius: Theme.popupRadius
    // Space between the pill's bottom edge and the bubble's top edge.
    readonly property int gap: 6
    // Transparent breathing room around the bubble so the open spring's scale
    // overshoot (the 1.67 control point) isn't clipped by the window bounds.
    readonly property int margin: 20

    function toggle() { open = !open }

    PopupWindow {
        id: popup

        // Even width, so centering on an even-width pill needs no rounding
        readonly property real bubbleWidth: 2 * Math.ceil((contentSlot.childrenRect.width + 2 * root.padding) / 2)
        readonly property real bubbleHeight: contentSlot.childrenRect.height + 2 * root.padding

        anchor.item: root.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect.x: 0
        anchor.rect.width: root.anchorItem.width
        // Anchor the window so the bubble's top edge (which sits `margin`
        // inside the window) lands `gap` below the pill's bottom.
        anchor.rect.y: 0
        anchor.rect.height: root.anchorItem.height + root.gap - root.margin
        visible: root.open || wrapper.opacity > 0.01
        color: "transparent"
        implicitWidth: Math.ceil(bubbleWidth) + 2 * root.margin
        implicitHeight: Math.ceil(bubbleHeight) + 2 * root.margin

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

            Rectangle {
                id: bubble
                x: root.margin
                y: root.margin
                width: parent.width - 2 * root.margin
                height: parent.height - 2 * root.margin
                radius: root.cornerRadius
                color: Theme.popupBg
                border.width: root.ringColor.a > 0 ? 1 : 0
                border.color: root.ringColor
            }

            Item {
                id: contentSlot
                x: root.margin + root.padding
                y: root.margin + root.padding
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
