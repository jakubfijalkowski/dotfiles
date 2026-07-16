import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import qs
import qs.components

// wireplumber: "{icon} {volume}%", muted "", click mutes, right-click
// opens pavucontrol, scroll steps 5%
BarPill {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0

    readonly property string icon: {
        if (muted) return "\u{EEE8}";
        const icons = ["\u{F026}", "\u{F027}", "\u{F028}"];
        return icons[Math.min(icons.length - 1, Math.floor(volume * icons.length))];
    }

    PwObjectTracker { objects: sink ? [sink] : [] }

    visible: sink !== null
    // #wireplumber { min-width: 28pt }
    minContentWidth: 37
    accent: muted ? Theme.lavender : Theme.flamingo
    contentWidth: content.implicitWidth

    // The icon renders as a Symbols Nerd Font run, the text as Iosevka,
    // mirroring pango's font itemization of "{icon} {volume}%".
    Row {
        id: content
        anchors.centerIn: parent

        Text {
            id: iconLabel
            anchors.baseline: volumeLabel.baseline
            font.family: Theme.iconFontFamily
            font.pixelSize: Theme.iconFontSize
            color: root.fg
            textFormat: Text.PlainText
            text: root.icon

            Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: volumeLabel
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: root.fg
            textFormat: Text.PlainText
            // format-muted has no volume text
            text: root.muted ? "" : " " + Math.round(root.volume * 100) + "%"

            Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
        }
    }

    onClicked: mouse => {
        if (!sink?.audio) return;
        if (mouse.button === Qt.LeftButton)
            sink.audio.muted = !sink.audio.muted;
        else if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["uwsm", "app", "pavucontrol"]);
    }

    onWheelUp: if (sink?.audio) sink.audio.volume = Math.min(1, sink.audio.volume + 0.05)
    onWheelDown: if (sink?.audio) sink.audio.volume = Math.max(0, sink.audio.volume - 0.05)
}
