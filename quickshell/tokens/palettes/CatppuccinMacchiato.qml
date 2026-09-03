pragma Singleton
import QtQuick

QtObject {
    id: p

    readonly property string name: "CatppuccinMacchiato"
    readonly property string label: "Catppuccin Macchiato"
    readonly property bool isDark: true

    readonly property color bg:             "#303446"
    readonly property color surface:        "#414559"
    readonly property color surfaceVariant: "#51576d"
    readonly property color surfaceRaised:  "#626880"

    readonly property color fg:             "#c6d0f5"
    readonly property color fgMuted:        "#a5adce"
    readonly property color fgDisabled:     "#737994"
    readonly property color fgOnAccent:     "#303446"
    readonly property color fgOnSurface:    "#c6d0f5"
    readonly property color fgOnWarning:    "#303446"

    readonly property color accent:         "#8caaee"
    readonly property color accentHover:    "#7284e0"
    readonly property color accentPressed:  "#5a6dd4"
    readonly property color accentMuted:    "#8caaee25"
    readonly property color accentSurface:  "#414559"

    readonly property color success:        "#a6d189"
    readonly property color successMuted:   "#a6d18925"
    readonly property color successSurface: "#414559"
    readonly property color warning:        "#ef9f76"
    readonly property color warningMuted:   "#ef9f7625"
    readonly property color warningSurface: "#414559"
    readonly property color error:          "#e78284"
    readonly property color errorMuted:     "#e7828425"
    readonly property color errorSurface:   "#414559"
    readonly property color info:           "#99d1db"
    readonly property color infoMuted:      "#99d1db25"
    readonly property color infoSurface:    "#414559"

    readonly property color border:         "#51576d"
    readonly property color borderStrong:   "#626880"
    readonly property color borderFocus:    "#8caaee"
    readonly property color divider:        "#51576d"

    readonly property color pillBg:         "#24273b"
    readonly property color pillFg:         "#c6d0f5"
    readonly property color pillBorder:     "#303446"

    readonly property color hoverOverlay:   "#08c6d0f5"
    readonly property color pressedOverlay: "#10c6d0f5"
    readonly property color selectedBg:     "#188caaee"
    readonly property color toggleTrack:    "#626880"
    readonly property color toggleActive:   "#8caaee"
    readonly property color sliderTrack:    "#626880"
    readonly property color sliderFill:     "#8caaee"
    readonly property color inputBg:        "#303446"
    readonly property color inputBorder:    "#626880"
    readonly property color inputBorderFocus: "#8caaee"

    readonly property color scrollbarTrack:      "#c6d0f505"
    readonly property color scrollbarHandle:     "#c6d0f520"
    readonly property color scrollbarHandleHover: "#c6d0f535"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
