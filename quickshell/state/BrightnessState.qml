pragma Singleton
import QtQuick

QtObject {
    id: brightnessState

    // ═══════════════════════════════════════════════════════════════
    //  BrightnessState
    //
    //  Reactive brightness properties. Written by BrightnessService.
    // ═══════════════════════════════════════════════════════════════

    // ── Screen brightness ──────────────────────────────────────────
    property real brightness: 0.0      // 0.0 – 1.0
    property real maxBrightness: 1.0

    // ── Keyboard backlight ─────────────────────────────────────────
    property real kbdBrightness: 0.0
    property real kbdMaxBrightness: 1.0

    // ── Actions ────────────────────────────────────────────────────
    signal setBrightnessRequested(real value)
    signal setKbdBrightnessRequested(real value)
}
