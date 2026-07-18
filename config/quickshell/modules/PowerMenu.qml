import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// Power drawer content: session actions (lock / logout / reboot / shutdown), a
// live CPU + RAM readout, a pager over the recent-notification ring, and a
// weather card. Stats poll only while open; weather is fetched lazily with a
// short-lived cache.
Column {
    id: root

    signal opened()
    signal closeRequested()

    // True while the drawer is open — gates the stat poll and the lazy fetches.
    property bool active: false

    readonly property color accent: Theme.red
    readonly property int menuWidth: 340

    onOpened: {
        notifIndex = 0;
        refreshWeather();
    }

    spacing: 14

    component SectionLabel: Text {
        font.family: Theme.fontFamily
        font.pixelSize: Theme.popupMicroSize
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.8
        color: Theme.overlay1
    }

    component Card: Rectangle {
        default property alias content: cardBody.data
        width: root.menuWidth
        radius: Theme.cardRadius
        color: Theme.cardBg
        border.width: 1
        border.color: Theme.cardBorder
        implicitHeight: cardBody.childrenRect.height + 2 * cardBody.anchors.margins

        Item {
            id: cardBody
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            height: childrenRect.height
        }
    }

    // Session actions
    component PowerTile: Rectangle {
        id: tile
        property string glyph: ""
        property string label: ""
        property color tint: root.accent
        required property var command

        width: (root.menuWidth - 3 * actionRow.spacing) / 4
        height: 62
        radius: Theme.cardRadius
        color: tileMouse.containsMouse ? Theme.alpha(tint, 0.16) : Theme.alpha(tint, 0.06)
        border.width: 1
        border.color: Theme.alpha(tint, tileMouse.containsMouse ? 0.75 : 0.45)

        Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

        Column {
            anchors.centerIn: parent
            spacing: 5

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.mdiFontFamily
                font.pixelSize: 22
                color: tile.tint
                text: tile.glyph
                textFormat: Text.PlainText
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.popupCaptionSize
                color: Theme.text
                text: tile.label
                textFormat: Text.PlainText
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Quickshell.execDetached(tile.command);
                root.closeRequested();
            }
        }
    }

    Row {
        id: actionRow
        width: root.menuWidth
        spacing: 8

        PowerTile { glyph: "\u{F0341}"; label: "Lock";     tint: Theme.blue;  command: ["hyprlock"] }
        PowerTile { glyph: "\u{F0343}"; label: "Logout";   tint: Theme.mauve; command: ["hyprctl", "dispatch", "exit"] }
        PowerTile { glyph: "\u{F0709}"; label: "Reboot";   tint: Theme.peach; command: ["reboot"] }
        PowerTile { glyph: "\u{F0425}"; label: "Shutdown"; tint: Theme.red;   command: ["shutdown", "now"] }
    }

    // System usage — CPU (avg across cores) + RAM
    property real cpuPct: -1               // -1 until the first sample lands
    property real memUsedGiB: 0
    property real memTotalGiB: 0
    readonly property real memPct: memTotalGiB > 0 ? memUsedGiB / memTotalGiB * 100 : 0

    // Sample CPU over a 0.3s window (so a value is ready on the first tick) and
    // read the memory totals in the same shot.
    Process {
        id: statProc
        command: ["sh", "-c",
            "a=$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8+$9, $5+$6}' /proc/stat); " +
            "sleep 0.3; " +
            "b=$(awk '/^cpu / {print $2+$3+$4+$5+$6+$7+$8+$9, $5+$6}' /proc/stat); " +
            "echo \"$a $b\"; grep -E '^MemTotal|^MemAvailable' /proc/meminfo"]
        stdout: StdioCollector { onStreamFinished: root.parseStats(text) }
    }

    function parseStats(text: string) {
        const lines = text.trim().split("\n");
        const p = lines[0].trim().split(/\s+/).map(Number);
        const totalD = p[2] - p[0], idleD = p[3] - p[1];
        if (totalD > 0)
            cpuPct = Math.max(0, Math.min(100, (1 - idleD / totalD) * 100));
        let total = 0, avail = 0;
        for (let i = 1; i < lines.length; i++) {
            const m = /^(\w+):\s+(\d+)/.exec(lines[i]);
            if (!m) continue;
            if (m[1] === "MemTotal") total = Number(m[2]);
            else if (m[1] === "MemAvailable") avail = Number(m[2]);
        }
        if (total > 0) {
            memTotalGiB = total / 1048576;
            memUsedGiB = (total - avail) / 1048576;
        }
    }

    Timer {
        interval: 3000
        repeat: true
        triggeredOnStart: true
        running: root.active
        onTriggered: if (!statProc.running) statProc.running = true
    }

    component StatMeter: Column {
        property string glyph: ""
        property string name: ""
        property color tint: root.accent
        property real pct: 0
        property string value: ""
        property bool ready: true

        width: parent.width
        spacing: 6

        Item {
            width: parent.width
            height: 16

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.mdiFontFamily
                    font.pixelSize: 14
                    color: tint
                    text: glyph
                    textFormat: Text.PlainText
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: Theme.subtext1
                    text: name
                }
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontFamily
                font.pixelSize: Theme.popupBodySize
                font.weight: Font.DemiBold
                color: ready ? Theme.text : Theme.overlay0
                text: ready ? value : "…"
            }
        }

        Rectangle {
            width: parent.width
            height: 6
            radius: 3
            color: Theme.alpha(Theme.surface2, 0.45)

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, pct / 100))
                height: parent.height
                radius: parent.radius
                color: tint

                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            }
        }
    }

    Column {
        width: root.menuWidth
        spacing: 8

        SectionLabel { text: "System" }

        Card {
            Column {
                width: parent.width
                spacing: 12

                StatMeter {
                    glyph: "\u{F09B9}"      // mdi cpu-64-bit
                    name: "CPU"
                    tint: Theme.sapphire
                    ready: root.cpuPct >= 0
                    pct: Math.max(0, root.cpuPct)
                    value: Math.round(root.cpuPct) + "%"
                }
                StatMeter {
                    glyph: "\u{F035B}"      // mdi memory
                    name: "RAM"
                    tint: Theme.mauve
                    ready: root.memTotalGiB > 0
                    pct: root.memPct
                    value: root.memUsedGiB.toFixed(1) + " / " + root.memTotalGiB.toFixed(1) + " GiB"
                }
            }
        }
    }

    // Recent notifications — page through the history ring with ‹ ›
    property int notifIndex: 0
    readonly property int notifCount: Notifs.historyModel.count
    readonly property var current: {
        Notifs.received;   // re-evaluate when a new notification arrives
        if (notifIndex < 0 || notifIndex >= Notifs.historyModel.count)
            return null;
        return Notifs.historyModel.get(notifIndex);
    }

    function fmtAgo(epochSec: double): string {
        const s = Math.floor(Time.now.getTime() / 1000) - epochSec;
        if (s < 60) return "just now";
        const m = Math.floor(s / 60);
        if (m < 60) return m + "m ago";
        const h = Math.floor(m / 60);
        if (h < 24) return h + "h ago";
        return Math.floor(h / 24) + "d ago";
    }

    // Clicking a history card opens the app that sent it (the object's live
    // actions are gone once it stops being tracked, so we relaunch instead).
    function openCurrentNotif() {
        const n = root.current;
        if (n) {
            const key = n.desktopEntry || n.appName || "";
            const entry = key ? DesktopEntries.heuristicLookup(key) : null;
            if (entry)
                entry.execute();
        }
        root.closeRequested();
    }

    component PagerArrow: Rectangle {
        property string glyph: ""
        property bool enabled: true
        signal activated()

        width: 24
        height: 24
        radius: 12
        opacity: enabled ? 1 : 0.3
        color: arrowMouse.containsMouse && enabled ? Theme.cardHoverBg : "transparent"

        Behavior on color { ColorAnimation { duration: 120; easing.type: Easing.InOutQuad } }

        Text {
            anchors.centerIn: parent
            font.family: Theme.mdiFontFamily
            font.pixelSize: 18
            color: Theme.subtext1
            text: glyph
            textFormat: Text.PlainText
        }

        MouseArea {
            id: arrowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (parent.enabled) parent.activated()
        }
    }

    Column {
        width: root.menuWidth
        spacing: 8

        Item {
            width: parent.width
            height: 14

            SectionLabel {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Recent"
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.notifCount > 0
                font.family: Theme.fontFamily
                font.pixelSize: Theme.popupMicroSize
                color: Theme.overlay1
                text: (root.notifIndex + 1) + " / " + root.notifCount
            }
        }

        Card {
            id: notifCard
            readonly property var notif: root.current
            // Lift on hover so it reads as clickable (opens the sending app).
            color: notif && notifClick.containsMouse ? Theme.cardHoverBg : Theme.cardBg

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

            Item {
                width: parent.width
                // Fixed body height so paging doesn't resize the drawer per card.
                height: 66

                // Click anywhere but the pager arrows to open the app.
                MouseArea {
                    id: notifClick
                    anchors.fill: parent
                    enabled: notifCard.notif !== null
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openCurrentNotif()
                }

                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: notifCard.notif === null
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: Theme.overlay1
                    text: "No recent notifications"
                }

                Row {
                    id: notifRow
                    anchors.fill: parent
                    visible: notifCard.notif !== null
                    spacing: 11

                    readonly property var n: notifCard.notif
                    readonly property color urgencyAccent:
                        n ? Theme.notifAccent(n.urgency) : Theme.mauve

                    PagerArrow {
                        anchors.verticalCenter: parent.verticalCenter
                        glyph: "\u{F0141}"   // chevron-left → older
                        enabled: root.notifIndex < root.notifCount - 1
                        onActivated: root.notifIndex++
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 34
                        height: 34

                        Image {
                            id: notifIcon
                            anchors.fill: parent
                            source: notifRow.n ? notifRow.n.iconSource : ""
                            sourceSize.width: 68
                            sourceSize.height: 68
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            asynchronous: true
                            visible: status === Image.Ready
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: notifIcon.status !== Image.Ready
                            font.family: Theme.mdiFontFamily
                            font.pixelSize: 26
                            color: notifRow.urgencyAccent
                            text: "\u{F009A}"    // bell
                            textFormat: Text.PlainText
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        width: notifRow.width - 2 * 24 - 34 - 3 * notifRow.spacing
                        spacing: 2

                        Row {
                            width: parent.width
                            spacing: 6

                            Text {
                                width: Math.min(implicitWidth, parent.width - agoLabel.width - parent.spacing)
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.popupCaptionSize
                                font.weight: Font.Medium
                                color: notifRow.urgencyAccent
                                text: notifRow.n ? notifRow.n.appName : ""
                                textFormat: Text.PlainText
                            }
                            Text {
                                id: agoLabel
                                anchors.verticalCenter: parent.verticalCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.popupMicroSize
                                color: Theme.overlay1
                                text: notifRow.n ? "· " + root.fmtAgo(notifRow.n.time) : ""
                            }
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.popupBodySize
                            font.weight: Font.DemiBold
                            color: Theme.text
                            text: notifRow.n ? notifRow.n.summary : ""
                            textFormat: Text.PlainText
                        }
                        Text {
                            width: parent.width
                            visible: text !== ""
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.popupCaptionSize
                            color: Theme.subtext0
                            text: notifRow.n ? notifRow.n.body : ""
                            textFormat: Text.PlainText
                        }
                    }

                    PagerArrow {
                        anchors.verticalCenter: parent.verticalCenter
                        glyph: "\u{F0142}"   // chevron-right → newer
                        enabled: root.notifIndex > 0
                        onActivated: root.notifIndex--
                    }
                }
            }
        }
    }

    // Weather (wttr.in, IP-located)
    property bool wxLoading: false
    property bool wxError: false
    property string wxLocation: ""
    property string wxTemp: ""
    property string wxDesc: ""
    property string wxFeels: ""
    property string wxHumidity: ""
    property string wxWind: ""
    property int wxCode: 113
    // Upcoming 3-hourly slots: [{ label, temp, code, rain }] (wttr's resolution).
    property var wxHourly: []
    property double wxFetched: 0
    readonly property int wxTtlMs: 15 * 60 * 1000

    Process {
        id: wxProc
        command: ["curl", "-s", "--max-time", "12", "https://wttr.in/?format=j1"]
        stdout: StdioCollector { onStreamFinished: root.parseWeather(text) }
        onRunningChanged: root.wxLoading = running
    }

    function refreshWeather() {
        if (wxProc.running)
            return;
        if (wxFetched > 0 && Date.now() - wxFetched < wxTtlMs)
            return;
        wxError = false;
        wxProc.running = true;
    }

    function parseWeather(text: string) {
        wxFetched = Date.now();
        try {
            const j = JSON.parse(text);
            const c = j.current_condition[0];
            wxTemp = c.temp_C + "°";
            wxFeels = c.FeelsLikeC + "°";
            wxHumidity = c.humidity + "%";
            wxWind = c.windspeedKmph + " km/h";
            wxDesc = (c.weatherDesc && c.weatherDesc[0]) ? c.weatherDesc[0].value : "";
            wxCode = parseInt(c.weatherCode);
            const area = j.nearest_area && j.nearest_area[0];
            wxLocation = (area && area.areaName && area.areaName[0]) ? area.areaName[0].value : "";

            // Upcoming 3-hourly slots, starting from the current hour. wttr gives
            // 8 slots/day (times "0".."2100"); walk days until we have six.
            const nowH = Time.now.getHours();
            const days = j.weather || [];
            const slots = [];
            for (let di = 0; di < days.length && slots.length < 6; di++) {
                const hrs = days[di].hourly || [];
                for (let hi = 0; hi < hrs.length && slots.length < 6; hi++) {
                    const h = hrs[hi];
                    const hour = Math.floor(parseInt(h.time) / 100);
                    if (di === 0 && hour < nowH)
                        continue;   // already past today
                    slots.push({
                        label: (hour < 10 ? "0" : "") + hour + ":00",
                        hour: hour,
                        temp: h.tempC + "°",
                        code: parseInt(h.weatherCode),
                        rain: parseInt(h.chanceofrain)
                    });
                }
            }
            wxHourly = slots;
            wxError = false;
        } catch (e) {
            wxError = true;
        }
    }

    // WWO weather code → MDI weather glyph, grouped into a handful of families.
    // `hour` (optional 0–23) swaps a clear sky for a moon overnight.
    function weatherGlyph(code, hour) {
        const night = hour !== undefined && hour >= 0 && (hour < 6 || hour >= 20);
        if (code === 113) return night ? "\u{F0594}" : "\u{F0599}";   // moon / sunny
        if (code === 116) return "\u{F0595}";                         // partly cloudy
        if (code === 119 || code === 122) return "\u{F0590}";         // cloudy / overcast
        if ([143, 248, 260].indexOf(code) >= 0) return "\u{F0591}";   // mist / fog
        if ([200, 386, 389, 392, 395].indexOf(code) >= 0) return "\u{F0593}"; // thunder
        const snow = [179, 182, 227, 230, 317, 320, 323, 326, 329, 332, 335, 338,
                      350, 362, 365, 368, 371, 374, 377];
        if (snow.indexOf(code) >= 0) return "\u{F0598}";              // snow
        return "\u{F0597}";                                           // rain (default wet)
    }

    Column {
        width: root.menuWidth
        spacing: 8

        SectionLabel { text: "Weather" }

        Card {
            Column {
                width: parent.width
                spacing: 12

                // Current conditions
                Item {
                    id: wxCurrent
                    width: parent.width
                    height: 62

                    // Loading (before the first result) / error placeholders.
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: (root.wxLoading && root.wxTemp === "") || root.wxError

                        Spinner {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.wxLoading && !root.wxError
                            color: Theme.sky
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.popupBodySize
                            color: Theme.overlay1
                            text: root.wxError ? "Weather unavailable" : "Loading weather…"
                        }
                    }

                    Row {
                        anchors.fill: parent
                        visible: root.wxTemp !== "" && !root.wxError
                        spacing: 14

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.mdiFontFamily
                            font.pixelSize: 46
                            color: Theme.sky
                            text: root.weatherGlyph(root.wxCode, Time.now.getHours())
                            textFormat: Text.PlainText
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 46 - parent.spacing
                            spacing: 2

                            Item {
                                width: parent.width
                                height: tempText.height

                                Text {
                                    id: tempText
                                    anchors.left: parent.left
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 26
                                    font.weight: Font.DemiBold
                                    color: Theme.text
                                    text: root.wxTemp
                                }
                                Text {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: tempText.verticalCenter
                                    width: parent.width - tempText.width - 8
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupCaptionSize
                                    color: Theme.subtext0
                                    text: root.wxLocation
                                }
                            }

                            Text {
                                width: parent.width
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.popupCaptionSize
                                color: Theme.subtext1
                                text: root.wxDesc
                            }

                            Row {
                                width: parent.width
                                spacing: 12

                                Repeater {
                                    model: [
                                        { g: "\u{F050F}", v: root.wxFeels },     // thermometer
                                        { g: "\u{F058E}", v: root.wxHumidity },  // water-percent
                                        { g: "\u{F059D}", v: root.wxWind }       // windy
                                    ]

                                    Row {
                                        required property var modelData
                                        spacing: 4

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            font.family: Theme.mdiFontFamily
                                            font.pixelSize: 12
                                            color: Theme.overlay2
                                            text: modelData.g
                                            textFormat: Text.PlainText
                                        }
                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.popupMicroSize
                                            color: Theme.subtext0
                                            text: modelData.v
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.alpha(Theme.overlay0, 0.25)
                    visible: root.wxHourly.length > 0 && !root.wxError
                }

                // Upcoming 3-hourly strip: time · icon · temp · rain chance
                Item {
                    width: parent.width
                    height: hourRow.implicitHeight
                    visible: root.wxHourly.length > 0 && !root.wxError

                    Row {
                        id: hourRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8

                        Repeater {
                            model: root.wxHourly

                            Column {
                                id: cell
                                required property var modelData
                                readonly property color rainColor: modelData.rain >= 50 ? Theme.sapphire
                                    : modelData.rain >= 20 ? Theme.blue : Theme.overlay0

                                width: 46
                                spacing: 3

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupMicroSize
                                    color: Theme.subtext0
                                    text: cell.modelData.label
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.family: Theme.mdiFontFamily
                                    font.pixelSize: 20
                                    color: Theme.sky
                                    text: root.weatherGlyph(cell.modelData.code, cell.modelData.hour)
                                    textFormat: Text.PlainText
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupCaptionSize
                                    font.weight: Font.DemiBold
                                    color: Theme.text
                                    text: cell.modelData.temp
                                }
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 2

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.family: Theme.mdiFontFamily
                                        font.pixelSize: 10
                                        color: cell.rainColor
                                        text: "\u{F058C}"   // water (drop)
                                        textFormat: Text.PlainText
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.popupMicroSize
                                        color: cell.rainColor
                                        text: cell.modelData.rain + "%"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
