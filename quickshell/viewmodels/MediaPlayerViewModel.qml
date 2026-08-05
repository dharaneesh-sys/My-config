import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  MediaPlayerViewModel
    //
    //  Presentation adapter for the MediaPlayer panel.
    //  Reads MediaState, formats presentation data.
    //
    //  • Reads:  MediaState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Header ─────────────────────────────────────────────────────
    readonly property string headerTitle: MediaState.playerName || "Media"
    readonly property string headerSubtitle: MediaState.playing ? "Playing" : "Paused"

    // ── Now playing ────────────────────────────────────────────────
    readonly property bool hasMedia: MediaState.title !== ""
    readonly property string title: MediaState.title
    readonly property string artist: MediaState.artist
    readonly property url artwork: MediaState.artwork
    readonly property bool playing: MediaState.playing

    // ── Progress ───────────────────────────────────────────────────
    readonly property bool hasProgress: MediaState.length > 0
    readonly property real position: MediaState.position
    readonly property real length: MediaState.length
    readonly property string progressText: _formatTime(MediaState.position)
                                        + " / "
                                        + _formatTime(MediaState.length)

    // ── Shuffle & repeat ───────────────────────────────────────────
    readonly property bool shuffleOn: MediaState.shuffle === "on"
    readonly property bool repeatActive: MediaState.repeat !== "off"

    readonly property string nextShuffle: MediaState.shuffle === "on" ? "off" : "on"

    readonly property string nextRepeat: MediaState.repeat === "off" ? "track"
                                       : MediaState.repeat === "track" ? "playlist"
                                       : "off"

    // ── Players (ListModel, reconciled in place) ───────────────────
    // MediaService wholesale-reassigns MediaState.players on every poll.
    // See WiFiViewModel for the reconcile rationale.
    property ListModel playersModel: ListModel {}

    function _formatEntry(p) {
        return {
            name: p.name || "",
            subtitle: p.playing ? "Playing" : ""
        }
    }

    function _syncPlayers() {
        var raw = MediaState.players
        var m = vm.playersModel

        // 1) Remove rows whose key is no longer in the raw data
        for (var i = m.count - 1; i >= 0; i--) {
            var key = m.get(i).name
            var found = false
            for (var j = 0; j < raw.length; j++) {
                if (raw[j].name === key) { found = true; break }
            }
            if (!found)
                m.remove(i)
        }

        // 2) Update in place (only changed fields) or append new
        for (var k = 0; k < raw.length; k++) {
            var e = _formatEntry(raw[k])
            var idx = _findIndex(m, "name", e.name)
            if (idx === -1) {
                m.append(e)
            } else {
                var cur = m.get(idx)
                if (cur.subtitle !== e.subtitle) m.setProperty(idx, "subtitle", e.subtitle)
            }
        }
    }

    function _findIndex(model, role, key) {
        for (var i = 0; i < model.count; i++) {
            if (model.get(i)[role] === key)
                return i
        }
        return -1
    }

    readonly property bool hasMultiplePlayers: MediaState.players.length > 1

    // ── Sync on state changes ──────────────────────────────────────
    Connections {
        target: MediaState
        function onPlayersChanged() { vm._syncPlayers() }
    }

    Component.onCompleted: _syncPlayers()

    // ── Actions ────────────────────────────────────────────────────
    function playPause()     { MediaState.playPauseRequested() }
    function next()          { MediaState.nextRequested() }
    function previous()      { MediaState.previousRequested() }
    function seek(pos)       { MediaState.seekRequested(pos) }
    function toggleShuffle() { MediaState.setShuffleRequested(nextShuffle) }
    function toggleRepeat()  { MediaState.setRepeatRequested(nextRepeat) }
    function selectPlayer(name) { MediaState.setActivePlayerRequested(name) }

    // ── Formatting ─────────────────────────────────────────────────
    function _formatTime(secs) {
        if (secs <= 0) return "0:00"
        var m = Math.floor(secs / 60)
        var s = Math.floor(secs % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }
}
