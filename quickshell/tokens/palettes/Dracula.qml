pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "Dracula"
    readonly property string label: "Dracula"
    readonly property bool isDark: true

    readonly property color bg:             "#282a36"
    readonly property color surface:        "#343746"
    readonly property color surfaceVariant: "#44475a"
    readonly property color surfaceRaised:  "#5a5c6e"

    readonly property color fg:             "#f8f8f2"
    readonly property color fgMuted:        "#6272a4"
    readonly property color fgDisabled:     "#445065"
    readonly property color fgOnAccent:     "#282a36"
    readonly property color fgOnSurface:    "#f8f8f2"
    readonly property color fgOnWarning:    "#282a36"

    readonly property color accent:         "#bd93f9"
    readonly property color accentHover:    "#caa8fc"
    readonly property color accentPressed:  "#a67be8"
    readonly property color accentMuted:    "#bd93f925"
    readonly property color accentSurface:  "#343746"

    readonly property color success:        "#50fa7b"
    readonly property color successMuted:   "#50fa7b25"
    readonly property color successSurface: "#343746"
    readonly property color warning:        "#ffb86c"
    readonly property color warningMuted:   "#ffb86c25"
    readonly property color warningSurface: "#343746"
    readonly property color error:          "#ff5555"
    readonly property color errorMuted:     "#ff555525"
    readonly property color errorSurface:   "#343746"
    readonly property color info:           "#8be9fd"
    readonly property color infoMuted:      "#8be9fd25"
    readonly property color infoSurface:    "#343746"

    readonly property color border:         "#44475a"
    readonly property color borderStrong:   "#5a5c6e"
    readonly property color borderFocus:    "#bd93f9"
    readonly property color divider:        "#44475a"

    readonly property color pillBg:         "#21222c"
    readonly property color pillFg:         "#f8f8f2"
    readonly property color pillBorder:     "#282a36"

    readonly property color hoverOverlay:   "#08f8f8f2"
    readonly property color pressedOverlay: "#10f8f8f2"
    readonly property color selectedBg:     "#18bd93f9"
    readonly property color toggleTrack:    "#5a5c6e"
    readonly property color toggleActive:   "#bd93f9"
    readonly property color sliderTrack:    "#5a5c6e"
    readonly property color sliderFill:     "#bd93f9"
    readonly property color inputBg:        "#282a36"
    readonly property color inputBorder:    "#5a5c6e"
    readonly property color inputBorderFocus: "#bd93f9"

    readonly property color scrollbarTrack:      "#f8f8f205"
    readonly property color scrollbarHandle:     "#f8f8f220"
    readonly property color scrollbarHandleHover: "#f8f8f235"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
