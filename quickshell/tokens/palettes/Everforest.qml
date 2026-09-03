pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "Everforest"
    readonly property string label: "Everforest"
    readonly property bool isDark: true

    readonly property color bg:             "#2d353b"
    readonly property color surface:        "#343f44"
    readonly property color surfaceVariant: "#3b4449"
    readonly property color surfaceRaised:  "#445055"

    readonly property color fg:             "#d3c6aa"
    readonly property color fgMuted:        "#859289"
    readonly property color fgDisabled:     "#5c6a60"
    readonly property color fgOnAccent:     "#2d353b"
    readonly property color fgOnSurface:    "#d3c6aa"
    readonly property color fgOnWarning:    "#2d353b"

    readonly property color accent:         "#7fbbb3"
    readonly property color accentHover:    "#6aa8a0"
    readonly property color accentPressed:  "#55958d"
    readonly property color accentMuted:    "#7fbbb325"
    readonly property color accentSurface:  "#343f44"

    readonly property color success:        "#a7c080"
    readonly property color successMuted:   "#a7c08025"
    readonly property color successSurface: "#343f44"
    readonly property color warning:        "#dbbc7f"
    readonly property color warningMuted:   "#dbbc7f25"
    readonly property color warningSurface: "#343f44"
    readonly property color error:          "#e67e67"
    readonly property color errorMuted:     "#e67e6725"
    readonly property color errorSurface:   "#343f44"
    readonly property color info:           "#83b598"
    readonly property color infoMuted:      "#83b59825"
    readonly property color infoSurface:    "#343f44"

    readonly property color border:         "#3b4449"
    readonly property color borderStrong:   "#445055"
    readonly property color borderFocus:    "#7fbbb3"
    readonly property color divider:        "#3b4449"

    readonly property color pillBg:         "#232a2e"
    readonly property color pillFg:         "#d3c6aa"
    readonly property color pillBorder:     "#2d353b"

    readonly property color hoverOverlay:   "#08d3c6aa"
    readonly property color pressedOverlay: "#10d3c6aa"
    readonly property color selectedBg:     "#187fbbb3"
    readonly property color toggleTrack:    "#445055"
    readonly property color toggleActive:   "#7fbbb3"
    readonly property color sliderTrack:    "#445055"
    readonly property color sliderFill:     "#7fbbb3"
    readonly property color inputBg:        "#2d353b"
    readonly property color inputBorder:    "#445055"
    readonly property color inputBorderFocus: "#7fbbb3"

    readonly property color scrollbarTrack:      "#d3c6aa05"
    readonly property color scrollbarHandle:     "#d3c6aa20"
    readonly property color scrollbarHandleHover: "#d3c6aa35"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
