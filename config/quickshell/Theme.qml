pragma Singleton
import Quickshell
import QtQuick

// Shared look & feel for the bar and its popups — "Neon" style:
// dark crust bar, outlined pills that carry each module's color in
// their border and text, matching outlined popup surfaces.
Singleton {
    id: root

    // Catppuccin Mocha
    readonly property color rosewater: "#f5e0dc"
    readonly property color flamingo: "#f2cdcd"
    readonly property color pink: "#f5c2e7"
    readonly property color mauve: "#cba6f7"
    readonly property color red: "#f38ba8"
    readonly property color reallyRed: "#d20f39"
    readonly property color maroon: "#eba0ac"
    readonly property color peach: "#fab387"
    readonly property color yellow: "#f9e2af"
    readonly property color green: "#a6e3a1"
    readonly property color teal: "#94e2d5"
    readonly property color sky: "#89dceb"
    readonly property color sapphire: "#74c7ec"
    readonly property color blue: "#89b4fa"
    readonly property color lavender: "#b4befe"
    readonly property color text: "#cdd6f4"
    readonly property color subtext1: "#bac2de"
    readonly property color subtext0: "#a6adc8"
    readonly property color overlay2: "#9399b2"
    readonly property color overlay1: "#7f849c"
    readonly property color overlay0: "#6c7086"
    readonly property color surface2: "#585b70"
    readonly property color surface1: "#45475a"
    readonly property color surface0: "#313244"
    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color crust: "#11111b"

    function alpha(c: color, a: real): color { return Qt.rgba(c.r, c.g, c.b, a) }

    // Fonts — the single source of truth. Text renders in Iosevka; icon
    // glyphs are pinned per module to the font waybar's fallback list
    // (Material Design Icons, Iosevka, Symbols Nerd Font) resolves to.
    readonly property string fontFamily: "Iosevka"
    readonly property string iconFontFamily: "Symbols Nerd Font"
    readonly property string mdiFontFamily: "Material Design Icons"
    readonly property int fontSize: 14        // px; matches waybar's 11pt metrics
    readonly property int iconFontSize: 15    // px; icons keep the full 11pt size
    readonly property int powerIconFontSize: 17  // px; #group-power label is 13pt
    readonly property int calendarFontSize: 12   // px; calendar tooltip <small>

    // Bar metrics (px)
    readonly property int barHeight: 30
    readonly property int pillHeight: 26
    readonly property int pillPaddingH: 13
    readonly property int moduleSpacing: 5

    // transition: all 0.3s ease-in-out
    readonly property int transitionDuration: 300

    // Bar surface — translucent so a Hyprland blur layer shows through
    readonly property color barBg: alpha(crust, 0.40)
    readonly property color barBorder: alpha(surface0, 0.9)

    // Module pills: outline style — accent lives in border and text
    readonly property real pillRadius: 7
    function pillBg(accent: color, neutral: bool): color {
        return neutral ? alpha(surface0, 0.35) : alpha(accent, 0.1);
    }
    function pillFg(accent: color, neutral: bool): color {
        return neutral ? text : accent;
    }
    function pillBorder(accent: color, neutral: bool): color {
        return neutral ? alpha(overlay0, 0.5) : alpha(accent, 0.75);
    }

    // Workspace buttons
    readonly property color wsIdleBg: pillBg(text, true)
    readonly property color wsActiveBg: alpha(lavender, 0.12)
    readonly property color wsActiveFg: lavender
    readonly property color wsActiveBorder: alpha(lavender, 0.75)
    readonly property real wsRadius: 6

    // Popup / tooltip surfaces — match the bar: same translucent crust so
    // both share one look under the Hyprland blur layer, set off by a border.
    readonly property color popupBg: barBg
    readonly property color popupBorder: surface1
    readonly property real popupRadius: 12

    // Cards inside popups
    readonly property color cardBg: alpha(surface0, 0.25)
    readonly property color cardHoverBg: alpha(surface1, 0.45)
    readonly property color cardBorder: alpha(overlay0, 0.55)
    readonly property real cardRadius: 8

    // Calendar drawer (continuous Monday-first month strip)
    readonly property int calDayCellWidth: 34
    readonly property int calCellHeight: 28
    readonly property int calWeekColWidth: 30
    readonly property int calCellSpacing: 2
    readonly property int calMonthGap: 10
    readonly property real calCellRadius: 6
    readonly property color calHeaderFg: subtext0
    readonly property color calWeekNumFg: overlay0
    readonly property color calDayFg: text
    readonly property color calAdjacentFg: overlay0
    readonly property color calWeekendBg: alpha(surface2, 0.22)
    function calTodayBg(accent: color): color { return alpha(accent, 0.20); }
    function calTodayBorder(accent: color): color { return alpha(accent, 0.85); }

    // The clock follows LC_TIME like waybar's locale-aware formats
    readonly property var dateLocale: {
        const lc = Quickshell.env("LC_TIME") || Quickshell.env("LC_ALL") || Quickshell.env("LANG") || "";
        return lc ? Qt.locale(lc.split(".")[0]) : Qt.locale();
    }
}
