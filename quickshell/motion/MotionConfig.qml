pragma Singleton
import QtQuick
import qs.settings
import qs.state

// Runtime animation-override layer (plan §B1).
// tokens/Motion.qml is FROZEN and cannot become writable, so this module is
// the sanctioned "runtime animation override layer" (KNOWN_LIMITATIONS #2).
// All non-frozen motion in the shell consumes durations and spring parameters
// from here, so SettingsStore.animationSpeed / animationsEnabled / spring*
// actually drive the animation system.
QtObject {
    // Game mode disables all quickshell animations — keep functional, drop decorative
    readonly property bool animationsEnabled: SettingsStore.animationsEnabled && !GameModeState.active

    // animationSpeed is a multiplier 0.5 - 2.0; a higher speed means SHORTER
    // durations, so scale by the inverse, clamped to keep extreme values sane.
    readonly property real speedFactor: Math.max(0.25, 1.0 / Math.max(0.25, SettingsStore.animationSpeed))

    function duration(ms) {
        return animationsEnabled ? Math.round(ms * speedFactor) : 0
    }

    readonly property QtObject spring: QtObject {
        readonly property real stiffness: SettingsStore.springStiffness
        readonly property real damping: SettingsStore.springDamping
        readonly property real mass: 1.0
        readonly property real epsilon: 0.25
    }
}
