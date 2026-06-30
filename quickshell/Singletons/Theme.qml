pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ── JSON-backed theme reader ─────────────────
    readonly property bool __loaded: themeFile.loaded

    FileView {
        id: themeFile
        path: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/ricelin/theme-colors.json"
        blockLoading: true
        watchChanges: true
        printErrors: false

        onFileChanged: reload()

        JsonAdapter {
            id: m3
            // Material Design 3 color tokens (all 49) — snake_case avoids QML signal-handler collision
            property color primary:                   "#a7c080"
            property color on_primary:                "#2d353b"
            property color primary_container:         "#6a7a5a"
            property color on_primary_container:      "#d3c6aa"
            property color primary_fixed:             "#a7c080"
            property color primary_fixed_dim:         "#8da376"
            property color on_primary_fixed:          "#2d353b"
            property color on_primary_fixed_variant:  "#3d484d"
            property color secondary:                 "#c4a87c"
            property color on_secondary:              "#2d353b"
            property color secondary_container:       "#8a7a5a"
            property color on_secondary_container:    "#d3c6aa"
            property color secondary_fixed:           "#c4a87c"
            property color secondary_fixed_dim:       "#b9b193"
            property color on_secondary_fixed:        "#2d353b"
            property color on_secondary_fixed_variant:"#3d484d"
            property color tertiary:                  "#8da376"
            property color on_tertiary:               "#2d353b"
            property color tertiary_container:        "#5a6a3a"
            property color on_tertiary_container:     "#d3c6aa"
            property color tertiary_fixed:            "#8da376"
            property color tertiary_fixed_dim:        "#769a5a"
            property color on_tertiary_fixed:         "#2d353b"
            property color on_tertiary_fixed_variant: "#3d484d"
            property color error:                     "#e67e80"
            property color on_error:                  "#2d353b"
            property color error_container:           "#5a3a3a"
            property color on_error_container:        "#e6b3b3"
            property color surface:                   "#2d353b"
            property color on_surface:                "#d3c6aa"
            property color surface_variant:           "#4a5a4a"
            property color on_surface_variant:        "#a6b0a0"
            property color surface_dim:               "#1e2326"
            property color surface_bright:            "#3d484d"
            property color surface_container_lowest:  "#1a1f22"
            property color surface_container_low:     "#232a2e"
            property color surface_container:         "#3d484d"
            property color surface_container_high:    "#3d484d"
            property color surface_container_highest: "#4a555a"
            property color outline:                   "#5f6c71"
            property color outline_variant:           "#4a5a4a"
            property color shadow:                    "#000000"
            property color scrim:                     "#000000"
            property color inverse_surface:           "#d3c6aa"
            property color inverse_on_surface:        "#2d353b"
            property color inverse_primary:           "#6a7a5a"
            property color background:                "#2d353b"
            property color source_color:              "#a7c080"
            property color surface_tint:              "#a7c080"
        }
    }

    // ── Helper functions ────────────────────────
    function alpha(c, a) {
        if (!c || typeof c.r !== "number") return Qt.rgba(0, 0, 0, a || 0);
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function hexStr(c) {
        if (!c || typeof c.r !== "number") return "#000000";
        var hr = ((c.r * 255) | 0).toString(16).padStart(2, '0');
        var hg = ((c.g * 255) | 0).toString(16).padStart(2, '0');
        var hb = ((c.b * 255) | 0).toString(16).padStart(2, '0');
        return "#" + hr + hg + hb;
    }

    // ── Informational ──────────────────────────
    property bool darkMode: true

    // ── Ricelin color properties ────────────────
    property color verm:        __loaded ? m3.primary                 : "#a7c080"
    property color vermLit:     __loaded ? m3.secondary               : "#c4a87c"
    property color vermDeep:    __loaded ? m3.tertiary                : "#8da376"
    property color cream:       __loaded ? m3.on_surface              : "#d3c6aa"
    property color bright:                                             "#ffffff"
    property color dim:         __loaded ? m3.on_surface_variant      : "#a6b0a0"
    property color cardTop:     __loaded ? m3.surface_container_high  : "#3d484d"
    property color cardBot:     __loaded ? m3.surface                 : "#2d353b"
    property color border:      __loaded ? m3.outline                 : "#5f6c71"
    property color shadow:                                             Qt.rgba(0, 0, 0, 0.55)
    property color tileBg:      __loaded ? m3.surface_container       : "#3d484d"
    property color subtle:      __loaded ? m3.on_surface_variant      : "#a6b0a0"
    property color faint:       __loaded ? m3.outline                 : "#5f6c71"
    property color iconDim:     __loaded ? m3.on_surface              : "#d3c6aa"
    property color hair:        __loaded ? alpha(m3.outline_variant, 0.13)                : Qt.rgba(0.6, 0.7, 0.6, 0.13)
    property color sheen:       __loaded ? alpha(m3.surface_container_high, 0.07)          : Qt.rgba(0.6, 0.7, 0.6, 0.07)
    property color vermDim:     __loaded ? m3.primary_container       : "#6a7a5a"
    property color vermDimDeep: __loaded ? alpha(m3.primary_container, 0.6)                : "#4a5a3a"
    property color vermBurn:    __loaded ? alpha(m3.primary, 0.4)                          : "#5a6a3a"
    property color tickRest:    __loaded ? m3.on_surface_variant      : "#9aab8a"
    property color threadBg:    __loaded ? alpha(m3.surface_variant, 0.13)                 : Qt.rgba(0.6, 0.7, 0.6, 0.13)
    property color flameCore:   __loaded ? m3.on_surface              : "#e6d6b3"
    property color flameGlow:   __loaded ? m3.secondary               : "#c4a87c"
    property string flameInk:   __loaded ? hexStr(m3.on_surface)             : "#b3a06a"
    property string flameEmber: __loaded ? hexStr(m3.surface_container)      : "#5a4a2a"
    property string flameBurn:  __loaded ? hexStr(m3.outline)                : "#6a5a3a"
    property string flameTip:   __loaded ? hexStr(m3.on_surface_variant)     : "#d4bea0"
    property color todayWarm:   __loaded ? m3.secondary               : "#c4a87c"
    property color ghost:       __loaded ? m3.surface_variant         : "#4a5a4a"
    property color frameBg:     __loaded ? alpha(m3.surface_variant, 0.06)                : Qt.rgba(0.6, 0.7, 0.6, 0.06)
    property color frameBorder: __loaded ? alpha(m3.outline_variant, 0.10)                : Qt.rgba(0.6, 0.7, 0.6, 0.10)
    property color creamMenu:   __loaded ? alpha(m3.on_surface, 0.82)                     : Qt.rgba(0.82, 0.78, 0.68, 0.82)
    readonly property real shadowOpacity: 0.5
    readonly property string font:   "Noto Sans"
    readonly property string fontJp: "Noto Sans CJK JP"

    /**
     * MPRIS trackArtists arrives as a JS array from some players and as a
     * plain string from others (Spotify); calling join on the string throws
     * and kills the whole binding. Handles both, falls back to trackArtist.
     */
    function joinArtists(artists, single) {
        if (artists && typeof artists.join === "function" && artists.length > 0)
            return artists.join(", ");
        if (artists && String(artists).length > 0)
            return String(artists);
        return single ? String(single) : "";
    }
}
