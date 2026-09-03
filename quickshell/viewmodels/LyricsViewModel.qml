import QtQuick

import qs.state
import qs.settings

QtObject {
    id: vm

    // ── Header ─────────────────────────────────────────────────────
    readonly property string headerTitle: {
        if (!MediaState.title) return "Lyrics"
        if (MediaState.isVideo) return "Lyrics — Video (no lyrics)"
        return "Lyrics — " + MediaState.title
    }
    readonly property string headerSubtitle: {
        if (MediaState.isVideo) return "Video detected — lyrics hidden"
        if (!LyricsState.isEnabled) return "Lyrics disabled in settings"
        if (LyricsState.isInstrumental) return "Instrumental"
        if (!LyricsState.hasLyrics) return "No lyrics found"
        return MediaState.artist + (MediaState.album ? " • " + MediaState.album : "")
    }

    // ── State ──────────────────────────────────────────────────────
    readonly property bool isVideo: MediaState.isVideo
    readonly property bool isEnabled: LyricsState.isEnabled
    readonly property bool hasLyrics: LyricsState.hasLyrics
    readonly property bool hasSynced: LyricsState.hasSynced
    readonly property bool isInstrumental: LyricsState.isInstrumental
    readonly property var lyricsLines: LyricsState.lyricsLines
    readonly property string plainLyrics: LyricsState.plainLyrics
    readonly property var candidates: LyricsState.candidates
    readonly property int currentLine: LyricsState.currentLine
    readonly property double syncOffset: LyricsState.syncOffset
    readonly property bool canShowSelection: LyricsState.candidates && LyricsState.candidates.length > 1
    readonly property string playerName: MediaState.playerName
    readonly property string trackTitle: MediaState.title
    readonly property string trackArtist: MediaState.artist

    // ── Settings (toggle in MediaPage) ─────────────────────────────
    readonly property bool showLyrics: SettingsStore.mediaShowLyrics
    readonly property bool autoSync: SettingsStore.mediaLyricsAutoSync

    // ── Actions ────────────────────────────────────────────────────
    function selectCandidate(index) { LyricsState.selectCandidate(index) }
    function adjustOffset(delta) { LyricsState.adjustOffset(delta) }
    function resetOffset() { LyricsState.syncOffset = 0; LyricsState.parseLrc(LyricsState._originalSynced, LyricsState._originalPlain); LyricsState.updateCurrentLine() }
    function refresh() {
        // Force refetch by clearing lastKey and re-triggering
        // Use a dummy change: set same title/artist will be ignored, so we directly call service
        // For now, just clear and re-fetch via state helper
        LyricsState._lastKey = ""
        LyricsState._maybeFetch()
    }
    function setShowLyrics(v) { SettingsStore.mediaShowLyrics = v }
    function setAutoSync(v) { SettingsStore.mediaLyricsAutoSync = v }
    function seekToLine(index) {
        if (!hasSynced || index < 0 || index >= lyricsLines.length) return
        var t = lyricsLines[index].time
        MediaState.seekRequested(t)
    }
}
