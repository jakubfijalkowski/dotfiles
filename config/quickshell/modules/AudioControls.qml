import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import qs
import qs.components

// Audio drawer: output/input volume with device selectors (AudioDeviceCard)
// and a collapsible per-app mixer. Values from PipeWire.
Column {
    id: root

    // True while the drawer is open; gates PipeWire node tracking so closed
    // drawers don't sync every node.
    property bool active: false

    signal closeRequested()
    signal opened()
    onOpened: {
        outCard.expanded = false;
        inCard.expanded = false;
        appCol.expanded = false;
    }

    readonly property int listWidth: 340

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    function mediaClass(n) {
        return n && n.properties ? (n.properties["media.class"] ?? "") : "";
    }

    // `n.audio` is set before binding; `media.class` only populates once tracked
    // — so track all audio nodes and filter by isSink/isStream.
    readonly property var audioNodes: Pipewire.nodes.values.filter(n => n.audio)
    readonly property var outputs: audioNodes.filter(n => n.isSink && !n.isStream)
    readonly property var inputs: audioNodes.filter(n => !n.isSink && !n.isStream)
    readonly property var streams: audioNodes.filter(n => n.isStream && root.mediaClass(n) === "Stream/Output/Audio")

    PwObjectTracker {
        objects: root.active ? root.audioNodes : []
    }

    function resolveIcon(node) {
        const p = node.properties ?? ({});
        return Icons.resolve([p["application.icon-name"], p["application.name"], node.name]);
    }

    spacing: 8

    AudioDeviceCard {
        id: outCard
        width: root.listWidth
        node: root.sink
        nodes: root.outputs
        kind: "Output"
        tint: Theme.flamingo
        glyphOn: "\u{F057E}"   // volume-high
        glyphOff: "\u{F0581}"  // volume-off
    }

    AudioDeviceCard {
        id: inCard
        width: root.listWidth
        node: root.source
        nodes: root.inputs
        kind: "Input"
        tint: Theme.sapphire
        glyphOn: "\u{F036C}"   // mic
        glyphOff: "\u{F036D}"  // mic-off
    }

    Card {
        width: root.listWidth
        padding: 8

        Column {
            id: appCol
            width: parent.width
            spacing: 8

            property bool expanded: false

            ExpandHeader {
                glyph: "\u{F062E}"   // tune
                glyphColor: Theme.mauve
                strong: true
                text: "Applications · " + root.streams.length
                expanded: appCol.expanded
                onToggled: appCol.expanded = !appCol.expanded
            }

            ExpandArea {
                expanded: appCol.expanded

                Text {
                    visible: root.streams.length === 0
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    topPadding: 4
                    bottomPadding: 6
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.subtext0
                    text: "Nothing is playing"
                }

                Repeater {
                    model: root.streams

                    Item {
                        id: appEntry
                        required property var modelData
                        width: appCol.width
                        height: appInner.implicitHeight + 8

                        readonly property string appName: {
                            const p = modelData.properties;
                            return (p && (p["application.name"] || p["node.name"])) || modelData.name || "App";
                        }

                        Row {
                            id: appInner
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Item {
                                id: appIconSlot
                                anchors.verticalCenter: parent.verticalCenter
                                width: 26
                                height: 26

                                Image {
                                    id: appImg
                                    anchors.fill: parent
                                    sourceSize.width: 52
                                    sourceSize.height: 52
                                    fillMode: Image.PreserveAspectFit
                                    source: root.resolveIcon(appEntry.modelData)
                                    visible: status === Image.Ready
                                }
                                // Monogram tile when the app has no themed icon.
                                Rectangle {
                                    anchors.fill: parent
                                    visible: appImg.status !== Image.Ready
                                    radius: 7
                                    color: Theme.alpha(Theme.mauve, 0.15)
                                    border.width: 1
                                    border.color: Theme.alpha(Theme.mauve, 0.4)

                                    Text {
                                        anchors.centerIn: parent
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        color: Theme.mauve
                                        text: (appEntry.appName.charAt(0) || "?").toUpperCase()
                                    }
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - appIconSlot.width - parent.spacing
                                spacing: 4

                                Text {
                                    width: parent.width
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupCaptionSize
                                    color: Theme.subtext1
                                    elide: Text.ElideRight
                                    text: appEntry.appName
                                }

                                Row {
                                    width: parent.width
                                    spacing: 8

                                    StyledSlider {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 44 - parent.spacing
                                        tint: Theme.mauve
                                        value: appEntry.modelData.audio.volume
                                        onMoved: appEntry.modelData.audio.volume = value
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 44
                                        horizontalAlignment: Text.AlignRight
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.popupBodySize
                                        color: Theme.subtext1
                                        text: Math.round(appEntry.modelData.audio.volume * 100) + "%"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ActionButton {
        width: root.listWidth
        label: "Sound settings"
        tint: Theme.flamingo
        // nf-md-cog
        glyph: "\u{F0493}"
        onActivated: {
            Apps.launch(["pavucontrol"]);
            root.closeRequested();
        }
    }
}
