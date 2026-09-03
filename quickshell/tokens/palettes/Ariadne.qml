pragma Singleton
import QtQuick

QtObject {
    id: p

    readonly property string name: "Ariadne"
    readonly property string label: "Ariadne"
    readonly property bool isDark: true

    // ─── Backgrounds ──────────────────────────────────────────────
    readonly property color bg:             "#0a1816"
    readonly property color surface:        "#0a1816"
    readonly property color surfaceVariant: "#0f211f"
    readonly property color surfaceRaised:  "#152a26"

    // ─── Foregrounds ──────────────────────────────────────────────
    readonly property color fg:             "#f5e2c5"
    readonly property color fgMuted:        "#c4b09a"
    readonly property color fgDisabled:     "#7a6e5a"
    readonly property color fgOnAccent:     "#040e0d"
    readonly property color fgOnSurface:    "#f5e2c5"
    readonly property color fgOnWarning:    "#040e0d"

    // ─── Accent ───────────────────────────────────────────────────
    readonly property color accent:         "#7ad9a8"
    readonly property color accentHover:    "#5cb88a"
    readonly property color accentPressed:  "#3d9b6c"
    readonly property color accentMuted:    "#7ad9a825"
    readonly property color accentSurface:  "#0f211f"

    // ─── Semantic ─────────────────────────────────────────────────
    readonly property color success:        "#7ad9a8"
    readonly property color successMuted:   "#7ad9a825"
    readonly property color successSurface: "#0f211f"
    readonly property color warning:        "#ffa478"
    readonly property color warningMuted:   "#ffa47825"
    readonly property color warningSurface: "#0f211f"
    readonly property color error:          "#ff6048"
    readonly property color errorMuted:     "#ff604825"
    readonly property color errorSurface:   "#0f211f"
    readonly property color info:           "#5fc8d4"
    readonly property color infoMuted:      "#5fc8d425"
    readonly property color infoSurface:    "#0f211f"

    // ─── Borders & dividers ───────────────────────────────────────
    readonly property color border:         "#152a26"
    readonly property color borderStrong:   "#1d3631"
    readonly property color borderFocus:    "#7ad9a8"
    readonly property color divider:        "#152a26"

    // ─── Pill ─────────────────────────────────────────────────────
    readonly property color pillBg:         "#040e0d"
    readonly property color pillFg:         "#f5e2c5"
    readonly property color pillBorder:     "#0a1816"

    // ─── Interactive ──────────────────────────────────────────────
    readonly property color hoverOverlay:   "#08f5e2c5"
    readonly property color pressedOverlay: "#10f5e2c5"
    readonly property color selectedBg:     "#187ad9a8"
    readonly property color toggleTrack:    "#1d3631"
    readonly property color toggleActive:   "#7ad9a8"
    readonly property color sliderTrack:    "#1d3631"
    readonly property color sliderFill:     "#7ad9a8"
    readonly property color inputBg:        "#0a1816"
    readonly property color inputBorder:    "#1d3631"
    readonly property color inputBorderFocus: "#7ad9a8"

    // ─── Scrollbar ────────────────────────────────────────────────
    readonly property color scrollbarTrack:      "#7ad9a808"
    readonly property color scrollbarHandle:     "#7ad9a84d"
    readonly property color scrollbarHandleHover: "#7ad9a880"

    // ─── Overlay ──────────────────────────────────────────────────
    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"

    // ─── Shadow ───────────────────────────────────────────────────
    readonly property color shadow:         "#000000"
}
