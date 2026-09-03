pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

// Dynamic: wallpaper-derived Material You palette.
// Reads from ~/.config/hypr/themes/Dynamic/palette on startup and
// watches for changes so the shell updates live when the wallpaper changes.

QtObject {
    id: p
    readonly property string name: "Dynamic"
    readonly property string label: "Dynamic"
    readonly property bool isDark: true

    // ─── Palette file path ──────────────────────────────────────
    readonly property string _home: Quickshell.env("HOME")
    readonly property string _palettePath: _home + "/.config/hypr/themes/Dynamic/palette"

    // ─── Colors (mutable, updated from palette file) ────────────
    property color bg:             "#1e1e2e"
    property color surface:        "#313244"
    property color surfaceVariant: "#45475a"
    property color surfaceRaised:  "#585b70"

    property color fg:             "#cdd6f4"
    property color fgMuted:        "#a6adc8"
    property color fgDisabled:     "#6c7086"
    property color fgOnAccent:     "#1e1e2e"
    property color fgOnSurface:    "#cdd6f4"
    property color fgOnWarning:    "#1e1e2e"

    property color accent:         "#89b4fa"
    property color accentHover:    "#74a0e6"
    property color accentPressed:  "#5f8cd2"
    property color accentMuted:    "#89b4fa25"
    property color accentSurface:  "#313244"

    property color success:        "#a6e3a1"
    property color successMuted:   "#a6e3a125"
    property color successSurface: "#313244"
    property color warning:        "#fab387"
    property color warningMuted:   "#fab38725"
    property color warningSurface: "#313244"
    property color error:          "#f38ba8"
    property color errorMuted:     "#f38ba825"
    property color errorSurface:   "#313244"
    property color info:           "#89dceb"
    property color infoMuted:      "#89dceb25"
    property color infoSurface:    "#313244"

    property color border:         "#45475a"
    property color borderStrong:   "#585b70"
    property color borderFocus:    "#89b4fa"
    property color divider:        "#45475a"

    property color pillBg:         "#11111b"
    property color pillFg:         "#cdd6f4"
    property color pillBorder:     "#1e1e2e"

    property color hoverOverlay:   "#08cdd6f4"
    property color pressedOverlay: "#10cdd6f4"
    property color selectedBg:     "#1889b4fa"
    property color toggleTrack:    "#585b70"
    property color toggleActive:   "#89b4fa"
    property color sliderTrack:    "#585b70"
    property color sliderFill:     "#89b4fa"
    property color inputBg:        "#1e1e2e"
    property color inputBorder:    "#585b70"
    property color inputBorderFocus: "#89b4fa"

    property color scrollbarTrack:      "#cdd6f405"
    property color scrollbarHandle:     "#cdd6f420"
    property color scrollbarHandleHover: "#cdd6f435"

    property color overlay:        "#000000aa"
    property color overlayStrong:  "#000000cc"
    property color shadow:         "#000000"

    // ─── Palette file reader ──────────────────────────────────
    property FileView _paletteFile: FileView {
        id: paletteFile
        path: p._palettePath
        preload: true
        watchChanges: true
        onFileChanged: paletteFile.reload()
        onLoaded: p._applyPalette(paletteFile.text())
        onLoadFailed: {
            // File missing or empty — keep hardcoded fallback colors.
        }
    }

    // ─── Parse key=value palette and apply colors ─────────────
    function _applyPalette(text) {
        if (!text || text.trim() === "") return
        var colors = {}
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "" || line.startsWith("#")) continue
            var eq = line.indexOf("=")
            if (eq < 1) continue
            var key = line.substring(0, eq).trim()
            var val = line.substring(eq + 1).trim()
            // Normalize: ensure # prefix for hex colors
            if (!val.startsWith("#")) val = "#" + val
            colors[key] = val
        }

        // Map M3 palette keys → quickshell palette properties
        function c(name, fallback) { return colors[name] || fallback }

        bg             = c("surface", bg)
        surface        = c("surface_container", surface)
        surfaceVariant = c("surface_variant", surfaceVariant)
        surfaceRaised  = c("surface_container_high", surfaceRaised)
        fg             = c("on_surface", fg)
        fgMuted        = c("on_surface_variant", fgMuted)
        fgDisabled     = c("on_surface_variant", fgDisabled)
        fgOnAccent     = c("on_primary", fgOnAccent)
        fgOnSurface    = c("on_surface", fgOnSurface)

        accent         = c("primary", accent)
        accentHover    = c("primary", accentHover)
        accentPressed  = c("primary", accentPressed)
        accentMuted    = c("primary", accentMuted)
        accentSurface  = c("surface_container", accentSurface)

        success        = c("tertiary", success)
        successMuted   = c("tertiary", successMuted)
        successSurface = c("surface_container", successSurface)
        warning        = c("secondary", warning)
        warningMuted   = c("secondary", warningMuted)
        warningSurface = c("surface_container", warningSurface)
        error          = c("error", error)
        errorMuted     = c("error", errorMuted)
        errorSurface   = c("error_container", errorSurface)
        info           = c("tertiary", info)
        infoMuted      = c("tertiary", infoMuted)
        infoSurface    = c("surface_container", infoSurface)

        border         = c("outline", border)
        borderStrong   = c("outline_variant", borderStrong)
        borderFocus    = c("primary", borderFocus)
        divider        = c("outline_variant", divider)

        pillBg         = c("surface_container_lowest", pillBg)
        pillFg         = c("on_surface", pillFg)
        pillBorder     = c("surface_container", pillBorder)

        inputBg        = c("surface_container", inputBg)
        inputBorder    = c("outline_variant", inputBorder)
        inputBorderFocus = c("primary", inputBorderFocus)

        toggleTrack    = c("surface_variant", toggleTrack)
        toggleActive   = c("primary", toggleActive)
        sliderTrack    = c("surface_variant", sliderTrack)
        sliderFill     = c("primary", sliderFill)

        overlay        = c("scrim", overlay)
        overlayStrong  = c("scrim", overlayStrong)
        shadow         = c("shadow", shadow)

        console.info("Dynamic: palette applied from " + _palettePath)
    }

    // ─── Runtime update from matugen (JSON) ──────────────────
    // Called by WallpaperService when matugen runs directly.
    function applyMatugen(m) {
        function c(name, fallback) {
            var entry = m.colors ? m.colors[name] : null
            if (!entry) return fallback
            var v = entry.default || entry.dark || entry.light || {}
            return v.color || fallback
        }
        bg             = c("surface", bg)
        surface        = c("surface_container", surface)
        surfaceVariant = c("surface_variant", surfaceVariant)
        surfaceRaised  = c("surface_container_high", surfaceRaised)
        fg             = c("on_surface", fg)
        fgMuted        = c("on_surface_variant", fgMuted)
        accent         = c("primary", accent)
        accentHover    = c("primary", accentHover)
        borderFocus    = c("primary", borderFocus)
        border         = c("outline", border)
        borderStrong   = c("outline_variant", borderStrong)
        divider        = c("outline_variant", divider)
        accentMuted    = accent + "25"
        accentSurface  = surface
        pillBg         = c("surface_container_lowest", pillBg)
        pillFg         = c("on_surface", pillFg)
        inputBg        = c("surface_container", inputBg)
        scrollbarHandle= c("outline", scrollbarHandle)
    }
}
