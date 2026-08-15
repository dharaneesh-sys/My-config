pragma Singleton
import QtQuick

QtObject {
    id: p
    readonly property string name: "SolarizedDark"
    readonly property string label: "Solarized Dark"
    readonly property bool isDark: true

    readonly property color bg:             "#002b36"
    readonly property color surface:        "#073642"
    readonly property color surfaceVariant: "#0a4050"
    readonly property color surfaceRaised:  "#11535f"

    readonly property color fg:             "#93a1a1"
    readonly property color fgMuted:        "#657b83"
    readonly property color fgDisabled:     "#586e75"
    readonly property color fgOnAccent:     "#002b36"
    readonly property color fgOnSurface:    "#93a1a1"
    readonly property color fgOnWarning:    "#002b36"

    readonly property color accent:         "#268bd2"
    readonly property color accentHover:    "#1e7dba"
    readonly property color accentPressed:  "#1871a8"
    readonly property color accentMuted:    "#268bd225"
    readonly property color accentSurface:  "#073642"

    readonly property color success:        "#859900"
    readonly property color successMuted:   "#85990025"
    readonly property color successSurface: "#073642"
    readonly property color warning:        "#b58900"
    readonly property color warningMuted:   "#b5890025"
    readonly property color warningSurface: "#073642"
    readonly property color error:          "#dc322f"
    readonly property color errorMuted:     "#dc322f25"
    readonly property color errorSurface:   "#073642"
    readonly property color info:           "#2aa198"
    readonly property color infoMuted:      "#2aa19825"
    readonly property color infoSurface:    "#073642"

    readonly property color border:         "#0a4050"
    readonly property color borderStrong:   "#11535f"
    readonly property color borderFocus:    "#268bd2"
    readonly property color divider:        "#0a4050"

    readonly property color pillBg:         "#001e27"
    readonly property color pillFg:         "#93a1a1"
    readonly property color pillBorder:     "#002b36"

    readonly property color hoverOverlay:   "#93a1a108"
    readonly property color pressedOverlay: "#93a1a110"
    readonly property color selectedBg:     "#268bd218"
    readonly property color toggleTrack:    "#11535f"
    readonly property color toggleActive:   "#268bd2"
    readonly property color sliderTrack:    "#11535f"
    readonly property color sliderFill:     "#268bd2"
    readonly property color inputBg:        "#002b36"
    readonly property color inputBorder:    "#11535f"
    readonly property color inputBorderFocus: "#268bd2"

    readonly property color scrollbarTrack:      "#93a1a105"
    readonly property color scrollbarHandle:     "#93a1a120"
    readonly property color scrollbarHandleHover: "#93a1a135"

    readonly property color overlay:        "#000000aa"
    readonly property color overlayStrong:  "#000000cc"
    readonly property color shadow:         "#000000"
}
