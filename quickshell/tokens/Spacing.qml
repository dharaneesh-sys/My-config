pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Base unit ────────────────────────────────────────────────
    // All spacing values are multiples of this.
    // Change this single value to rescale the entire shell spatially.
    readonly property real unit: 4.0

    // ─── Scale ────────────────────────────────────────────────────
    readonly property real none:  0
    readonly property real xxs:   unit * 0.5   // 2
    readonly property real xs:    unit * 1     // 4
    readonly property real sm:    unit * 2     // 8
    readonly property real md:    unit * 3     // 12
    readonly property real lg:    unit * 4     // 16
    readonly property real xl:    unit * 6     // 24
    readonly property real xxl:   unit * 8     // 32
    readonly property real xxxl:  unit * 12    // 48

    // ─── Semantic spacings ────────────────────────────────────────
    // Named aliases for specific use cases, derived from the scale.
    // Components reference these instead of raw scale values.

    readonly property QtObject pill: QtObject {
        readonly property real height:       lg * 3          // 48
        readonly property real width:        xl * 5 + lg     // 136 (fits HH:MM:SS)
        readonly property real paddingH:     lg              // 16
        readonly property real paddingV:     xs              // 4
    }

    readonly property QtObject panel: QtObject {
        readonly property real padding:      lg              // 16
        readonly property real gap:          md              // 12
        readonly property real sectionGap:  xl              // 24
        readonly property real headerGap:   lg              // 16
        readonly property real minWidth:    xl * 10 + lg    // 256 — cosmetic min
        readonly property real maxWidth:    xl * 17 + md    // 420
        readonly property real maxHeight:   xxxl + xxl * 3  // 144 — will be screen-relative
        readonly property real cornerSize:  lg              // 16
    }

    readonly property QtObject card: QtObject {
        readonly property real padding:      md              // 12
        readonly property real gap:          sm              // 8
        readonly property real minWidth:     xl              // 24
    }

    readonly property QtObject listItem: QtObject {
        readonly property real height:       xl * 2          // 48
        readonly property real paddingH:     md              // 12
        readonly property real gap:          sm              // 8
        readonly property real iconSize:     lg              // 16
    }

    readonly property QtObject button: QtObject {
        readonly property real height:       lg * 2          // 32
        readonly property real paddingH:     md              // 12
        readonly property real gap:          sm              // 8
        readonly property real iconSize:     lg              // 16
    }

    readonly property QtObject toggle: QtObject {
        readonly property real height:       lg + xs         // 20
        readonly property real width:        xl * 2          // 48
        readonly property real thumbSize:    lg              // 16
        readonly property real trackGap:     xxs             // 2
    }

    readonly property QtObject slider: QtObject {
        readonly property real height:       lg + xs         // 20
        readonly property real trackHeight:  xs              // 4
        readonly property real handleSize:   lg              // 16
        readonly property real labelGap:     sm              // 8
    }

    readonly property QtObject input: QtObject {
        readonly property real height:       lg * 2 + xs     // 36
        readonly property real paddingH:     md              // 12
        readonly property real iconGap:      sm              // 8
    }

    readonly property QtObject icon: QtObject {
        readonly property real tiny:         xs * 3          // 12
        readonly property real small:        lg              // 16
        readonly property real medium:       lg + xs         // 20
        readonly property real large:        xl              // 24
        readonly property real huge:         xxl             // 32
    }

    readonly property QtObject quickTile: QtObject {
        readonly property real size:         xl * 2 + lg     // 64
        readonly property real iconSize:     lg + xs         // 20
        readonly property real gap:          xs              // 4
    }

    readonly property QtObject notification: QtObject {
        readonly property real padding:      md              // 12
        readonly property real gap:          sm              // 8
        readonly property real iconSize:     lg + xs         // 20
        readonly property real maxHeight:    xl * 3          // 72
    }

    readonly property QtObject scrollbar: QtObject {
        readonly property real width:        xs              // 4
        readonly property real padding:      xxs             // 2
        readonly property real minHandle:    lg              // 16
    }

    readonly property QtObject settings: QtObject {
        readonly property real sidebarWidth: xl * 7          // 168
        readonly property real minWindowW:   xl * 14         // 336
        readonly property real minWindowH:   xl * 12         // 288
        readonly property real defaultW:     xl * 34         // 816
        readonly property real defaultH:     xl * 22         // 528
        readonly property real padding:      lg              // 16
        readonly property real pageGap:      lg              // 16
    }
}
