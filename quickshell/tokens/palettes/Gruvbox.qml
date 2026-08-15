pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "Gruvbox"
    readonly property string label: "Gruvbox"
    readonly property bool isDark: true

    readonly property color bg:             "#282828"
    readonly property color surface:        "#3c3836"
    readonly property color surfaceVariant: "#504945"
    readonly property color surfaceRaised:  "#665c54"

    readonly property color fg:             "#ebdbb2"
    readonly property color fgMuted:        "#a89984"
    readonly property color fgDisabled:     "#665c54"
    readonly property color fgOnAccent:     "#282828"
    readonly property color fgOnSurface:    "#ebdbb2"
    readonly property color fgOnWarning:    "#282828"

    readonly property color accent:         "#83a598"
    readonly property color accentHover:    "#729192"
    readonly property color accentPressed:  "#617d8c"
    readonly property color accentMuted:    "#83a59825"
    readonly property color accentSurface:  "#3c3836"

    readonly property color success:        "#b8bb26"
    readonly property color successMuted:   "#b8bb2625"
    readonly property color successSurface: "#3c3836"
    readonly property color warning:        "#fabd2f"
    readonly property color warningMuted:   "#fabd2f25"
    readonly property color warningSurface: "#3c3836"
    readonly property color error:          "#fb4934"
    readonly property color errorMuted:     "#fb493425"
    readonly property color errorSurface:   "#3c3836"
    readonly property color info:           "#8ec07c"
    readonly property color infoMuted:      "#8ec07c25"
    readonly property color infoSurface:    "#3c3836"

    readonly property color border:         "#504945"
    readonly property color borderStrong:   "#665c54"
    readonly property color borderFocus:    "#83a598"
    readonly property color divider:        "#504945"

    readonly property color pillBg:         "#1d2021"
    readonly property color pillFg:         "#ebdbb2"
    readonly property color pillBorder:     "#282828"

    readonly property color hoverOverlay:   "#ebdbb208"
    readonly property color pressedOverlay: "#ebdbb210"
    readonly property color selectedBg:     "#83a59818"
    readonly property color toggleTrack:    "#665c54"
    readonly property color toggleActive:   "#83a598"
    readonly property color sliderTrack:    "#665c54"
    readonly property color sliderFill:     "#83a598"
    readonly property color inputBg:        "#282828"
    readonly property color inputBorder:    "#665c54"
    readonly property color inputBorderFocus: "#83a598"

    readonly property color scrollbarTrack:      "#ebdbb205"
    readonly property color scrollbarHandle:     "#ebdbb220"
    readonly property color scrollbarHandleHover: "#ebdbb235"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
