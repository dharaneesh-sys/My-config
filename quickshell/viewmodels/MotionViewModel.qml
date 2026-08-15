import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  MotionViewModel
    //
    //  Presentation adapter for the Motion settings page.
    //  Reads SettingsStore for animation/spring/duration values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Animations ─────────────────────────────────────────────────
    readonly property bool animationsEnabled: SettingsStore.animationsEnabled
    readonly property real animationSpeed: SettingsStore.animationSpeed
    readonly property string animationSpeedText: SettingsStore.animationSpeed.toFixed(1) + "×"

    // ── Spring ────────────────────────────────────────────────────
    readonly property real springDamping: SettingsStore.springDamping
    readonly property string springDampingText: SettingsStore.springDamping.toFixed(2)

    readonly property real springStiffness: SettingsStore.springStiffness
    readonly property string springStiffnessText: SettingsStore.springStiffness.toFixed(1)

    // ── Durations ─────────────────────────────────────────────────
    readonly property int expandDuration: SettingsStore.expandDuration
    readonly property string expandDurationText: SettingsStore.expandDuration + "ms"

    readonly property int collapseDuration: SettingsStore.collapseDuration
    readonly property string collapseDurationText: SettingsStore.collapseDuration + "ms"

    // ── Presets ───────────────────────────────────────────────────
    readonly property var presets: [
        {
            label: "Instant",
            springDamping: 1.0,
            springStiffness: 4.0,
            expandDuration: 120,
            collapseDuration: 100
        },
        {
            label: "Snappy",
            springDamping: 0.6,
            springStiffness: 2.5,
            expandDuration: 200,
            collapseDuration: 200
        },
        {
            label: "Default",
            springDamping: 0.7,
            springStiffness: 1.5,
            expandDuration: 300,
            collapseDuration: 300
        },
        {
            label: "Polished",
            springDamping: 0.85,
            springStiffness: 2.0,
            expandDuration: 260,
            collapseDuration: 220
        },
        {
            label: "Gentle",
            springDamping: 1.0,
            springStiffness: 0.8,
            expandDuration: 500,
            collapseDuration: 500
        },
        {
            label: "Bouncy",
            springDamping: 0.42,
            springStiffness: 1.3,
            expandDuration: 360,
            collapseDuration: 320
        },
        {
            label: "Cinematic",
            springDamping: 0.95,
            springStiffness: 0.7,
            expandDuration: 620,
            collapseDuration: 560
        }
    ]

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setAnimationsEnabled(val) { SettingsStore.animationsEnabled = val }
    function setAnimationSpeed(val)    { SettingsStore.animationSpeed = val }

    function setSpringDamping(val)     { SettingsStore.springDamping = val }
    function setSpringStiffness(val)   { SettingsStore.springStiffness = val }

    function setExpandDuration(val)    { SettingsStore.expandDuration = Math.round(val) }
    function setCollapseDuration(val)  { SettingsStore.collapseDuration = Math.round(val) }

    function applyPreset(preset) {
        SettingsStore.springDamping = preset.springDamping
        SettingsStore.springStiffness = preset.springStiffness
        SettingsStore.expandDuration = preset.expandDuration
        SettingsStore.collapseDuration = preset.collapseDuration
    }
}
