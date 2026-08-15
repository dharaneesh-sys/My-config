pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "TokyoNight"
    readonly property string label: "Tokyo Night"
    readonly property bool isDark: true

    readonly property color bg:             "#1a1b26"
    readonly property color surface:        "#1f2335"
    readonly property color surfaceVariant: "#292e42"
    readonly property color surfaceRaised:  "#3b4261"

    readonly property color fg:             "#c0caf5"
    readonly property color fgMuted:        "#a9b1d6"
    readonly property color fgDisabled:     "#565f89"
    readonly property color fgOnAccent:     "#1a1b26"
    readonly property color fgOnSurface:    "#c0caf5"
    readonly property color fgOnWarning:    "#1a1b26"

    readonly property color accent:         "#7aa2f7"
    readonly property color accentHover:    "#6890e5"
    readonly property color accentPressed:  "#567ed3"
    readonly property color accentMuted:    "#7aa2f725"
    readonly property color accentSurface:  "#1f2335"

    readonly property color success:        "#9ece6a"
    readonly property color successMuted:   "#9ece6a25"
    readonly property color successSurface: "#1f2335"
    readonly property color warning:        "#e0af68"
    readonly property color warningMuted:   "#e0af6825"
    readonly property color warningSurface: "#1f2335"
    readonly property color error:          "#f7768e"
    readonly property color errorMuted:     "#f7768e25"
    readonly property color errorSurface:   "#1f2335"
    readonly property color info:           "#7dcfff"
    readonly property color infoMuted:      "#7dcfff25"
    readonly property color infoSurface:    "#1f2335"

    readonly property color border:         "#292e42"
    readonly property color borderStrong:   "#3b4261"
    readonly property color borderFocus:    "#7aa2f7"
    readonly property color divider:        "#292e42"

    readonly property color pillBg:         "#16161e"
    readonly property color pillFg:         "#c0caf5"
    readonly property color pillBorder:     "#1a1b26"

    readonly property color hoverOverlay:   "#c0caf508"
    readonly property color pressedOverlay: "#c0caf510"
    readonly property color selectedBg:     "#7aa2f718"
    readonly property color toggleTrack:    "#3b4261"
    readonly property color toggleActive:   "#7aa2f7"
    readonly property color sliderTrack:    "#3b4261"
    readonly property color sliderFill:     "#7aa2f7"
    readonly property color inputBg:        "#1a1b26"
    readonly property color inputBorder:    "#3b4261"
    readonly property color inputBorderFocus: "#7aa2f7"

    readonly property color scrollbarTrack:      "#c0caf505"
    readonly property color scrollbarHandle:     "#c0caf520"
    readonly property color scrollbarHandleHover: "#c0caf535"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
