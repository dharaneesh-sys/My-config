pragma Singleton
import QtQuick
import Quickshell.Services.Pipewire

QtObject {
    id: audioState

    // ═══════════════════════════════════════════════════════════════
    //  AudioState
    //
    //  Reactive audio properties bound directly to the native Pipewire
    //  service (Quickshell 0.3.0). No pactl subprocesses, no poll timer.
    //
    //  Volume/mute live on the default sink/source node's PwNodeAudio
    //  iface. A PwObjectTracker keeps each node bound so the iface stays
    //  valid across node churn.
    // ═══════════════════════════════════════════════════════════════

    // ── Native node bindings ───────────────────────────────────────
    // PwNodeIface is not QML-exported as a creatable type name, so we
    // hold the node references as var. The underlying objects expose
    // .name / .audio (PwNodeAudio) at runtime.
    property var sink: Pipewire.defaultAudioSink
    property var source: Pipewire.defaultAudioSource

    property PwObjectTracker _sinkTracker: PwObjectTracker {
        objects: audioState.sink ? [audioState.sink] : []
    }
    property PwObjectTracker _sourceTracker: PwObjectTracker {
        objects: audioState.source ? [audioState.source] : []
    }

    // ── Volume (0.0 – 1.0) ─────────────────────────────────────────
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0.0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property string deviceName: sink ? sink.name : ""
    property var devices: []

    // ── Source (microphone) ────────────────────────────────────────
    readonly property real sourceVolume: source && source.audio ? source.audio.volume : 0.0
    readonly property bool sourceMuted: source && source.audio ? source.audio.muted : false

    // ── Actions (kept as signals for API compatibility) ────────────
    signal setVolumeRequested(real volume)
    signal setMutedRequested(bool muted)
    signal setSourceVolumeRequested(real volume)
    signal setSourceMutedRequested(bool muted)

    property Connections _actions: Connections {
        target: audioState
        function onSetVolumeRequested(v) {
            var s = audioState.sink
            if (s && s.audio)
                s.audio.volume = Math.max(0, Math.min(1, v))
        }
        function onSetMutedRequested(m) {
            var s = audioState.sink
            if (s && s.audio)
                s.audio.muted = m
        }
        function onSetSourceVolumeRequested(v) {
            var s = audioState.source
            if (s && s.audio)
                s.audio.volume = Math.max(0, Math.min(1, v))
        }
        function onSetSourceMutedRequested(m) {
            var s = audioState.source
            if (s && s.audio)
                s.audio.muted = m
        }
    }
}
