pragma Singleton
import QtQuick

// Dynamic: placeholder for wallpaper-derived Material You palettes.
// Replace these values with output from wallust/pywal/material-color-utilities
// at runtime. The structure is identical to all other palettes.

QtObject {
    id: p
    readonly property string name: "Dynamic"
    readonly property string label: "Dynamic"
    readonly property bool isDark: true

    // ─── Defaults: Catppuccin Mocha as fallback ───────────────────
    // Replace ALL hex values below with your dynamic palette output.
    readonly property color bg:             "#1e1e2e"
    readonly property color surface:        "#313244"
    readonly property color surfaceVariant: "#45475a"
    readonly property color surfaceRaised:  "#585b70"

    readonly property color fg:             "#cdd6f4"
    readonly property color fgMuted:        "#a6adc8"
    readonly property color fgDisabled:     "#6c7086"
    readonly property color fgOnAccent:     "#1e1e2e"
    readonly property color fgOnSurface:    "#cdd6f4"
    readonly property color fgOnWarning:    "#1e1e2e"

    readonly property color accent:         "#89b4fa"
    readonly property color accentHover:    "#74a0e6"
    readonly property color accentPressed:  "#5f8cd2"
    readonly property color accentMuted:    "#89b4fa25"
    readonly property color accentSurface:  "#313244"

    readonly property color success:        "#a6e3a1"
    readonly property color successMuted:   "#a6e3a125"
    readonly property color successSurface: "#313244"
    readonly property color warning:        "#fab387"
    readonly property color warningMuted:   "#fab38725"
    readonly property color warningSurface: "#313244"
    readonly property color error:          "#f38ba8"
    readonly property color errorMuted:     "#f38ba825"
    readonly property color errorSurface:   "#313244"
    readonly property color info:           "#89dceb"
    readonly property color infoMuted:      "#89dceb25"
    readonly property color infoSurface:    "#313244"

    readonly property color border:         "#45475a"
    readonly property color borderStrong:   "#585b70"
    readonly property color borderFocus:    "#89b4fa"
    readonly property color divider:        "#45475a"

    readonly property color pillBg:         "#11111b"
    readonly property color pillFg:         "#cdd6f4"
    readonly property color pillBorder:     "#1e1e2e"

    readonly property color hoverOverlay:   "#cdd6f408"
    readonly property color pressedOverlay: "#cdd6f410"
    readonly property color selectedBg:     "#89b4fa18"
    readonly property color toggleTrack:    "#585b70"
    readonly property color toggleActive:   "#89b4fa"
    readonly property color sliderTrack:    "#585b70"
    readonly property color sliderFill:     "#89b4fa"
    readonly property color inputBg:        "#1e1e2e"
    readonly property color inputBorder:    "#585b70"
    readonly property color inputBorderFocus: "#89b4fa"

    readonly property color scrollbarTrack:      "#cdd6f405"
    readonly property color scrollbarHandle:     "#cdd6f420"
    readonly property color scrollbarHandleHover: "#cdd6f435"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
