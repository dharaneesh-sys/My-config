pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "Nord"
    readonly property string label: "Nord"
    readonly property bool isDark: true

    readonly property color bg:             "#2e3440"
    readonly property color surface:        "#3b4252"
    readonly property color surfaceVariant: "#434c5e"
    readonly property color surfaceRaised:  "#4c566a"

    readonly property color fg:             "#eceff4"
    readonly property color fgMuted:        "#d8dee9"
    readonly property color fgDisabled:     "#81a1c1"
    readonly property color fgOnAccent:     "#2e3440"
    readonly property color fgOnSurface:    "#eceff4"
    readonly property color fgOnWarning:    "#2e3440"

    readonly property color accent:         "#88c0d0"
    readonly property color accentHover:    "#7ab3c4"
    readonly property color accentPressed:  "#6ca6b8"
    readonly property color accentMuted:    "#88c0d025"
    readonly property color accentSurface:  "#3b4252"

    readonly property color success:        "#a3be8c"
    readonly property color successMuted:   "#a3be8c25"
    readonly property color successSurface: "#3b4252"
    readonly property color warning:        "#ebcb8b"
    readonly property color warningMuted:   "#ebcb8b25"
    readonly property color warningSurface: "#3b4252"
    readonly property color error:          "#bf616a"
    readonly property color errorMuted:     "#bf616a25"
    readonly property color errorSurface:   "#3b4252"
    readonly property color info:           "#81a1c1"
    readonly property color infoMuted:      "#81a1c125"
    readonly property color infoSurface:    "#3b4252"

    readonly property color border:         "#434c5e"
    readonly property color borderStrong:   "#4c566a"
    readonly property color borderFocus:    "#88c0d0"
    readonly property color divider:        "#434c5e"

    readonly property color pillBg:         "#252b37"
    readonly property color pillFg:         "#eceff4"
    readonly property color pillBorder:     "#2e3440"

    readonly property color hoverOverlay:   "#08eceff4"
    readonly property color pressedOverlay: "#10eceff4"
    readonly property color selectedBg:     "#1888c0d0"
    readonly property color toggleTrack:    "#4c566a"
    readonly property color toggleActive:   "#88c0d0"
    readonly property color sliderTrack:    "#4c566a"
    readonly property color sliderFill:     "#88c0d0"
    readonly property color inputBg:        "#2e3440"
    readonly property color inputBorder:    "#4c566a"
    readonly property color inputBorderFocus: "#88c0d0"

    readonly property color scrollbarTrack:      "#eceff405"
    readonly property color scrollbarHandle:     "#eceff420"
    readonly property color scrollbarHandleHover: "#eceff435"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
