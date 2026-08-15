pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "Nightfox"
    readonly property string label: "Nightfox"
    readonly property bool isDark: true

    readonly property color bg:             "#192330"
    readonly property color surface:        "#212e3f"
    readonly property color surfaceVariant: "#29394f"
    readonly property color surfaceRaised:  "#39506d"

    readonly property color fg:             "#cdcecf"
    readonly property color fgMuted:        "#71839b"
    readonly property color fgDisabled:     "#5a6a80"
    readonly property color fgOnAccent:     "#192330"
    readonly property color fgOnSurface:    "#cdcecf"
    readonly property color fgOnWarning:    "#192330"

    readonly property color accent:         "#719cd6"
    readonly property color accentHover:    "#5e89cc"
    readonly property color accentPressed:  "#4b76c2"
    readonly property color accentMuted:    "#719cd625"
    readonly property color accentSurface:  "#212e3f"

    readonly property color success:        "#81b29a"
    readonly property color successMuted:   "#81b29a25"
    readonly property color successSurface: "#212e3f"
    readonly property color warning:        "#dbc074"
    readonly property color warningMuted:   "#dbc07425"
    readonly property color warningSurface: "#212e3f"
    readonly property color error:          "#c94f6d"
    readonly property color errorMuted:     "#c94f6d25"
    readonly property color errorSurface:   "#212e3f"
    readonly property color info:           "#63cdcf"
    readonly property color infoMuted:      "#63cdcf25"
    readonly property color infoSurface:    "#212e3f"

    readonly property color border:         "#29394f"
    readonly property color borderStrong:   "#39506d"
    readonly property color borderFocus:    "#719cd6"
    readonly property color divider:        "#29394f"

    readonly property color pillBg:         "#131a24"
    readonly property color pillFg:         "#cdcecf"
    readonly property color pillBorder:     "#192330"

    readonly property color hoverOverlay:   "#cdcecf08"
    readonly property color pressedOverlay: "#cdcecf10"
    readonly property color selectedBg:     "#719cd618"
    readonly property color toggleTrack:    "#39506d"
    readonly property color toggleActive:   "#719cd6"
    readonly property color sliderTrack:    "#39506d"
    readonly property color sliderFill:     "#719cd6"
    readonly property color inputBg:        "#192330"
    readonly property color inputBorder:    "#39506d"
    readonly property color inputBorderFocus: "#719cd6"

    readonly property color scrollbarTrack:      "#cdcecf05"
    readonly property color scrollbarHandle:     "#cdcecf20"
    readonly property color scrollbarHandleHover: "#cdcecf35"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
