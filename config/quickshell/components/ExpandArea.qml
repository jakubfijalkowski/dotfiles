import QtQuick

// A vertical slide-open container: clips its content and quickly animates its
// height between 0 and the content's height when `expanded` toggles. Children
// are laid out top-to-bottom in an internal Column. Place it where the
// surrounding layout tracks its height (e.g. a Column whose window sizes to
// fit) so the reveal reads as one coherent slide.
Item {
    id: area

    property bool expanded: false
    property int animationDuration: 150
    property alias spacing: col.spacing
    default property alias content: col.data

    clip: true
    width: parent ? parent.width : 0
    implicitHeight: col.implicitHeight
    height: expanded ? implicitHeight : 0

    Behavior on height {
        NumberAnimation { duration: area.animationDuration; easing.type: Easing.OutCubic }
    }

    Column {
        id: col
        width: area.width
        spacing: 4
    }
}
