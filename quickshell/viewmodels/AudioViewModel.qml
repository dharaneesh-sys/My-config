import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  AudioViewModel
    //
    //  Presentation adapter for the Audio panel.
    //  Reads AudioState, formats presentation data.
    //
    //  • Reads:  AudioState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Output ─────────────────────────────────────────────────────
    readonly property string outputIcon: AudioState.muted ? "volume_off" : "volume_up"
    readonly property real outputVolume: AudioState.volume
    readonly property string outputVolumeText: Math.round(AudioState.volume * 100) + "%"
    readonly property bool outputMuted: AudioState.muted

    // ── Device ─────────────────────────────────────────────────────
    readonly property string deviceName: AudioState.deviceName
    readonly property bool hasDevice: AudioState.deviceName !== ""

    // ── Input ──────────────────────────────────────────────────────
    readonly property string inputIcon: AudioState.sourceMuted ? "mic_off" : "mic"
    readonly property real inputVolume: AudioState.sourceVolume
    readonly property string inputVolumeText: Math.round(AudioState.sourceVolume * 100) + "%"
    readonly property bool inputMuted: AudioState.sourceMuted

    // ── Actions ────────────────────────────────────────────────────
    function setVolume(vol)       { AudioState.setVolumeRequested(vol) }
    function toggleMute()         { AudioState.setMutedRequested(!AudioState.muted) }
    function setSourceVolume(vol) { AudioState.setSourceVolumeRequested(vol) }
    function toggleSourceMute()   { AudioState.setSourceMutedRequested(!AudioState.sourceMuted) }
}
