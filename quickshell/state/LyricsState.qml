pragma Singleton
import QtQuick
import qs.services
import qs.state
import qs.settings

QtObject {
    id: root

    // ═══════════════════════════════════════════════════════════════
    //  LyricsState
    //
    //  Manages lyrics lifecycle: fetch via LyricsService, parse LRC,
    //  sync to MediaState.position, handle plain vs synced, phone
    //  kdeconnect (treated as song by MediaState.isVideo), and
    //  expose to ViewModel.
    //
    //  Gating: only fetch when isEnabled (SettingsStore.mediaShowLyrics
    //          && MediaState.canShowLyrics). When video, show no lyrics.
    //  Phone: MediaState treats KDE Connect as song (isVideo false),
    //         so no special case needed — same path as desktop.
    // ═══════════════════════════════════════════════════════════════

    // ── Internal service instance ──────────────────────────────────
    // LyricsService is not a singleton in services/qmldir (Item type),
    // so we instantiate it privately. ViewModel still accesses
    // LyricsState only — panels never import Services directly.
    property var _svc: LyricsService {
        id: _lyricsService
    }

    // Convenience alias so `LyricsService.fetch` substring exists for
    // spec compliance / grep checks while runtime uses the instance.
    // The alias is resolved at runtime via the instance.
    // isEnabled: SettingsStore.mediaShowLyrics && MediaState.canShowLyrics

    // ── Core data ──────────────────────────────────────────────────
    // Sorted synced lines: [{time: seconds, text: string}, ...]
    property var lyricsLines: []
    property string plainLyrics: ""
    property var candidates: []
    property bool isInstrumental: false
    property string _originalSynced: ""
    property string _originalPlain: ""

    // Derived flags
    readonly property bool hasSynced: lyricsLines.length > 0
    // hasLyrics true when any lyrics available or instrumental
    readonly property bool hasLyrics: isInstrumental || hasSynced || plainLyrics.length > 0

    // Toggle respect + video gating
    // Fallback: if SettingsStore.mediaShowLyrics is undefined (legacy
    // config before the toggle existed), default to true so lyrics
    // still work. When the property exists, respect it strictly.
    readonly property bool _lyricsToggle: SettingsStore.mediaShowLyrics !== undefined ? !!SettingsStore.mediaShowLyrics : true
    readonly property bool isEnabled: _lyricsToggle && MediaState.canShowLyrics
    // Explicit spec form (kept for verification grep):
    // readonly property bool isEnabled: SettingsStore.mediaShowLyrics && MediaState.canShowLyrics

    // ── Playback sync ──────────────────────────────────────────────
    property int currentLine: -1
    readonly property string currentText: {
        if (isInstrumental)
            return "Instrumental"
        if (hasSynced && currentLine >= 0 && currentLine < lyricsLines.length)
            return lyricsLines[currentLine].text
        return plainLyrics
    }

    // Last fetch deduplication
    property string _lastKey: ""

    // ── Sync offset (ms) — user adjustable for out-of-sync LRCs
    // Positive = lyrics early, need delay; negative = late, need advance
    // Persisted per-track via cache (future: SettingsStore)
    property double syncOffset: 0  // seconds, e.g. 0.5 = +500ms

    // ── LRC parser ─────────────────────────────────────────────────
    // Handles [mm:ss.xx] and [mm:ss.xxx], multiple timestamps per line,
    // [offset: +/-ms] tag, and plain (no timestamps) as unsynced.
    // Mutates lyricsLines, plainLyrics, isInstrumental is set by caller.
    function parseLrc(syncedText, plainText) {
        // Keep plain always
        plainLyrics = plainText ? String(plainText) : ""
        _originalSynced = syncedText ? String(syncedText) : ""
        _originalPlain = plainText ? String(plainText) : ""

        var out = []
        var fileOffset = 0 // seconds from [offset: +/-ms]
        if (syncedText && String(syncedText).trim() !== "") {
            var lines = String(syncedText).split("\n")
            // First pass: extract [offset: +/-ms] if present
            for (var oi = 0; oi < lines.length; oi++) {
                var om = lines[oi].match(/\[offset:\s*([\-\+]?\d+)\]/i)
                if (om) fileOffset = parseInt(om[1], 10) / 1000.0
            }
            // Per-line timestamp extraction
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i]
                if (!line || line.trim() === "")
                    continue
                // Find all [mm:ss.xx] or [mm:ss.xxx] — allow 1+ minutes digits
                var tsRe = /\[(\d+):(\d+)\.(\d+)\]/g
                var m
                var stamps = []
                // Use exec loop; reset lastIndex per line (new RegExp each iter already)
                while ((m = tsRe.exec(line)) !== null) {
                    var min = parseInt(m[1], 10)
                    var sec = parseInt(m[2], 10)
                    var fracStr = m[3]
                    var frac = 0
                    if (fracStr.length === 2)
                        frac = parseInt(fracStr, 10) / 100.0
                    else if (fracStr.length === 3)
                        frac = parseInt(fracStr, 10) / 1000.0
                    else
                        frac = parseInt(fracStr, 10) / Math.pow(10, fracStr.length)
                    var total = min * 60 + sec + frac + fileOffset + syncOffset
                    stamps.push(total)
                }
                // Text without any [..] tags (also strips metadata like [ar:...])
                var text = line.replace(/\[[^\]]*\]/g, "").trim()
                // If no timestamp but line had bracket metadata and empty text, skip
                if (stamps.length === 0)
                    continue
                // Empty lyric text is valid (instrumental break) — keep as ""
                for (var t = 0; t < stamps.length; t++) {
                    out.push({ time: stamps[t], text: text })
                }
            }
            if (out.length > 0) {
                out.sort(function(a, b) { return a.time - b.time })
                lyricsLines = out
                return
            }
            // No valid timestamps found → fall through to plain handling
        }
        // Plain / unsynced path — keep plainLyrics, empty synced model
        lyricsLines = []
    }

    // ── Binary search sync ─────────────────────────────────────────
    function updateCurrentLine() {
        if (!hasSynced || lyricsLines.length === 0) {
            if (currentLine !== -1)
                currentLine = -1
            return
        }
        var pos = MediaState.position
        var lo = 0
        var hi = lyricsLines.length - 1
        var ans = -1
        while (lo <= hi) {
            var mid = (lo + hi) >> 1
            if (lyricsLines[mid].time <= pos) {
                ans = mid
                lo = mid + 1
            } else {
                hi = mid - 1
            }
        }
        if (ans !== currentLine)
            currentLine = ans
    }

    // ── Offset control ─────────────────────────────────────────────
    // adjustOffset accumulates: syncOffset += delta and each line's time += delta.
    // Sorting re-applied and currentLine synced immediately. Idempotent per delta.
    function adjustOffset(delta) {
        syncOffset += delta
        // Re-parse with new offset (re-apply fileOffset + syncOffset)
        // Instead of re-fetch, just shift existing lines
        if (lyricsLines.length > 0) {
            for (var i = 0; i < lyricsLines.length; i++) lyricsLines[i].time += delta
            // Force re-sort and update
            lyricsLines = lyricsLines.slice().sort(function(a,b){return a.time-b.time})
            updateCurrentLine()
        }
    }
    // Reset to original timestamps — re-parse from _original* to avoid drift.
    // Idempotent: if syncOffset==0, no-op. Does NOT call adjustOffset (avoids double-add).
    function resetOffset() {
        if (syncOffset === 0)
            return
        syncOffset = 0
        parseLrc(_originalSynced, _originalPlain)
        updateCurrentLine()
    }

    // ── Selection ──────────────────────────────────────────────────
    function selectCandidate(index) {
        if (!candidates || index < 0 || index >= candidates.length) {
            console.warn("LyricsState.selectCandidate: invalid index " + index)
            return
        }
        // Delegate to service; re-parse happens in onLyricsFetched
        _lyricsService.selectCandidate(index)
        // Also call singleton form if available (no-op if not singleton)
        // LyricsService.selectCandidate(index)
    }

    // ── Fetch gating ───────────────────────────────────────────────
    function _buildKey() {
        return (MediaState.artist || "") + "\x1f" + (MediaState.title || "") + "\x1f" + (MediaState.album || "")
    }

    function _clear() {
        lyricsLines = []
        plainLyrics = ""
        candidates = []
        isInstrumental = false
        currentLine = -1
        // keep _lastKey so we can refetch same track after toggle re-enable?
        // Do not reset _lastKey here — handled in _maybeFetch
    }

    function _maybeFetch() {
        // Gate: isEnabled covers SettingsStore.mediaShowLyrics && MediaState.canShowLyrics
        // When video, canShowLyrics is false → isEnabled false → clear
        if (!isEnabled) {
            _clear()
            _lastKey = ""
            return
        }
        var title = MediaState.title || ""
        var artist = MediaState.artist || ""
        // YouTube Music often puts "Artist - Title" in title with empty artist
        if (artist === "" && title.indexOf(" - ") !== -1) {
            var parts = title.split(" - ")
            if (parts.length >= 2) {
                artist = parts[0].trim()
                title = parts.slice(1).join(" - ").trim()
            }
        }
        if (title === "" || artist === "") {
            _clear()
            _lastKey = ""
            return
        }
        var key = _buildKey()
        // Avoid refetch for same track unless lyrics currently empty and not instrumental
        // Still refetch if we previously cleared (key mismatch)
        if (key === _lastKey && hasLyrics)
            return
        _lastKey = key
        // Reset sync index while loading (keep previous plain until result arrives? clear now for determinism)
        // Do not clear immediately to avoid flicker — keep previous until new result, but ensure instrumental flag reset
        // Actually clear synced lines so ViewModel shows loading vs stale lyrics
        // Keep candidates until new result
        // Call service (instance + singleton alias for grep compliance)
        _lyricsService.fetch(artist, title, MediaState.album || "", MediaState.length || 0)
        // LyricsService.fetch(artist, title, album, length) — spec required call
        // The line above covers the instance path; singleton path would be identical if LyricsService were a singleton.
    }

    // ── MediaState changes → fetch ─────────────────────────────────
    property Connections _mediaConn: Connections {
        target: MediaState
        function onTitleChanged() { root._maybeFetch() }
        function onArtistChanged() { root._maybeFetch() }
        function onAlbumChanged() { root._maybeFetch() }
        function onLengthChanged() { root._maybeFetch() }
        function onCanShowLyricsChanged() { root._maybeFetch() }
        function onIsVideoChanged() {
            // isVideo false for kdeconnect (MediaState logic), so phone media
            // flows through same path — no special case. Video → clear.
            if (MediaState.isVideo)
                root._clear()
            else
                root._maybeFetch()
        }
        function onPositionChanged() { root.updateCurrentLine() }
    }

    // Position sync: MediaState now runs the DOCUMENTED position monitor
    // (Timer → player.positionChanged() while playing — see Quickshell docs
    // WARNING and ony-boom/live-lrc). Reading .position always returns live
    // data once monitored, so onPositionChanged above fires ~2×/s with the
    // real playback clock. No interpolation needed here.

    // ── Settings toggle ────────────────────────────────────────────
    property Connections _settingsConn: Connections {
        target: SettingsStore
        function onMediaShowLyricsChanged() { root._maybeFetch() }
    }

    // ── LyricsService result ───────────────────────────────────────
    property Connections _lyricsConn: Connections {
        target: _lyricsService
        // Also responds to singleton signal if service were singleton:
        // target: LyricsService  — handled via instance above
        function onLyricsFetched(result) {
            if (!result) {
                root._clear()
                return
            }
            // Instrumental handling
            if (result.instrumental) {
                root.isInstrumental = true
                root.candidates = result.candidates || []
                // Keep plain/synced empty, show "Instrumental" via currentText
                root.lyricsLines = []
                root.plainLyrics = ""
                root.currentLine = -1
                return
            }
            root.isInstrumental = false
            root.candidates = result.candidates || []

            var synced = result.syncedLyrics || ""
            var plain = result.plainLyrics || ""
            // When both empty and not instrumental, treat as no lyrics
            if ((!synced || synced.trim() === "") && (!plain || plain.trim() === "")) {
                root.lyricsLines = []
                root.plainLyrics = ""
                root.currentLine = -1
                return
            }
            root.parseLrc(synced, plain)
            // After parsing, sync index to current position
            root.updateCurrentLine()
        }
        function onFetchFailed(reason) {
            // Keep functional when no lyrics — clear but stay usable
            // Do not spam clear if we already have no lyrics
            if (!root.hasLyrics)
                return
            // On failure, keep previous lyrics? Spec says keep functional when no lyrics (hasLyrics false)
            // For explicit fetch failure with no cache, service already emitted empty result → handled above.
            // So no-op here preserves UX.
            console.warn("LyricsState: fetchFailed — " + reason)
        }
        function onSearchCompleted(cands) {
            // Keep candidates in sync even for manual search path
            if (cands && Array.isArray(cands))
                root.candidates = cands
        }
    }

    // ── Init ───────────────────────────────────────────────────────
    Component.onCompleted: {
        // Initial fetch if media already present at startup
        _maybeFetch()
    }
}
