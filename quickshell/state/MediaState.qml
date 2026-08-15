pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

QtObject {
    id: mediaState

    // ═══════════════════════════════════════════════════════════════
    //  MediaState
    //
    //  Reactive media player properties bound directly to the native
    //  Mpris service. No playerctl subprocesses, no poll timer.
    //
    //  Positions are microseconds natively (MPRIS spec) — exposed to the
    //  rest of the shell in seconds, matching the previous contract.
    // ═══════════════════════════════════════════════════════════════

    // ── Native players model ───────────────────────────────────────
    readonly property var playersModel: Mpris.players

    // ── Active player selection ────────────────────────────────────
    // Prefer the explicitly chosen player, then the first playing one,
    // then the first in the list.
    property string preferredPlayerName: ""

    function _pickActivePlayer() {
        var vals = mediaState.playersModel.values
        if (vals.length === 0)
            return null
        if (mediaState.preferredPlayerName !== "") {
            for (var i = 0; i < vals.length; i++) {
                if (vals[i].identity === mediaState.preferredPlayerName)
                    return vals[i]
            }
        }
        for (var j = 0; j < vals.length; j++) {
            if (vals[j].isPlaying)
                return vals[j]
        }
        return vals[0]
    }

    property var _active: _pickActivePlayer()

    // ── Active player ──────────────────────────────────────────────
    readonly property string playerName: _active ? _active.identity : ""
    readonly property string title: _active ? _active.trackTitle : ""
    readonly property string artist: _active ? _active.trackArtist : ""
    readonly property string album: _active ? _active.trackAlbum : ""
    readonly property url artwork: _active && _active.trackArtUrl ? _active.trackArtUrl : ""

    // ── Playback (seconds) ─────────────────────────────────────────
    readonly property bool playing: _active ? _active.isPlaying : false
    readonly property real position: _active ? _active.position / 1000000 : 0.0
    readonly property real length: _active ? _active.length / 1000000 : 0.0
    readonly property string shuffle: _active ? (_active.shuffle ? "on" : "off") : "off"
    readonly property string repeat: _active ? _loopName(_active.loopState) : "off"

    function _loopName(s) {
        if (s === MprisLoopState.Track) return "track"
        if (s === MprisLoopState.Playlist) return "playlist"
        return "off"
    }

    // ── Available players: [{name, title, artist, playing}] ────────
    // Rebuilt from the model; players object properties change without
    // the model signalling, so a light timer reconciles the array.
    property var players: _collectPlayers()

    function _collectPlayers() {
        var vals = mediaState.playersModel.values
        var out = []
        for (var i = 0; i < vals.length; i++) {
            out.push({
                name: vals[i].identity || "",
                title: vals[i].trackTitle || "",
                artist: vals[i].trackArtist || "",
                playing: vals[i].isPlaying
            })
        }
        return out
    }

    // ── Actions (kept as signals for API compatibility) ────────────
    signal playPauseRequested()
    signal nextRequested()
    signal previousRequested()
    signal seekRequested(real position)
    signal setShuffleRequested(string mode)
    signal setRepeatRequested(string mode)
    signal setActivePlayerRequested(string name)

    property Connections _actions: Connections {
        target: mediaState
        function onPlayPauseRequested() {
            var p = mediaState._active
            if (p) p.togglePlaying()
        }
        function onNextRequested() {
            var p = mediaState._active
            if (p && p.canGoNext) p.next()
        }
        function onPreviousRequested() {
            var p = mediaState._active
            if (p && p.canGoPrevious) p.previous()
        }
        function onSeekRequested(pos) {
            var p = mediaState._active
            if (p && p.canSeek) p.position = pos * 1000000
        }
        function onSetShuffleRequested(mode) {
            var p = mediaState._active
            if (p) p.shuffle = (mode === "on")
        }
        function onSetRepeatRequested(mode) {
            var p = mediaState._active
            if (!p) return
            if (mode === "track") p.loopState = MprisLoopState.Track
            else if (mode === "playlist") p.loopState = MprisLoopState.Playlist
            else p.loopState = MprisLoopState.None
        }
        function onSetActivePlayerRequested(name) {
            mediaState.preferredPlayerName = name
        }
    }

    // ── Reconcile the player list ──────────────────────────────────
    // No subprocess: reads the in-process Mpris model only. Cheap
    // enough to run every 2s, and fires immediately on model changes.
    property Timer _playersTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: mediaState.players = mediaState._collectPlayers()
    }

    property Connections _modelConn: Connections {
        target: mediaState.playersModel
        function onValuesChanged() { mediaState.players = mediaState._collectPlayers() }
    }
}
