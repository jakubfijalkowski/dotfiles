import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import qs
import qs.components

// Content of the updates drawer: a header with the count, a scrollable list
// of pending updates (name + old -> new version, AUR entries tagged), and
// footer buttons to upgrade everything or just the official repos. The list
// is fetched lazily when the drawer opens.
Column {
    id: root

    // Emitted by the parent drawer when it opens.
    signal opened()
    // Asks the parent drawer to close.
    signal closeRequested()

    readonly property int listWidth: 420
    readonly property int rowHeight: 32
    readonly property int rowSpacing: 4
    // The drawer never grows past this many rows — the rest scrolls.
    readonly property int maxRows: 10

    property bool loading: false
    property int aurCount: 0

    // Fetching hits the network (checkupdates syncs a private pacman DB copy,
    // `yay -Qua` queries the AUR), so a fresh-enough result is reused instead
    // of refetching on every drawer open.
    readonly property int refreshTtlMs: 5 * 60 * 1000
    property double lastFetched: 0

    ListModel { id: updatesModel }

    // checkupdates = repo diffs, `yay -Qua` = AUR diffs; both print
    // "name oldver -> newver" (AUR adds a trailing "[age]" we ignore). A
    // sentinel line separates the two so we can tag AUR packages.
    Process {
        id: listProc
        command: ["sh", "-c", "checkupdates 2>/dev/null; echo '@@AUR@@'; yay -Qua 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.populate(text)
        }
        onRunningChanged: root.loading = running
    }

    function refresh() {
        if (listProc.running)
            return;
        if (lastFetched > 0 && Date.now() - lastFetched < refreshTtlMs)
            return;
        listProc.running = true;
    }

    function populate(text: string) {
        lastFetched = Date.now();
        const re = /^(\S+)\s+(\S+)\s*->\s*(\S+)/;
        const rows = [];
        let aur = false;
        for (const line of text.split("\n")) {
            const t = line.trim();
            if (t === "@@AUR@@") { aur = true; continue; }
            const m = re.exec(t);
            if (m)
                rows.push({ name: m[1], oldVer: m[2], newVer: m[3], aur: aur });
        }
        // AUR first (they warrant a look before upgrading), then alphabetical.
        rows.sort((a, b) => (b.aur - a.aur) || a.name.localeCompare(b.name));
        updatesModel.clear();
        for (const r of rows)
            updatesModel.append(r);
        root.aurCount = rows.filter(r => r.aur).length;
    }

    onOpened: refresh()

    spacing: 6

    // Header: Arch badge, title + count, refresh spinner
    Item {
        width: root.listWidth
        height: 34

        Rectangle {
            id: headerBadge
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 30
            height: 30
            radius: 9
            color: Theme.chipBg(Theme.yellow, true)
            border.width: 1
            border.color: Theme.chipBorder(Theme.yellow, true)

            Text {
                anchors.centerIn: parent
                font.family: Theme.iconFontFamily
                font.pixelSize: 15
                color: Theme.yellow
                // nf-linux-archlinux (matches the bar pill glyph)
                text: "\u{F303}"
            }
        }

        Column {
            anchors.left: headerBadge.right
            anchors.leftMargin: 10
            anchors.right: headerSpinner.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
                color: Theme.text
                text: "Updates"
            }
            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.popupCaptionSize
                color: Theme.subtext0
                text: {
                    if (updatesModel.count === 0)
                        return root.loading ? "Checking…" : "Up to date";
                    let s = updatesModel.count + " available";
                    if (root.aurCount > 0)
                        s += " · " + root.aurCount + " from AUR";
                    return s;
                }
            }
        }

        Spinner {
            id: headerSpinner
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            visible: root.loading && updatesModel.count > 0
            color: Theme.yellow
        }
    }

    // Loading placeholder (only before the first result arrives)
    Item {
        visible: root.loading && updatesModel.count === 0
        width: root.listWidth
        height: 2 * root.rowHeight

        Spinner {
            anchors.centerIn: parent
            color: Theme.yellow
        }
    }

    // Scrollable list — capped at maxRows, the rest scrolls.
    ListView {
        id: list
        // Whether the content overflows and needs the scrollbar.
        readonly property bool scrollActive: contentHeight > height + 0.5
        // Gutter reserved on the right so the scrollbar sits beside the rows.
        readonly property int gutter: 14

        visible: updatesModel.count > 0
        width: root.listWidth
        height: {
            const n = Math.min(updatesModel.count, root.maxRows);
            return n * root.rowHeight + Math.max(0, n - 1) * root.rowSpacing;
        }
        clip: true
        spacing: root.rowSpacing
        model: updatesModel
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            id: vbar
            policy: list.scrollActive ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            width: 6
            contentItem: Rectangle {
                radius: width / 2
                color: Theme.alpha(Theme.overlay0, vbar.pressed ? 0.9 : 0.55)
            }
        }

        delegate: Rectangle {
            id: row
            required property string name
            required property string oldVer
            required property string newVer
            required property bool aur

            // Leave the gutter free for the scrollbar when it's showing.
            width: list.width - (list.scrollActive ? list.gutter : 0)
            height: root.rowHeight
            radius: Theme.cardRadius
            color: rowMouse.containsMouse ? Theme.cardHoverBg : Theme.cardBg
            border.width: 1
            border.color: Theme.cardBorder

            Behavior on color { ColorAnimation { duration: 150; easing.type: Easing.InOutQuad } }

            // Name + optional AUR tag; the name elides so the tag stays visible.
            Row {
                id: nameGroup
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: versions.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    id: pkgName
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.min(implicitWidth,
                        nameGroup.width - (aurChip.visible ? aurChip.width + nameGroup.spacing : 0))
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupBodySize
                    color: Theme.text
                    elide: Text.ElideRight
                    text: row.name
                }

                Rectangle {
                    id: aurChip
                    anchors.verticalCenter: parent.verticalCenter
                    visible: row.aur
                    width: aurText.implicitWidth + 10
                    height: 16
                    radius: 4
                    color: Theme.chipBg(Theme.mauve, true)
                    border.width: 1
                    border.color: Theme.chipBorder(Theme.mauve, true)

                    Text {
                        id: aurText
                        anchors.centerIn: parent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.popupMicroSize
                        font.weight: Font.DemiBold
                        color: Theme.mauve
                        text: "AUR"
                    }
                }
            }

            Row {
                id: versions
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.subtext0
                    text: row.oldVer
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    color: Theme.overlay1
                    text: "→"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.popupCaptionSize
                    font.weight: Font.DemiBold
                    color: Theme.yellow
                    text: row.newVer
                }
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    // Footer: upgrade everything, or only the official repositories.
    Row {
        width: root.listWidth
        spacing: 6

        ActionButton {
            width: (root.listWidth - parent.spacing) / 2
            label: "Update all"
            tint: Theme.yellow
            // nf-md-download
            glyph: "\u{F0552}"
            onActivated: {
                Quickshell.execDetached(["xdg-terminal-exec", "--", "yay", "-Syu", "--devel"]);
                root.closeRequested();
            }
        }

        ActionButton {
            width: (root.listWidth - parent.spacing) / 2
            label: "Update official"
            tint: Theme.sapphire
            // nf-md-package_variant
            glyph: "\u{F03D9}"
            onActivated: {
                Quickshell.execDetached(["xdg-terminal-exec", "--", "sudo", "pacman", "-Syu"]);
                root.closeRequested();
            }
        }
    }
}
