import QtQuick

// Everforest dynamic theme — dark | light palette
// darkMode=false → light variant (surface becomes cream, text dark)
// darkMode=true  → dark variant (current default)
QtObject {
    // ── Theme variant selector ─────────────────
    property bool darkMode: true

    // ── Dark palette (Everforest dark) ─────────
    readonly property color __darkPrimary:          "#a7c080"
    readonly property color __darkOnPrimary:        "#2d353b"
    readonly property color __darkPrimaryContainer: "#3d484d"
    readonly property color __darkTertiary:          "#7fbbb3"
    readonly property color __darkOnTertiary:       "#2d353b"
    readonly property color __darkTertiaryContainer:"#3d484d"
    readonly property color __darkSecondary:         "#d3c6aa"
    readonly property color __darkOnSecondary:       "#2d353b"
    readonly property color __darkSecondaryContainer:"#3d484d"
    readonly property color __darkSurface:           "#2d353b"
    readonly property color __darkSurfaceVariant:    "#3d484d"
    readonly property color __darkSurfaceDim:        "#1e2326"
    readonly property color __darkOnSurface:         "#d3c6aa"
    readonly property color __darkOnSurfaceVariant:  "#a6b0a0"
    readonly property color __darkOutline:           "#5f6c71"
    readonly property color __darkError:              "#e67e80"
    readonly property color __darkErrorContainer:    "#3d484d"
    readonly property color __darkSurfaceContainerHigh: "#4d5a5f"

    // ── Light palette (Everforest light) ────────
    readonly property color __lightPrimary:          "#8ca868"
    readonly property color __lightOnPrimary:        "#ffffff"
    readonly property color __lightPrimaryContainer: "#d8cfbe"
    readonly property color __lightTertiary:          "#69a89f"
    readonly property color __lightOnTertiary:       "#ffffff"
    readonly property color __lightTertiaryContainer:"#d8cfbe"
    readonly property color __lightSecondary:         "#b9b193"
    readonly property color __lightOnSecondary:       "#ffffff"
    readonly property color __lightSecondaryContainer:"#d8cfbe"
    readonly property color __lightSurface:           "#f3edd6"
    readonly property color __lightSurfaceVariant:    "#e0d8be"
    readonly property color __lightSurfaceDim:        "#e8e0c8"
    readonly property color __lightOnSurface:         "#5c5e50"
    readonly property color __lightOnSurfaceVariant:  "#94977e"
    readonly property color __lightOutline:           "#bcc0ab"
    readonly property color __lightError:              "#d56a6b"
    readonly property color __lightErrorContainer:    "#d8cfbe"
    readonly property color __lightSurfaceContainerHigh: "#cfcab4"

    // ── Active palette (selected by darkMode) ──
    property color clPrimary:          darkMode ? __darkPrimary          : __lightPrimary
    property color clOnPrimary:        darkMode ? __darkOnPrimary        : __lightOnPrimary
    property color clPrimaryContainer: darkMode ? __darkPrimaryContainer : __lightPrimaryContainer
    property color clOnPrimaryContainer: clPrimaryContainer
    property color clOnSecondaryContainer: clSecondaryContainer
    property color clOnTertiaryContainer: clTertiaryContainer
    property color clTertiary:          darkMode ? __darkTertiary          : __lightTertiary
    property color clOnTertiary:       darkMode ? __darkOnTertiary        : __lightOnTertiary
    property color clTertiaryContainer: darkMode ? __darkTertiaryContainer : __lightTertiaryContainer
    property color clSecondary:         darkMode ? __darkSecondary         : __lightSecondary
    property color clOnSecondary:       darkMode ? __darkOnSecondary       : __lightOnSecondary
    property color clSecondaryContainer: darkMode ? __darkSecondaryContainer : __lightSecondaryContainer
    property color clSurface:           darkMode ? __darkSurface           : __lightSurface
    property color clSurfaceVariant:    darkMode ? __darkSurfaceVariant    : __lightSurfaceVariant
    property color clSurfaceDim:        darkMode ? __darkSurfaceDim        : __lightSurfaceDim
    property color clOnSurface:         darkMode ? __darkOnSurface         : __lightOnSurface
    property color clOnSurfaceVariant:  darkMode ? __darkOnSurfaceVariant  : __lightOnSurfaceVariant
    property color clOutline:           darkMode ? __darkOutline           : __lightOutline
    property color clError:              darkMode ? __darkError              : __lightError
    property color clErrorContainer:    darkMode ? __darkErrorContainer    : __lightErrorContainer
    property color clSurfaceContainerHigh: darkMode ? __darkSurfaceContainerHigh : __lightSurfaceContainerHigh

    // ── Animation & effects ────────────────────
    readonly property int animDurationFast: 120
    readonly property int animDurationNorm: 220
    readonly property int animDurationSlow: 350
    readonly property real barBgOpacity: 0.55       // glassmorphism bg
    readonly property real barBgBlur: 24.0          // px blur radius
    readonly property real hoverElevation: 1.08     // scale on hover
    readonly property real pressElevation: 0.96     // scale on press

    // ── Per-widget accent groups ──────────────
    property color accentPrimary:      clPrimary
    property color onAccentPrimary:    clOnPrimary
    property color accentTertiary:     clTertiary
    property color onAccentTertiary:   clOnTertiary
    property color accentSecondary:    clSecondary
    property color onAccentSecondary:  clOnSecondary

    // ── Shorthand aliases ─────────────────────
    property color primary:            clPrimary
    property color onPrimary:          clOnPrimary
    property color primaryContainer:   clPrimaryContainer
    property color onPrimaryContainer: clOnPrimaryContainer
    property color secondaryContainer: clSecondaryContainer
    property color onSecondaryContainer: clOnSecondaryContainer
    property color tertiaryContainer:  clTertiaryContainer
    property color onTertiaryContainer: clOnTertiaryContainer
    property color tertiary:           clTertiary
    property color onTertiary:         clOnTertiary
    property color secondary:          clSecondary
    property color onSecondary:        clOnSecondary
    property color surface:            clSurface
    property color surfaceVariant:     clSurfaceVariant
    property color surfaceDim:         clSurfaceDim
    property color onSurface:          clOnSurface
    property color onSurfaceVariant:   clOnSurfaceVariant
    property color outline:            clOutline
    property color error:              clError
    property color errorContainer:     clErrorContainer
    property color surfaceContainerHigh: clSurfaceContainerHigh

    // ── Bar dimensions —───────────────────────
    readonly property int barHeight: 36
    readonly property int pillRadius: 14
    readonly property int iconSize: 16
    readonly property int spacing: 1
    readonly property string fontFamily: "Noto Sans"
    readonly property string fontJp: "Noto Sans CJK JP"
    readonly property int fontSize: 13
}
