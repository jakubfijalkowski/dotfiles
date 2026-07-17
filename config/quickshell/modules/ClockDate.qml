import Quickshell
import Quickshell.Io
import QtQuick
import qs
import qs.components

// clock#date: "{:L%d %B %y}" with a calendar tooltip.
// Actions: left-click opens the calendar drawer (also: qs ipc call calendar
// toggle), scroll shifts the calendar, right-click toggles month/year mode,
// middle-click resets (mode-mon-col: 3).
BarPill {
    id: root

    readonly property var barWindow: QsWindow.window

    accent: Theme.teal
    text: clock.date.toLocaleDateString(Theme.dateLocale, "dd MMMM yy")
    highlighted: calendarDrawer.open

    tooltipRich: true
    // <tt><small>{calendar}</small></tt> — hidden while the drawer is open.
    tooltipTextPixelSize: Theme.calendarFontSize
    tooltipText: calendarDrawer.open ? "" : calendarMarkup()

    property string mode: "month"  // "month" | "year"
    property int shift: 0          // months in month mode, years in year mode

    onWheelUp: shift += 1
    onWheelDown: shift -= 1
    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) calendarDrawer.toggle();
        else if (mouse.button === Qt.RightButton) mode = (mode === "month" ? "year" : "month");
        else if (mouse.button === Qt.MiddleButton) { shift = 0; mode = "month"; }
    }

    IpcHandler {
        target: "calendar"
        function toggle(): void { calendarDrawer.toggle(); }
    }

    // Drops down from the top-right corner (flush with the bar + right edge),
    // like BarDrawer, holding the full calendar view.
    EdgeDrawer {
        id: calendarDrawer
        screen: root.barWindow ? root.barWindow.screen : null
        accent: root.accent

        // Reset to the current month each time the drawer opens.
        onOpenChanged: if (open) calendarView.reset()

        CalendarView {
            id: calendarView
            accent: root.accent
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    function pad(s: string, w: int): string {
        s = String(s);
        while (s.length < w) s = " " + s;
        return s;
    }

    // One month as an array of equal-width plain-text lines plus a
    // parallel array of marked-up lines (bold per calendar.format).
    function monthBlock(year: int, month: int): var {
        const loc = Theme.dateLocale;
        const today = clock.date;
        const firstDow = loc.firstDayOfWeek === 0 ? 7 : loc.firstDayOfWeek;

        let names = [];
        for (let i = 0; i < 7; i++) {
            const dow = (firstDow - 1 + i) % 7 + 1;
            names.push(loc.dayName(dow, Locale.ShortFormat).replace(/\./g, "").substring(0, 3));
        }
        const colw = Math.max(2, ...names.map(n => n.length));
        const width = 7 * (colw + 1) - 1;

        const lines = [];
        const header = loc.standaloneMonthName(month, Locale.LongFormat) + " " + year;
        const lpad = Math.max(0, Math.floor((width - header.length) / 2));
        lines.push({ text: pad("", lpad) + header + pad("", width - lpad - header.length), markup: "months" });
        lines.push({ text: names.map(n => pad(n, colw)).join(" "), markup: "weekdays" });

        const first = new Date(year, month, 1);
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        let offset = (first.getDay() === 0 ? 7 : first.getDay()) - firstDow;
        if (offset < 0) offset += 7;

        let day = 1;
        while (day <= daysInMonth) {
            const cells = [];
            for (let i = 0; i < 7; i++) {
                if ((lines.length === 2 && i < offset) || day > daysInMonth) {
                    cells.push({ text: pad("", colw) });
                } else {
                    const isToday = day === today.getDate()
                        && month === today.getMonth() && year === today.getFullYear();
                    cells.push({ text: pad(day, colw), today: isToday });
                    day++;
                }
            }
            lines.push({ cells: cells });
        }
        return { width: width, lines: lines };
    }

    function esc(s: string): string {
        return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
                .replace(/ /g, "&nbsp;");
    }

    // calendar.format: months/days/weekdays "<b>{}</b>", today "<b><u>{}</u></b>"
    function renderLine(line: var, width: int): string {
        if (line.cells !== undefined) {
            return line.cells.map(c => {
                if (c.today) return "<b><u>" + esc(c.text) + "</u></b>";
                if (c.text.trim() !== "") return "<b>" + esc(c.text) + "</b>";
                return esc(c.text);
            }).join("&nbsp;");
        }
        const padded = line.text + " ".repeat(Math.max(0, width - line.text.length));
        return "<b>" + esc(padded) + "</b>";
    }

    function calendarMarkup(): string {
        const now = clock.date;
        const out = [];

        if (mode === "month") {
            const shown = new Date(now.getFullYear(), now.getMonth() + shift, 1);
            const block = monthBlock(shown.getFullYear(), shown.getMonth());
            for (const line of block.lines)
                out.push(renderLine(line, block.width));
        } else {
            // year mode, mode-mon-col: 3
            const year = now.getFullYear() + shift;
            for (let rowStart = 0; rowStart < 12; rowStart += 3) {
                const blocks = [0, 1, 2].map(i => monthBlock(year, rowStart + i));
                const rows = Math.max(...blocks.map(b => b.lines.length));
                for (let r = 0; r < rows; r++) {
                    out.push(blocks.map(b => {
                        if (r < b.lines.length) return renderLine(b.lines[r], b.width);
                        return esc(" ".repeat(b.width));
                    }).join("&nbsp;&nbsp;"));
                }
                if (rowStart < 9) out.push("");
            }
        }
        return out.join("<br/>");
    }
}
