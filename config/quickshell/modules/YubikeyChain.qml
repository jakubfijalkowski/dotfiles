import QtQuick
import qs
import qs.components

// YubiKey drawer: who asked for the touch, as each requester's parent chain
// (requester first, up to init). Snapshotted when the request started, since
// the processes usually exit right after the touch.
Column {
    id: root

    property var chains: []
    property var kinds: []

    readonly property int listWidth: 460
    readonly property var kindNames: ({ u2f: "FIDO2", gpg: "GPG", hmac: "HMAC" })

    spacing: 6

    DrawerHeader {
        width: root.listWidth
        glyph: "\u{F030B}"   // key, as on the bar pill
        tint: Theme.peach
        title: "YubiKey"
        subtitle: "Waiting for touch · " + root.kinds.map(k => root.kindNames[k] ?? k).join(", ")
    }

    Text {
        visible: root.chains.length === 0
        width: root.listWidth
        font.family: Theme.fontFamily
        font.pixelSize: Theme.popupBodySize
        color: Theme.subtext0
        text: "Couldn't tell which process asked."
    }

    Repeater {
        model: root.chains

        Card {
            id: card
            required property var modelData

            width: root.listWidth
            padding: 10
            verticalPadding: 6

            Column {
                id: chainColumn
                width: parent.width

                Repeater {
                    model: card.modelData

                    Item {
                        id: step
                        required property var modelData
                        required property int index

                        readonly property bool first: index === 0
                        readonly property bool last: index === card.modelData.length - 1
                        readonly property real dotCenter: nameLine.y + nameLine.height / 2

                        width: chainColumn.width
                        height: info.implicitHeight + 8

                        // Rail through the dots, so the chain reads as one lineage
                        Rectangle {
                            x: 3.5
                            y: step.first ? step.dotCenter : 0
                            width: 1
                            height: (step.last ? step.dotCenter : step.height) - y
                            visible: !(step.first && step.last)
                            color: Theme.surface2
                        }

                        Rectangle {
                            x: 0
                            y: step.dotCenter - 4
                            width: 8
                            height: 8
                            radius: 4
                            color: step.first ? Theme.peach : Theme.surface1
                            border.width: 1
                            border.color: step.first ? Theme.peach : Theme.overlay0
                        }

                        Column {
                            id: info
                            x: 18
                            y: 4
                            width: parent.width - x
                            spacing: 1

                            Row {
                                id: nameLine
                                spacing: 6

                                Text {
                                    anchors.baseline: pid.baseline
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupBodySize
                                    font.weight: Font.DemiBold
                                    color: step.first ? Theme.peach : Theme.text
                                    textFormat: Text.PlainText
                                    text: step.modelData.name
                                }
                                Text {
                                    id: pid
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupCaptionSize
                                    color: Theme.overlay1
                                    text: step.modelData.pid
                                }
                            }

                            Text {
                                visible: text !== "" && text !== step.modelData.name
                                width: parent.width
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.popupCaptionSize
                                color: Theme.subtext0
                                textFormat: Text.PlainText
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                text: step.modelData.args
                            }
                        }
                    }
                }
            }
        }
    }
}
