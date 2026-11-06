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

    // Session actions
    component PowerTile: Rectangle {
        id: tile
        property string glyph: ""
        property string label: ""
        property color tint: root.accent
        required property var command
        // Destructive actions take a second click, so a stray one can't end the session.
        property bool confirm: false
        property bool armed: false

        width: (root.menuWidth - 3 * actionRow.spacing) / 4
        height: 62
        radius: Theme.cardRadius
        color: Theme.alpha(tint, armed ? 0.24 : tileMouse.containsMouse ? 0.16 : 0.06)
        border.width: 1
        border.color: Theme.alpha(tint, armed || tileMouse.containsMouse ? 0.75 : 0.45)

        Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }
        Behavior on border.color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }

        Timer {
            id: disarm
            interval: 3000
            onTriggered: tile.armed = false
        }
        Connections {
            target: root
            function onActiveChanged() { tile.armed = false; }
        }

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
                color: tile.armed ? tile.tint : Theme.text
                text: tile.armed ? "Confirm" : tile.label
                textFormat: Text.PlainText
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (tile.confirm && !tile.armed) {
                    tile.armed = true;
                    disarm.restart();
                    return;
                }
                Quickshell.execDetached(tile.command);
                root.closeRequested();
            }
        }
    }

    Row {
        id: actionRow
        width: root.menuWidth
        spacing: 8

        // Lock via logind, so hypridle's lock_cmd guards against a second hyprlock.
        PowerTile { glyph: "\u{F0341}"; label: "Lock";     tint: Theme.blue;  command: ["loginctl", "lock-session"] }
        // The session runs under uwsm, which tears down the compositor and the
        // graphical units in order.
        PowerTile { glyph: "\u{F0343}"; label: "Logout";   tint: Theme.mauve; confirm: true; command: ["uwsm", "stop"] }
        PowerTile { glyph: "\u{F0709}"; label: "Reboot";   tint: Theme.peach; confirm: true; command: ["systemctl", "reboot"] }
        PowerTile { glyph: "\u{F0425}"; label: "Shutdown"; tint: Theme.red;   confirm: true; command: ["systemctl", "poweroff"] }
    }

    // System usage — CPU (avg across cores) + RAM
    property real cpuPct: -1               // -1 until the first sample lands
    property real memUsedGiB: 0
    property real memTotalGiB: 0
    readonly property real memPct: memTotalGiB > 0 ? memUsedGiB / memTotalGiB * 100 : 0

    // CPU usage is the busy share of the jiffies elapsed between two reads of
    // /proc/stat.
    property var cpuPrev: null

    FileView {
        id: procStat
        path: "/proc/stat"
        onLoaded: root.parseCpu(text())
    }
    FileView {
        id: procMeminfo
        path: "/proc/meminfo"
        onLoaded: root.parseMem(text())
    }

    function parseCpu(text: string) {
        const f = text.slice(0, text.indexOf("\n")).trim().split(/\s+/).slice(1, 9).map(Number);
        const total = f.reduce((a, b) => a + b, 0);
        const idle = f[3] + f[4];   // idle + iowait
        const prev = cpuPrev;
        cpuPrev = { total: total, idle: idle };
        if (prev && total > prev.total)
            cpuPct = Math.max(0, Math.min(100, (1 - (idle - prev.idle) / (total - prev.total)) * 100));
    }

    function parseMem(text: string) {
        const kib = key => Number((new RegExp("^" + key + ":\\s+(\\d+)", "m").exec(text) || [0, 0])[1]);
        const total = kib("MemTotal");
        if (total > 0) {
            memTotalGiB = total / 1048576;
            memUsedGiB = (total - kib("MemAvailable")) / 1048576;
        }
    }

    onActiveChanged: if (!active) { cpuPrev = null; cpuPct = -1; }

    Timer {
        // Quick second sample on open, so CPU shows a figure right away.
        interval: root.cpuPct < 0 ? 300 : 3000
        repeat: true
        triggeredOnStart: true
        running: root.active
        onTriggered: {
            procStat.reload();
            procMeminfo.reload();
        }
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
            color: Theme.meterTrack

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
            width: root.menuWidth

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
    // A new arrival shifts every index; jump back to it rather than let the
    // card swap to a different notification under the cursor.
    Connections {
        target: Notifs
        function onReceivedChanged() { root.notifIndex = 0; }
    }
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

    // Clicking a history card brings up the app that sent it — its window if
    // one is open, else a fresh launch (the notification's own actions are
    // gone once it stops being tracked).
    function openCurrentNotif() {
        const n = root.current;
        if (n && !Apps.focus([n.desktopEntry, n.appName])) {
            const key = n.desktopEntry || n.appName || "";
            const entry = key ? DesktopEntries.heuristicLookup(key) : null;
            if (entry)
                Apps.launchEntry(entry);
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

        Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.InOutQuad } }

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
            width: root.menuWidth
            // Lift on hover so it reads as clickable (opens the sending app).
            color: notif && notifClick.containsMouse ? Theme.cardHoverBg : Theme.cardBg

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
    // Upcoming 3-hourly slots: [{ label, temp, code, rain, night }] (wttr's resolution).
    property var wxHourly: []
    // Sunrise/sunset per forecast day (today first), in minutes after midnight;
    // NaN on polar days, which wttr reports as "No sunrise"/"No sunset".
    property var wxSun: []
    // Time of the last good fetch. A failed one leaves it alone, so the next
    // open retries while the last good reading stays on screen.
    property double wxFetched: 0
    readonly property int wxTtlMs: 15 * 60 * 1000

    Process {
        id: wxProc
        command: ["curl", "-sf", "--max-time", "12", "https://wttr.in/?format=j1"]
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

    // "06:40 AM" → minutes after midnight.
    function parseClock(s: string): real {
        const m = /(\d+):(\d+)\s*(AM|PM)/i.exec(s || "");
        if (!m)
            return NaN;
        return (parseInt(m[1]) % 12 + (m[3].toUpperCase() === "PM" ? 12 : 0)) * 60 + parseInt(m[2]);
    }
    function fmtClock(minutes: real): string {
        const pad = n => (n < 10 ? "0" : "") + n;
        return pad(Math.floor(minutes / 60)) + ":" + pad(Math.round(minutes % 60));
    }
    // Dark outside? Falls back to 6–20 h without sun times for that day.
    function isNight(day: int, minutes: real): bool {
        const sun = wxSun[day];
        if (!sun || isNaN(sun.rise) || isNaN(sun.set))
            return minutes < 6 * 60 || minutes >= 20 * 60;
        return minutes < sun.rise || minutes >= sun.set;
    }

    function parseWeather(text: string) {
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

            const days = j.weather || [];
            wxSun = days.map(d => {
                const a = (d.astronomy && d.astronomy[0]) || {};
                return { rise: parseClock(a.sunrise), set: parseClock(a.sunset) };
            });

            // Upcoming 3-hourly slots, starting from the current hour. wttr gives
            // 8 slots/day (times "0".."2100"); walk days until we have six.
            const nowH = Time.now.getHours();
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
                        rain: parseInt(h.chanceofrain),
                        night: isNight(di, hour * 60)
                    });
                }
            }
            wxHourly = slots;
            wxError = false;
            wxFetched = Date.now();
        } catch (e) {
            wxError = true;
        }
    }

    // WWO weather code → MDI weather glyph, grouped into a handful of families.
    // A clear sky shows a moon at night.
    function weatherGlyph(code: int, night: bool): string {
        if (code === 113) return night ? "\u{F0594}" : "\u{F0599}";   // moon / sunny
        if (code === 116) return night ? "\u{F0F31}" : "\u{F0595}";  // partly cloudy
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

        Item {
            width: parent.width
            height: 14

            SectionLabel {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: "Weather"
            }
            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: root.wxError && root.wxTemp !== ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.popupMicroSize
                color: Theme.overlay1
                text: "Offline · as of " + Qt.formatDateTime(new Date(root.wxFetched), "HH:mm")
            }
        }

        Card {
            width: root.menuWidth

            Column {
                width: parent.width
                spacing: 12

                // Current conditions
                Item {
                    id: wxCurrent
                    width: parent.width
                    height: 62

                    // Loading / error placeholders, only until a first reading lands —
                    // after that a failed refresh keeps showing the last one.
                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: root.wxTemp === "" && (root.wxLoading || root.wxError)

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
                        visible: root.wxTemp !== ""
                        spacing: 14

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: Theme.mdiFontFamily
                            font.pixelSize: 46
                            color: Theme.sky
                            text: root.weatherGlyph(root.wxCode,
                                root.isNight(0, Time.now.getHours() * 60 + Time.now.getMinutes()))
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

                            Item {
                                width: parent.width
                                height: descText.height

                                Text {
                                    id: descText
                                    anchors.left: parent.left
                                    width: parent.width - (sunTimes.visible ? sunTimes.width + 8 : 0)
                                    elide: Text.ElideRight
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.popupCaptionSize
                                    color: Theme.subtext1
                                    text: root.wxDesc
                                }

                                Row {
                                    id: sunTimes
                                    readonly property var today: root.wxSun[0] ?? null
                                    anchors.right: parent.right
                                    anchors.verticalCenter: descText.verticalCenter
                                    visible: today !== null && !isNaN(today.rise) && !isNaN(today.set)
                                    spacing: 8

                                    Repeater {
                                        model: sunTimes.visible ? [
                                            { g: "\u{F059C}", v: root.fmtClock(sunTimes.today.rise) },  // weather-sunset-up
                                            { g: "\u{F059B}", v: root.fmtClock(sunTimes.today.set) }    // weather-sunset-down
                                        ] : []

                                        Row {
                                            required property var modelData
                                            spacing: 3

                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                font.family: Theme.mdiFontFamily
                                                font.pixelSize: 12
                                                color: Theme.yellow
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
                    color: Theme.divider
                    visible: root.wxHourly.length > 0
                }

                // Upcoming 3-hourly strip: time · icon · temp · rain chance
                Item {
                    width: parent.width
                    height: hourRow.implicitHeight
                    visible: root.wxHourly.length > 0

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
                                    text: root.weatherGlyph(cell.modelData.code, cell.modelData.night)
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
