pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Named theme enum ─────────────────────────────────────────
    // Every palette directory entry becomes a value here.
    enum Theme {
        Ariadne,
        CatppuccinMacchiato,
        CatppuccinMocha,
        Dracula,
        Dynamic,
        Everforest,
        Gruvbox,
        Nightfox,
        Noir,
        Nord,
        RosePine,
        SolarizedDark,
        TokyoNight
    }

    // ─── Active theme ─────────────────────────────────────────────
    property int theme: Colors.Theme.TokyoNight

    // ─── Theme switching ──────────────────────────────────────────
    // Accepts either an enum int (Colors.Theme.Gruvbox) or a lowercase
    // string key ("gruvbox", "catppuccin-mocha", …). Setting the theme
    // re-resolves _active and cascades to every color role binding.
    function setTheme(keyOrValue) {
        if (typeof keyOrValue === "string") {
            var pal = paletteForKey(keyOrValue)
            if (pal === null) {
                console.warn("Colors: unknown theme key \"" + keyOrValue + "\"")
                return
            }
            // Resolve the enum value that owns this palette.
            for (var k in _registry) {
                if (_registry[k].palette === pal) {
                    theme = parseInt(k, 10)
                    return
                }
            }
            return
        }
        theme = keyOrValue
    }

    // ─── Theme registry ───────────────────────────────────────────
    // Maps enum values to palette singletons and metadata.
    readonly property var _registry: ({
        [Colors.Theme.Ariadne]:           { palette: Ariadne,           key: "ariadne" },
        [Colors.Theme.CatppuccinMacchiato]: { palette: CatppuccinMacchiato, key: "catppuccin-macchiato" },
        [Colors.Theme.CatppuccinMocha]:   { palette: CatppuccinMocha,   key: "catppuccin-mocha" },
        [Colors.Theme.Dracula]:           { palette: Dracula,           key: "dracula" },
        [Colors.Theme.Dynamic]:           { palette: Dynamic,           key: "dynamic" },
        [Colors.Theme.Everforest]:        { palette: Everforest,        key: "everforest" },
        [Colors.Theme.Gruvbox]:           { palette: Gruvbox,           key: "gruvbox" },
        [Colors.Theme.Nightfox]:          { palette: Nightfox,          key: "nightfox" },
        [Colors.Theme.Noir]:              { palette: Noir,              key: "noir" },
        [Colors.Theme.Nord]:              { palette: Nord,              key: "nord" },
        [Colors.Theme.RosePine]:          { palette: RosePine,          key: "rose-pine" },
        [Colors.Theme.SolarizedDark]:     { palette: SolarizedDark,     key: "solarized-dark" },
        [Colors.Theme.TokyoNight]:        { palette: TokyoNight,        key: "tokyo-night" }
    })

    // ─── Active palette resolver ──────────────────────────────────
    readonly property QtObject _active: _registry[theme].palette

    // ─── Palette lookup by key ────────────────────────────────────
    // Returns the palette singleton for a lowercase theme key
    // ("gruvbox", "catppuccin-mocha", …) or null if unknown.
    // Used by ThemeSwitcher/Appearance viewmodels to preview each
    // theme's real colors (bg/surface/accent) in cards.
    function paletteForKey(key) {
        if (typeof key !== "string") return null
        for (var k in _registry) {
            if (_registry[k].key === key)
                return _registry[k].palette
        }
        return null
    }

    // ─── Derived metadata ─────────────────────────────────────────
    readonly property bool isDark:     _active.isDark
    readonly property bool isLight:    !_active.isDark
    readonly property string key:      _registry[theme].key
    readonly property string name:     _active.name
    readonly property string label:    _active.label

    // ─── Theme list (for Settings UI) ─────────────────────────────
    readonly property var availableThemes: [
        { value: Colors.Theme.Ariadne,           key: "ariadne",            label: "Ariadne" },
        { value: Colors.Theme.CatppuccinMacchiato, key: "catppuccin-macchiato", label: "Catppuccin Macchiato" },
        { value: Colors.Theme.CatppuccinMocha,   key: "catppuccin-mocha",   label: "Catppuccin Mocha" },
        { value: Colors.Theme.Dracula,           key: "dracula",            label: "Dracula" },
        { value: Colors.Theme.Dynamic,           key: "dynamic",            label: "Dynamic" },
        { value: Colors.Theme.Everforest,        key: "everforest",         label: "Everforest" },
        { value: Colors.Theme.Gruvbox,           key: "gruvbox",            label: "Gruvbox" },
        { value: Colors.Theme.Nightfox,          key: "nightfox",           label: "Nightfox" },
        { value: Colors.Theme.Noir,              key: "noir",               label: "Noir" },
        { value: Colors.Theme.Nord,              key: "nord",               label: "Nord" },
        { value: Colors.Theme.RosePine,          key: "rose-pine",          label: "Rosé Pine" },
        { value: Colors.Theme.SolarizedDark,     key: "solarized-dark",     label: "Solarized Dark" },
        { value: Colors.Theme.TokyoNight,        key: "tokyo-night",        label: "Tokyo Night" }
    ]

    // ═══════════════════════════════════════════════════════════════
    //  PUBLIC SEMANTIC COLOR ROLES
    //  Every property delegates to _active.<same>.
    //  Components ONLY reference these — never _active directly.
    // ═══════════════════════════════════════════════════════════════

