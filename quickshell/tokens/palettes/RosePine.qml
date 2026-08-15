pragma Singleton
import QtQuick

// Rosé Pine Main variant

QtObject {
    id: p
    readonly property string name: "RosePine"
    readonly property string label: "Rosé Pine"
    readonly property bool isDark: true

    readonly property color bg:             "#191724"
    readonly property color surface:        "#1f1d2e"
    readonly property color surfaceVariant: "#26233a"
    readonly property color surfaceRaised:  "#403d52"

    readonly property color fg:             "#e0def4"
    readonly property color fgMuted:        "#908caa"
    readonly property color fgDisabled:     "#6e6a86"
    readonly property color fgOnAccent:     "#191724"
    readonly property color fgOnSurface:    "#e0def4"
    readonly property color fgOnWarning:    "#191724"

    readonly property color accent:         "#c4a7e7"
    readonly property color accentHover:    "#b696da"
    readonly property color accentPressed:  "#a885cd"
    readonly property color accentMuted:    "#c4a7e725"
    readonly property color accentSurface:  "#1f1d2e"

    readonly property color success:        "#31748f"
    readonly property color successMuted:   "#31748f25"
    readonly property color successSurface: "#1f1d2e"
    readonly property color warning:        "#f6c177"
    readonly property color warningMuted:   "#f6c17725"
    readonly property color warningSurface: "#1f1d2e"
    readonly property color error:          "#eb6f92"
    readonly property color errorMuted:     "#eb6f9225"
    readonly property color errorSurface:   "#1f1d2e"
    readonly property color info:           "#9ccfd8"
    readonly property color infoMuted:      "#9ccfd825"
    readonly property color infoSurface:    "#1f1d2e"

    readonly property color border:         "#26233a"
    readonly property color borderStrong:   "#403d52"
    readonly property color borderFocus:    "#c4a7e7"
    readonly property color divider:        "#26233a"

    readonly property color pillBg:         "#13111f"
    readonly property color pillFg:         "#e0def4"
    readonly property color pillBorder:     "#191724"

    readonly property color hoverOverlay:   "#e0def408"
    readonly property color pressedOverlay: "#e0def410"
    readonly property color selectedBg:     "#c4a7e718"
    readonly property color toggleTrack:    "#403d52"
    readonly property color toggleActive:   "#c4a7e7"
    readonly property color sliderTrack:    "#403d52"
    readonly property color sliderFill:     "#c4a7e7"
    readonly property color inputBg:        "#191724"
    readonly property color inputBorder:    "#403d52"
    readonly property color inputBorderFocus: "#c4a7e7"

    readonly property color scrollbarTrack:      "#e0def405"
    readonly property color scrollbarHandle:     "#e0def420"
    readonly property color scrollbarHandleHover: "#e0def435"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
