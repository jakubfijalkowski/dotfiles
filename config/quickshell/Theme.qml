pragma Singleton
import Quickshell
import QtQuick

// Shared look & feel for the bar (colors from waybar's colors.css).
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
    readonly property int pillRadius: 5
    readonly property int moduleSpacing: 5

    // transition: all 0.3s ease-in-out
    readonly property int transitionDuration: 300

    // The clock follows LC_TIME like waybar's locale-aware formats
    readonly property var dateLocale: {
        const lc = Quickshell.env("LC_TIME") || Quickshell.env("LC_ALL") || Quickshell.env("LANG") || "";
        return lc ? Qt.locale(lc.split(".")[0]) : Qt.locale();
    }
}
