pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Duration scale (ms) ──────────────────────────────────────
    readonly property QtObject duration: QtObject {
        readonly property int instant:  0
        readonly property int micro:    50
        // The shell favours the short, deliberate settle of native macOS
        // controls.  Reserve longer motion for spatial changes only.
        readonly property int fast:     150
        readonly property int medium:   240
        readonly property int slow:     360
        readonly property int glacial:  500
        readonly property int toast:    3000
    }

    // ─── Easing curves ────────────────────────────────────────────
    // These map to Qt's Easing.Type enum values.
    // Components use: easing.type = Motion.easing.standard

    readonly property QtObject easing: QtObject {
        readonly property int standard:    Easing.OutCubic
        readonly property int standardIn:  Easing.InCubic
        readonly property int decelerate:  Easing.OutQuart
        readonly property int accelerate:  Easing.InQuart
        readonly property int sharp:       Easing.OutQuint
        readonly property int symmetrical: Easing.InOutCubic
        readonly property int bounce:      Easing.OutBounce
        readonly property int elastic:     Easing.OutElastic
        readonly property int linear:      Easing.Linear
    }

    // ─── Spring configurations ────────────────────────────────────
    // For SpringAnimation — different presets for different feels.

    readonly property QtObject spring: QtObject {
        // Default: smooth, slightly overshooting
        readonly property QtObject default_: QtObject {
            readonly property real spring:   1.5
            readonly property real damping:  0.7
            readonly property real mass:     1.0
            readonly property real epsilon:  0.25
        }

        // Gentle: slow, no overshoot
        readonly property QtObject gentle: QtObject {
            readonly property real spring:   0.8
            readonly property real damping:  1.0
            readonly property real mass:     1.0
            readonly property real epsilon:  0.25
        }

        // Snappy: fast, small overshoot
        readonly property QtObject snappy: QtObject {
            readonly property real spring:   2.5
            readonly property real damping:  0.6
            readonly property real mass:     1.0
            readonly property real epsilon:  0.25
        }

        // Bouncy: playful, noticeable overshoot
        readonly property QtObject bouncy: QtObject {
            readonly property real spring:   1.2
            readonly property real damping:  0.4
            readonly property real mass:     1.0
            readonly property real epsilon:  0.25
        }

        // Stiff: very fast, minimal overshoot
        readonly property QtObject stiff: QtObject {
            readonly property real spring:   4.0
            readonly property real damping:  0.8
            readonly property real mass:     1.0
            readonly property real epsilon:  0.01
        }
    }

    // ─── Semantic animation configs ───────────────────────────────
    // Named aliases for specific use cases.
    // Components reference these instead of assembling values.

    readonly property QtObject panel: QtObject {
        // Panel expand/collapse
        readonly property int expandDuration:   duration.slow
        readonly property int collapseDuration: duration.slow
        readonly property int swapDuration:     duration.fast
        readonly property int contentFadeIn:    duration.medium
        readonly property int contentFadeOut:   duration.fast
        readonly property QtObject springConfig:     spring.default_
        readonly property int staggerDelay:          32
    }

    readonly property QtObject pill: QtObject {
        readonly property int clickScaleDuration: duration.micro
        readonly property real clickScale:        0.97
    }

    readonly property QtObject button: QtObject {
        readonly property int pressDuration:   duration.micro
        readonly property int hoverDuration:   duration.fast
        readonly property int focusDuration:   duration.medium
        readonly property real pressScale:     0.98
    }

    readonly property QtObject toggle: QtObject {
        readonly property int trackDuration:   duration.medium
        readonly property int thumbDuration:   duration.medium
        readonly property QtObject springConfig:    spring.snappy
    }

    readonly property QtObject slider: QtObject {
        readonly property int fillDuration:    duration.fast
        readonly property int handleDuration:  duration.fast
        readonly property int labelDuration:   duration.fast
    }

    readonly property QtObject listItem: QtObject {
        readonly property int hoverDuration:   duration.fast
        readonly property int pressDuration:   duration.micro
        readonly property int staggerDelay:    50   // ms per item
    }

    readonly property QtObject notification: QtObject {
        readonly property int enterDuration:   duration.slow
        readonly property int exitDuration:    duration.medium
        readonly property int autoDismiss:     duration.toast
        readonly property QtObject springConfig:    spring.gentle
    }

    readonly property QtObject theme: QtObject {
        // Full theme transition (recoloring everything)
        readonly property int crossfadeDuration: duration.glacial
    }

    readonly property QtObject window: QtObject {
        // Settings window resize/move
        readonly property int resizeDuration:  duration.slow
        readonly property QtObject springConfig:    spring.default_
    }

    readonly property QtObject scroll: QtObject {
        readonly property int flickDecel:     1500   // deceleration rate
        readonly property int overshoot:      100    // overshoot distance
    }

    // ─── Opacity values ───────────────────────────────────────────
    readonly property QtObject opacity: QtObject {
        readonly property real visible:    1.0
        readonly property real hidden:     0.0
        readonly property real disabled:   0.4
        readonly property real muted:      0.6
        readonly property real hover:      0.8
        readonly property real pressed:    0.7
        readonly property real backdrop:   0.5
        readonly property real shadow:     0.15
    }
}
