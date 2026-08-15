pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Base unit ────────────────────────────────────────────────
    readonly property real unit: 4.0

    // ─── Scale ────────────────────────────────────────────────────
    readonly property real none:  0
    readonly property real xxs:   unit * 1     // 4
    readonly property real xs:    unit * 1.5   // 6
    readonly property real sm:    unit * 2     // 8
    readonly property real md:    unit * 3     // 12
    readonly property real lg:    unit * 4     // 16
    readonly property real xl:    unit * 5     // 20
    readonly property real xxl:   unit * 6     // 24
    // Fully-rounded sentinel value — use where a rectangle should be
    // circular/capsule-shaped. Kept as a named constant so the
    // semantic QtObject `pill` below doesn't need a magic number.
    readonly property real _fullyRounded: 9999

    // ─── Semantic radii ───────────────────────────────────────────
    // Named aliases for specific use cases, derived from the scale.
    // Components reference these instead of raw scale values.

    readonly property QtObject pill: QtObject {
        readonly property real background: _fullyRounded
        readonly property real border:     _fullyRounded
    }

    readonly property QtObject panel: QtObject {
        readonly property real background: lg         // 16
        readonly property real border:     lg         // 16
        readonly property real inner:      md         // 12
    }

    readonly property QtObject card: QtObject {
        readonly property real background: md         // 12
        readonly property real border:     md         // 12
    }

    readonly property QtObject listItem: QtObject {
        readonly property real background: sm         // 8
        readonly property real border:     sm         // 8
    }

    readonly property QtObject button: QtObject {
        readonly property real background: sm         // 8
        readonly property real border:     sm         // 8
    }

    readonly property QtObject iconButton: QtObject {
        readonly property real background: xs         // 6
        readonly property real border:     xs         // 6
    }

    readonly property QtObject toggle: QtObject {
        readonly property real track:      _fullyRounded
        readonly property real thumb:      _fullyRounded
    }

    readonly property QtObject input: QtObject {
        readonly property real background: sm         // 8
        readonly property real border:     sm         // 8
    }

    readonly property QtObject quickTile: QtObject {
        readonly property real background: md         // 12
        readonly property real border:     md         // 12
    }

    readonly property QtObject notification: QtObject {
        readonly property real background: md         // 12
        readonly property real border:     md         // 12
    }

    readonly property QtObject tooltip: QtObject {
        readonly property real background: xs         // 6
        readonly property real border:     xs         // 6
    }

    readonly property QtObject settings: QtObject {
        readonly property real window:     lg         // 16
        readonly property real sidebar:    none       // 0
        readonly property real page:       none       // 0
    }

    readonly property QtObject scrollbar: QtObject {
        readonly property real track:      _fullyRounded
        readonly property real handle:     _fullyRounded
    }
}
