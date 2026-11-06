import QtQuick
import qs

// A bordered card inside a drawer. Content sits inset by `padding` (top and
// bottom by `verticalPadding`, for denser lists) and the card sizes to it.
Rectangle {
    id: root

    property int padding: 12
    property int verticalPadding: padding
    default property alias content: body.data

    radius: Theme.cardRadius
    color: Theme.cardBg
    border.width: 1
    border.color: Theme.cardBorder
    implicitHeight: body.childrenRect.height + 2 * verticalPadding

    Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }

    Item {
        id: body
        x: root.padding
        y: root.verticalPadding
        width: root.width - 2 * root.padding
        height: childrenRect.height
    }
}
