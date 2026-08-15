pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Shadow elevation levels ──────────────────────────────────
    // Modeled after Material Design elevation adapted for dark surfaces.
    // Each level defines shadow properties for use with layer.effect: DropShadow

    readonly property QtObject level0: QtObject {
        readonly property real offsetY:      0
        readonly property real offsetX:      0
        readonly property real blurRadius:   0
        readonly property real spread:       0
        readonly property real opacity:      0
        readonly property color color:       "#000000"
    }

    readonly property QtObject level1: QtObject {
        readonly property real offsetY:      2
        readonly property real offsetX:      0
        readonly property real blurRadius:   6
        readonly property real spread:       0
        readonly property real opacity:      0.08
        readonly property color color:       "#000000"
    }

    readonly property QtObject level2: QtObject {
        readonly property real offsetY:      4
        readonly property real offsetX:      0
        readonly property real blurRadius:   12
        readonly property real spread:       0
        readonly property real opacity:      0.12
        readonly property color color:       "#000000"
    }

    readonly property QtObject level3: QtObject {
        readonly property real offsetY:      8
        readonly property real offsetX:      0
        readonly property real blurRadius:   20
        readonly property real spread:       0
        readonly property real opacity:      0.16
        readonly property color color:       "#000000"
    }

    readonly property QtObject level4: QtObject {
        readonly property real offsetY:      12
        readonly property real offsetX:      0
        readonly property real blurRadius:   28
        readonly property real spread:       0
        readonly property real opacity:      0.20
        readonly property color color:       "#000000"
    }

    // ─── Level lookup ─────────────────────────────────────────────
    // Use: Elevation.levels[2] to get level2 programmatically
    readonly property var levels: [level0, level1, level2, level3, level4]

    // ─── Semantic elevation assignments ───────────────────────────
    // Named aliases for specific shell elements.

    readonly property QtObject pill: QtObject {
        readonly property QtObject shadow: level1
        readonly property real borderWidth:       1
    }

    readonly property QtObject panel: QtObject {
        readonly property QtObject shadow: level3
        readonly property real borderWidth:       1
    }

    readonly property QtObject card: QtObject {
        readonly property QtObject shadow: level1
        readonly property real borderWidth:       1
    }

    readonly property QtObject listItem: QtObject {
        readonly property QtObject shadow: level0
        readonly property real borderWidth:       0
    }

    readonly property QtObject button: QtObject {
        readonly property QtObject shadow: level0
        readonly property real borderWidth:       1
    }

    readonly property QtObject quickTile: QtObject {
        readonly property QtObject shadow: level0
        readonly property real borderWidth:       1
    }

    readonly property QtObject notification: QtObject {
        readonly property QtObject shadow: level2
        readonly property real borderWidth:       1
    }

    readonly property QtObject settings: QtObject {
        readonly property QtObject shadow: level4
        readonly property real borderWidth:       1
    }

    // ─── Background blur ──────────────────────────────────────────
    // For Hyprland window rules and Qt layer effects.

    readonly property QtObject blur: QtObject {
        // Shell panels — subtle blur
        readonly property real shellRadius:       12
        readonly property real shellOpacity:      0.85

        // Settings window — stronger blur
        readonly property real settingsRadius:    20
        readonly property real settingsOpacity:   0.90

        // Dialogs/modals — medium blur
        readonly property real dialogRadius:      16
        readonly property real dialogOpacity:     0.88

        // Tooltip — light blur
        readonly property real tooltipRadius:     8
        readonly property real tooltipOpacity:    0.92
    }

    // ─── Overlay opacity ──────────────────────────────────────────
    // For dimming the background behind modals/expansions.

    readonly property QtObject overlay: QtObject {
        readonly property real light:     0.30
        readonly property real medium:    0.50
        readonly property real heavy:    0.70
        readonly property real maximum:  0.85
    }

    // ─── Z-ordering ───────────────────────────────────────────────
    // Explicit stacking order constants for z properties.
    // Prevents z-index conflicts across components.

    readonly property QtObject z: QtObject {
        readonly property real base:          0
        readonly property real pill:          10
        readonly property real expandedPanel: 20
        readonly property real overlay:       30
        readonly property real settings:      40
        readonly property real tooltip:       50
        readonly property real notification:  60
    }
}
