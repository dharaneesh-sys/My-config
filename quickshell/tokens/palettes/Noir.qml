pragma Singleton
import QtQuick

// Noir: pure minimalist black. Maximum OLED contrast.

QtObject {
    id: p
    readonly property string name: "Noir"
    readonly property string label: "Noir"
    readonly property bool isDark: true

    readonly property color bg:             "#000000"
    readonly property color surface:        "#0d0d0d"
    readonly property color surfaceVariant: "#1a1a1a"
    readonly property color surfaceRaised:  "#262626"

    readonly property color fg:             "#f0f0f0"
    readonly property color fgMuted:        "#808080"
    readonly property color fgDisabled:     "#4d4d4d"
    readonly property color fgOnAccent:     "#000000"
    readonly property color fgOnSurface:    "#f0f0f0"
    readonly property color fgOnWarning:    "#000000"

    readonly property color accent:         "#5b9bd5"
    readonly property color accentHover:    "#4a8ac7"
    readonly property color accentPressed:  "#3a79b9"
    readonly property color accentMuted:    "#5b9bd525"
    readonly property color accentSurface:  "#0d0d0d"

    readonly property color success:        "#6a9955"
    readonly property color successMuted:   "#6a995525"
    readonly property color successSurface: "#0d0d0d"
    readonly property color warning:        "#dcdcaa"
    readonly property color warningMuted:   "#dcdcaa25"
    readonly property color warningSurface: "#0d0d0d"
    readonly property color error:          "#f44747"
    readonly property color errorMuted:     "#f4474725"
    readonly property color errorSurface:   "#0d0d0d"
    readonly property color info:           "#569cd6"
    readonly property color infoMuted:      "#569cd625"
    readonly property color infoSurface:    "#0d0d0d"

    readonly property color border:         "#1a1a1a"
    readonly property color borderStrong:   "#262626"
    readonly property color borderFocus:    "#5b9bd5"
    readonly property color divider:        "#1a1a1a"

    readonly property color pillBg:         "#000000"
    readonly property color pillFg:         "#f0f0f0"
    readonly property color pillBorder:     "#0d0d0d"

    readonly property color hoverOverlay:   "#08f0f0f0"
    readonly property color pressedOverlay: "#10f0f0f0"
    readonly property color selectedBg:     "#185b9bd5"
    readonly property color toggleTrack:    "#262626"
    readonly property color toggleActive:   "#5b9bd5"
    readonly property color sliderTrack:    "#262626"
    readonly property color sliderFill:     "#5b9bd5"
    readonly property color inputBg:        "#0d0d0d"
    readonly property color inputBorder:    "#262626"
    readonly property color inputBorderFocus: "#5b9bd5"

    readonly property color scrollbarTrack:      "#f0f0f005"
    readonly property color scrollbarHandle:     "#f0f0f020"
    readonly property color scrollbarHandleHover: "#f0f0f035"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
