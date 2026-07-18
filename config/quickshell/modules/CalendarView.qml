import QtQuick
import qs

// The calendar shown inside the clock's EdgeDrawer. A continuous, Monday-first
// vertical strip of weeks: the last ~2 weeks of the previous month, all of the
// focused month, and the first ~2 weeks of the next month. The focused month's
// days are drawn in full colour and adjacent months dimmed; today (the real
// current day) is highlighted in the accent colour, weekends carry a faint
// tint, and each row shows its ISO-8601 week number on the left. Month blocks
// are separated by a small gap (a week belongs to the month of its Thursday,
// per ISO) so the three months read as distinct groups.
//
// Navigate months by scrolling anywhere over it or with the arrows beside the
// month name; middle-click resets to the current month.
Item {
    id: root

    // Accent for the "today" highlight — the clock pill's colour.
    property color accent: Theme.teal
    // Months away from the real current month (0 = current).
    property int monthOffset: 0

    readonly property date today: Time.now
    // First day of the focused month (current month + offset).
    readonly property date focusDate: new Date(today.getFullYear(), today.getMonth() + monthOffset, 1)
    // Day-granular stamp so the grid only rebuilds at midnight, not every tick.
    readonly property int dayStamp: today.getFullYear() * 10000 + today.getMonth() * 100 + today.getDate()
    readonly property string rebuildKey: dayStamp + ":" + monthOffset
    property var weeks: []

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    onRebuildKeyChanged: weeks = buildWeeks(focusDate, today)
    Component.onCompleted: weeks = buildWeeks(focusDate, today)

    function shiftMonth(delta: int) { monthOffset += delta; }
    function reset() { monthOffset = 0; }

    // --- date helpers ---
    function addDays(d: var, n: int): var {
        return new Date(d.getFullYear(), d.getMonth(), d.getDate() + n);
    }
    function mondayOf(d: var): var {
        const dow = (d.getDay() + 6) % 7; // Mon=0 .. Sun=6
        return addDays(d, -dow);
    }
    function sameDay(a: var, b: var): bool {
        return a.getFullYear() === b.getFullYear()
            && a.getMonth() === b.getMonth()
            && a.getDate() === b.getDate();
    }
    // ISO-8601 week number (weeks start Monday; week 1 holds the first Thursday).
    function isoWeek(d: var): int {
        const t = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        const dow = (t.getDay() + 6) % 7;
        t.setDate(t.getDate() - dow + 3);            // Thursday of this week
        const firstThu = new Date(t.getFullYear(), 0, 4);
        const fdow = (firstThu.getDay() + 6) % 7;
        firstThu.setDate(firstThu.getDate() - fdow + 3);
        return 1 + Math.round((t.getTime() - firstThu.getTime()) / 604800000);
    }

    function buildWeeks(ref: var, now: var): var {
        const curMonth = ref.getMonth();
        const curYear = ref.getFullYear();
        const firstOfMonth = new Date(curYear, curMonth, 1);
        const lastOfMonth = new Date(curYear, curMonth + 1, 0);
        // Two full weeks before the focused month's first (Monday-aligned) week,
        // through two full weeks past the Monday of its last week.
        const start = addDays(mondayOf(firstOfMonth), -14);
        const end = addDays(mondayOf(lastOfMonth), 14 + 6);
        const out = [];
        let prevGroup = -2;
        for (let cur = start; cur.getTime() <= end.getTime(); cur = addDays(cur, 7)) {
            const days = [];
            for (let i = 0; i < 7; i++) {
                const d = addDays(cur, i);
                days.push({
                    day: d.getDate(),
                    inMonth: d.getMonth() === curMonth && d.getFullYear() === curYear,
                    isToday: sameDay(d, now),
                    isWeekend: i >= 5   // Mon-first: 5 = Sat, 6 = Sun
                });
            }
            // Group weeks around the focused month so its own first/last week —
            // which may carry a few dimmed neighbour-month days — stays in its
            // block: -1 before the month, 0 within it, +1 after. A change of group
            // opens a gap. (Grouping by the ISO Thursday would misfile a boundary
            // week whose Thursday lands in a neighbour month.)
            const group = days.some(x => x.inMonth) ? 0
                        : (cur.getTime() < firstOfMonth.getTime() ? -1 : 1);
            out.push({ week: isoWeek(cur), days: days, groupStart: out.length > 0 && group !== prevGroup });
            prevGroup = group;
        }
        return out;
    }

    // Monday-first weekday label; Qt Locale.dayName uses 1=Mon .. 7=Sun.
    function headerName(i: int): string {
        return Theme.dateLocale.dayName(i + 1, Locale.ShortFormat).replace(/\.$/, "");
    }

    // Scroll anywhere / middle-click to reset. Sits under the content, which is
    // transparent to the mouse except for the arrow buttons (which forward
    // wheel events too).
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton
        onWheel: wheel => root.shiftMonth(wheel.angleDelta.y > 0 ? -1 : 1)
        onClicked: root.reset()
    }

    Column {
        id: layout
        spacing: 12

        // Title: arrows flanking the focused month + year.
        Row {
            spacing: 4

            Text {
                id: prevArrow
                text: "\u{F0141}"   // mdi-chevron-left
                font.family: Theme.mdiFontFamily
                font.pixelSize: Theme.iconFontSize + 5
                height: 26
                verticalAlignment: Text.AlignVCenter
                color: prevMa.containsMouse ? root.accent : Theme.subtext0
                Behavior on color { ColorAnimation { duration: 120 } }
                MouseArea {
                    id: prevMa
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    onClicked: root.shiftMonth(-1)
                    onWheel: wheel => root.shiftMonth(wheel.angleDelta.y > 0 ? -1 : 1)
                }
            }

            Text {
                text: Theme.dateLocale.standaloneMonthName(root.focusDate.getMonth(), Locale.LongFormat)
                      + " " + root.focusDate.getFullYear()
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 3
                font.capitalization: Font.Capitalize
                height: 26
                verticalAlignment: Text.AlignVCenter
                color: root.accent
            }

            Text {
                id: nextArrow
                text: "\u{F0142}"   // mdi-chevron-right
                font.family: Theme.mdiFontFamily
                font.pixelSize: Theme.iconFontSize + 5
                height: 26
                verticalAlignment: Text.AlignVCenter
                color: nextMa.containsMouse ? root.accent : Theme.subtext0
                Behavior on color { ColorAnimation { duration: 120 } }
                MouseArea {
                    id: nextMa
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    onClicked: root.shiftMonth(1)
                    onWheel: wheel => root.shiftMonth(wheel.angleDelta.y > 0 ? -1 : 1)
                }
            }
        }

        Column {
            spacing: Theme.calCellSpacing

            // Weekday header row
            Row {
                spacing: Theme.calCellSpacing

                Item {
                    width: Theme.calWeekColWidth
                    height: Theme.calCellHeight
                }
                Repeater {
                    model: 7
                    delegate: Item {
                        id: hcell
                        required property int index
                        width: Theme.calDayCellWidth
                        height: Theme.calCellHeight
                        Text {
                            anchors.centerIn: parent
                            text: root.headerName(hcell.index)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.bold: true
                            color: Theme.calHeaderFg
                        }
                    }
                }
            }

            // One row per week; a month's first week carries a top gap so the
            // three months separate into blocks.
            Repeater {
                model: root.weeks
                delegate: Item {
                    id: weekWrap
                    required property var modelData
                    readonly property int topGap: weekWrap.modelData.groupStart ? Theme.calMonthGap : 0
                    implicitWidth: weekRow.implicitWidth
                    implicitHeight: Theme.calCellHeight + topGap

                    Row {
                        id: weekRow
                        y: weekWrap.topGap
                        spacing: Theme.calCellSpacing

                        // ISO week number
                        Item {
                            width: Theme.calWeekColWidth
                            height: Theme.calCellHeight
                            Text {
                                anchors.centerIn: parent
                                text: weekWrap.modelData.week
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                color: Theme.calWeekNumFg
                            }
                        }

                        Repeater {
                            model: weekWrap.modelData.days
                            delegate: Rectangle {
                                id: dayCell
                                required property var modelData
                                width: Theme.calDayCellWidth
                                height: Theme.calCellHeight
                                radius: Theme.calCellRadius
                                color: dayCell.modelData.isToday ? Theme.calTodayBg(root.accent)
                                     : dayCell.modelData.isWeekend ? Theme.calWeekendBg
                                     : "transparent"
                                border.width: dayCell.modelData.isToday ? 1 : 0
                                border.color: dayCell.modelData.isToday ? Theme.calTodayBorder(root.accent)
                                                                        : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: dayCell.modelData.day
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    font.bold: dayCell.modelData.isToday
                                    color: dayCell.modelData.isToday ? root.accent
                                         : dayCell.modelData.inMonth ? Theme.calDayFg
                                         : Theme.calAdjacentFg
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
