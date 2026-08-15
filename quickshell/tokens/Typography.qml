pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Font families ────────────────────────────────────────────
    readonly property QtObject families: QtObject {
        readonly property string primary:    "Inter"
        readonly property string monospace:  "JetBrains Mono"
        readonly property string icons:      "Material Symbols Rounded"
    }

    // ─── Size scale (px) ─────────────────────────────────────────
    readonly property QtObject size: QtObject {
        readonly property real xxs:   9
        readonly property real xs:    10
        readonly property real sm:    11
        readonly property real md:    12
        readonly property real base:  13
        readonly property real lg:    14
        readonly property real xl:    15
        readonly property real xxl:   16
        readonly property real xxxl:  18
        readonly property real huge:  20
        readonly property real display: 24
    }

    // ─── Weight scale ─────────────────────────────────────────────
    readonly property QtObject weight: QtObject {
        readonly property int thin:      Font.Thin          // 100
        readonly property int extraLight: Font.ExtraLight   // 200
        readonly property int light:     Font.Light         // 300
        readonly property int regular:   Font.Normal        // 400
        readonly property int medium:    Font.Medium        // 500
        readonly property int demiBold:  Font.DemiBold      // 600
        readonly property int bold:      Font.Bold          // 700
        readonly property int extraBold: Font.ExtraBold     // 800
        readonly property int black:     Font.Black         // 900
    }

    // ─── Letter spacing (px) ─────────────────────────────────────
    readonly property QtObject tracking: QtObject {
        readonly property real tight:    -0.25
        readonly property real normal:    0.0
        readonly property real wide:      0.5
        readonly property real wider:     1.0
        readonly property real widest:    1.5
    }

    // ─── Line height (multiplier) ─────────────────────────────────
    readonly property QtObject lineHeight: QtObject {
        readonly property real tight:    1.2
        readonly property real normal:   1.4
        readonly property real relaxed:  1.6
        readonly property real loose:    1.8
    }

    // ─── Composed styles ─────────────────────────────────────────
    // Each style bundles: family, size, weight, tracking, lineHeight
    // Components bind to these instead of assembling values manually.

    readonly property QtObject clock: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.lg
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject heading: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.xxl
        readonly property int weight:          root.weight.demiBold
        readonly property real tracking:       root.tracking.tight
        readonly property real lineHeight:     root.lineHeight.tight
    }

    readonly property QtObject subheading: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.lg
        readonly property int weight:          root.weight.demiBold
        readonly property real tracking:       root.tracking.tight
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject title: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.huge
        readonly property int weight:          root.weight.bold
        readonly property real tracking:       root.tracking.tight
        readonly property real lineHeight:     root.lineHeight.tight
    }

    readonly property QtObject subtitle: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.xl
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject body: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.base
        readonly property int weight:          root.weight.regular
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject bodyBold: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.base
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject caption: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.sm
        readonly property int weight:          root.weight.regular
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject captionMedium: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.sm
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject overline: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.xs
        readonly property int weight:          root.weight.demiBold
        readonly property real tracking:       root.tracking.wider
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject button: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.base
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject appLabel: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.sm
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject sliderValue: QtObject {
        readonly property string family:       families.primary
        readonly property real size:           root.size.md
        readonly property int weight:          root.weight.medium
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject mono: QtObject {
        readonly property string family:       families.monospace
        readonly property real size:           root.size.base
        readonly property int weight:          root.weight.regular
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }

    readonly property QtObject monoCaption: QtObject {
        readonly property string family:       families.monospace
        readonly property real size:           root.size.sm
        readonly property int weight:          root.weight.regular
        readonly property real tracking:       root.tracking.normal
        readonly property real lineHeight:     root.lineHeight.normal
    }
}