// Backgrounds
    // All background roles follow the active palette so the shell fully
    // matches the applied system theme (current_theme → ThemeService).
    // Hover/press affordance stays theme-consistent because
    // surfaceVariant/surfaceRaised come from the same palette.
    readonly property color bg:             _active.bg
    readonly property color surface:        _active.surface
    readonly property color surfaceVariant: _active.surfaceVariant
    readonly property color surfaceRaised:  _active.surfaceRaised

    // Foregrounds
    readonly property color fg:             _active.fg
    readonly property color fgMuted:        _active.fgMuted
    readonly property color fgDisabled:     _active.fgDisabled
    readonly property color fgOnAccent:     _active.fgOnAccent
    readonly property color fgOnSurface:    _active.fgOnSurface
    readonly property color fgOnWarning:    _active.fgOnWarning

    // Accent
    readonly property color accent:         _active.accent
    readonly property color accentHover:    _active.accentHover
    readonly property color accentPressed:  _active.accentPressed
    readonly property color accentMuted:    _active.accentMuted
    readonly property color accentSurface:  _active.accentSurface

    // Semantic
    readonly property color success:        _active.success
    readonly property color successMuted:   _active.successMuted
    readonly property color successSurface: _active.successSurface
    readonly property color warning:        _active.warning
    readonly property color warningMuted:   _active.warningMuted
    readonly property color warningSurface: _active.warningSurface
    readonly property color error:          _active.error
    readonly property color errorMuted:     _active.errorMuted
    readonly property color errorSurface:   _active.errorSurface
    readonly property color info:           _active.info
    readonly property color infoMuted:      _active.infoMuted
    readonly property color infoSurface:    _active.infoSurface

    // Borders & dividers
    readonly property color border:         _active.border
    readonly property color borderStrong:   _active.borderStrong
    readonly property color borderFocus:    _active.borderFocus
    readonly property color divider:        _active.divider

    // Pill — background follows the active theme like the panels;
    // foreground/border stay theme-driven.
    readonly property color pillBg:         _active.pillBg
    readonly property color pillFg:         _active.pillFg
    readonly property color pillBorder:     _active.pillBorder

    // Interactive
    readonly property color hoverOverlay:   _active.hoverOverlay
    readonly property color pressedOverlay: _active.pressedOverlay
    readonly property color selectedBg:     _active.selectedBg
    readonly property color toggleTrack:    _active.toggleTrack
    readonly property color toggleActive:   _active.toggleActive
    readonly property color sliderTrack:    _active.sliderTrack
    readonly property color sliderFill:     _active.sliderFill
    readonly property color inputBg:        _active.inputBg
    readonly property color inputBorder:    _active.inputBorder
    readonly property color inputBorderFocus: _active.inputBorderFocus

    // Scrollbar
    readonly property color scrollbarTrack:      _active.scrollbarTrack
    readonly property color scrollbarHandle:     _active.scrollbarHandle
    readonly property color scrollbarHandleHover: _active.scrollbarHandleHover

    // Overlay
    readonly property color overlay:        _active.overlay
    readonly property color overlayStrong:  _active.overlayStrong

    // Shadow
    readonly property color shadow:         _active.shadow
}
