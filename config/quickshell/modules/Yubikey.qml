import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// Touch-request pill, fed straight from yubikey-touch-detector's socket;
// ~/.local/bin/yubikey-touch-requester names who asked. Click opens the
// requesters' process chains. Hidden when idle.
BarPill {
    id: root

    property bool gpg: false
    property bool u2f: false
    property bool hmac: false
    property string requester: ""
    property var chains: []
    // Snapshot of the kinds the chains belong to, so the drawer's header
    // holds still while it closes.
    property var requestKinds: []
    // Held back until the lookup answers, so the pill doesn't pop in bare
    // and then widen once the name arrives.
    property bool resolved: false
    property string pending: ""

    readonly property var kinds: [gpg && "gpg", u2f && "u2f", hmac && "hmac"].filter(Boolean)

    // Kept up while the drawer rolls shut, so it doesn't lose its anchor.
    visible: (kinds.length > 0 && resolved) || chainPopup.shown
    accent: Theme.peach
    contentWidth: content.implicitWidth
    highlighted: chainPopup.open

    onKindsChanged: {
        if (kinds.length > 0) {
            lookup.exec([Quickshell.env("HOME") + "/.local/bin/yubikey-touch-requester", ...kinds]);
            lookupTimeout.restart();
        } else {
            lookup.running = false;
            lookupTimeout.stop();
            chainPopup.open = false;
            if (!chainPopup.shown) clear();
        }
    }

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton)
            chainPopup.toggle();
    }

    function resolve(name: string, found: var) {
        lookupTimeout.stop();
        if (kinds.length === 0) return;
        requester = name;
        chains = found;
        requestKinds = kinds;
        resolved = true;
    }

    function clear() {
        resolved = false;
        requester = "";
        chains = [];
        requestKinds = [];
    }

    Row {
        id: content
        anchors.centerIn: parent

        Text {
            anchors.baseline: requesterLabel.baseline
            font.family: Theme.mdiFontFamily
            font.pixelSize: Theme.iconFontSize
            color: root.fg
            textFormat: Text.PlainText
            text: "\u{F030B}"

            Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: requesterLabel
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: root.fg
            textFormat: Text.PlainText
            text: root.requester === "" ? "" : " " + root.requester

            Behavior on color { ColorAnimation { duration: Theme.transitionDuration; easing.type: Easing.InOutQuad } }
        }
    }

    // Messages are fixed 5-byte "GPG_1"-style codes with no delimiter, so a
    // read may carry several or split one.
    function consume(data: string) {
        for (pending += data; pending.length >= 5; pending = pending.slice(5)) {
            const on = pending[4] === "1";
            switch (pending.slice(0, 3)) {
            case "GPG": gpg = on; break;
            case "U2F": u2f = on; break;
            case "MAC": hmac = on; break;
            }
        }
    }

    // Socket keeps a failed connect around and never retries it, so rebuild
    // the whole object instead.
    function reconnect() {
        pending = "";
        gpg = u2f = hmac = false;
        detector.active = false;
        retry.start();
    }

    Loader {
        id: detector
        sourceComponent: Socket {
            path: Quickshell.env("XDG_RUNTIME_DIR") + "/yubikey-touch-detector.socket"
            connected: true
            parser: SplitParser {
                splitMarker: ""
                onRead: data => root.consume(data)
            }
            onConnectedChanged: if (!connected) root.reconnect()
            onError: root.reconnect()
        }
    }

    Timer {
        id: retry
        interval: 5000
        onTriggered: detector.active = true
    }

    Process {
        id: lookup
        stdout: StdioCollector {
            onStreamFinished: {
                let parsed = {};
                try {
                    parsed = JSON.parse(text);
                } catch (e) {
                    console.warn("yubikey: bad requester output:", text);
                }
                root.resolve(parsed.text ?? "", parsed.chains ?? []);
            }
        }
    }

    // A touch is still pending if the lookup hangs or fails; show it bare.
    Timer {
        id: lookupTimeout
        interval: 1000
        onTriggered: root.resolve(root.requester, root.chains)
    }

    BarDrawer {
        id: chainPopup
        anchorItem: root
        accent: root.accent

        onShownChanged: if (!shown && root.kinds.length === 0) root.clear()

        YubikeyChain {
            chains: root.chains
            kinds: root.requestKinds
        }
    }

    IpcHandler {
        target: "yubikey"
        function toggle(): void { if (root.visible) chainPopup.toggle(); }
    }
}
