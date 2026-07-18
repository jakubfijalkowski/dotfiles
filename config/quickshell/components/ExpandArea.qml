import QtQuick

// Slide-open container: clips its content and animates height 0↔content when
// `expanded` toggles. Children lay out in an internal Column.
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
