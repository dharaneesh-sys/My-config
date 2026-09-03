import Quickshell
import QtQuick
import Quickshell.Io

Item {
    id: lyricsService

    // ═══════════════════════════════════════════════════════════════
    //  LyricsService
    //
    //  LRCLIB (https://lrclib.net) — keyless, open lyrics API.
    //    GET /api/get?artist_name=&track_name=&album_name=&duration=  (exact)
    //    GET /api/search?artist_name=&track_name=&album_name=         (array)
    //
    //  Flow: cache → /api/get (with duration) → /api/search (ranked)
    //  Candidate ranking: (1) duration ±5s (2) exact artist/title
    //                     (3) synced vs plain. Full list exposed.
    //  Cache: ~/.cache/quickshell/lyrics/<hash>.json  {plain,synced,…}
    //  Offline: returns cached entry when network unavailable.
    //  Pure service: caller passes artist/title/album/duration; no
    //  MediaState dependency.
    // ═══════════════════════════════════════════════════════════════

    readonly property string home: Quickshell.env("HOME")
    property string cacheDir: home + "/.cache/quickshell/lyrics"

    // ── Public signals ───────────────────────────────────────────
    // result = { plainLyrics, syncedLyrics, instrumental, duration,
    //            trackName, artistName, albumName, source, cached,
    //            candidates: [ ranked best→worst ] }
    signal lyricsFetched(var result)
    signal searchCompleted(var candidates)
    signal fetchFailed(string reason)

    // ── Pending request state ────────────────────────────────────
    property var _pendingCallback: null
    property string _pendingArtist: ""
    property string _pendingTitle: ""
    property string _pendingAlbum: ""
    property real _pendingDuration: 0
    property string _pendingHash: ""
    property string _pendingPath: ""
    // "cache" | "get" | "search" | "manual-search"
    property string _phase: ""

    // ── URL encoding ─────────────────────────────────────────────
    function _enc(s) {
        if (!s) return ""
        return encodeURIComponent(s)
    }

    // ── Deterministic hash for cache filename ────────────────────
    // Pure-JS FNV-1a + djb2 mix → 16 hex chars. Matches spec intent:
    // hash(artist+title+album+duration) e.g. sha256 prefix. Stable,
    // collision-resistant for the cache use-case without spawning
    // a shell process just to name the file.
    function _hashKey(artist, title, album, duration) {
        var raw = (artist || "") + "\x1f" + (title || "") + "\x1f" + (album || "") + "\x1f" + String(duration || "")
        var h1 = 2166136261  // FNV offset
        var h2 = 5381        // djb2
        for (var i = 0; i < raw.length; i++) {
            var c = raw.charCodeAt(i)
            h1 ^= c
            h1 = (h1 * 16777619) >>> 0
            h2 = (((h2 << 5) + h2) ^ c) >>> 0
        }
        function toHex(v) {
            var s = (v >>> 0).toString(16)
            while (s.length < 8) s = "0" + s
            return s
        }
        return toHex(h1) + toHex(h2)
    }

    // ── Scoring / ranking ────────────────────────────────────────
    function _scoreCandidate(c, artist, title, duration) {
        var score = 0
        var dur = c.duration || 0
        var target = duration || 0
        // Duration gate: a candidate whose length differs wildly from the
        // playing track is a DIFFERENT recording (snippet/live/remaster) —
        // its timestamps can never line up. Hard-reject instead of
        // downranking, so the syncedLyrics bonus can't rescue a 50s snippet
        // for a 191s song (the exact desync bug this replaces).
        if (target > 0 && dur > 0) {
            var diff = Math.abs(dur - target)
            if (diff <= 3) score += 25
            else if (diff <= 8) score += 12
            else if (diff <= 15) score += 4
            else return -1000
        }
        var ca = (c.artistName || "").toLowerCase()
        var ct = (c.trackName || c.name || "").toLowerCase()
        var la = (artist || "").toLowerCase()
        var lt = (title || "").toLowerCase()
        if (la && ca === la) score += 10
        else if (la && ca.indexOf(la) !== -1) score += 3
        else if (la && la.indexOf(ca) !== -1) score += 2
        if (lt && ct === lt) score += 10
        else if (lt && ct.indexOf(lt) !== -1) score += 3
        else if (lt && lt.indexOf(ct) !== -1) score += 2
        if (c.syncedLyrics) score += 15
        else if (c.plainLyrics) score += 5
        if (c.instrumental) score -= 3
        return score
    }

    function _rankCandidates(cands, artist, title, duration) {
        var scored = []
        for (var i = 0; i < cands.length; i++) {
            var c = cands[i]
            scored.push({ candidate: c, score: _scoreCandidate(c, artist, title, duration) })
        }
        scored.sort(function(a, b) { return b.score - a.score })
        var sorted = []
        for (var j = 0; j < scored.length; j++) sorted.push(scored[j].candidate)
        return { sorted: sorted, scored: scored }
    }

    // ── URL builders ─────────────────────────────────────────────
    function _buildGetUrl(artist, title, album, duration) {
        var url = "https://lrclib.net/api/get?artist_name=" + _enc(artist)
                + "&track_name=" + _enc(title)
                + "&album_name=" + _enc(album || "")
        if (duration && duration > 0) url += "&duration=" + String(Math.round(duration))
        return url
    }

    function _buildSearchUrl(artist, title, album) {
        var url = "https://lrclib.net/api/search?artist_name=" + _enc(artist)
                + "&track_name=" + _enc(title)
                + "&album_name=" + _enc(album || "")
        return url
    }

    // ── Cache writer ─────────────────────────────────────────────
    function _writeCache(hash, payload) {
        if (!hash || !payload) return
        var jsonStr = JSON.stringify(payload)
        var target = cacheDir + "/" + hash + ".json"
        // Use argv quoting: printf '%s' "$2" > "$3" where $2 is json
        // and $3 is path — safe for quotes/newlines (no eval).
        cacheWriteProc.command = ["sh", "-c",
            "mkdir -p \"$1\" && printf '%s' \"$2\" > \"$3\"",
            "sh", cacheDir, jsonStr, target]
        cacheWriteProc.running = true
    }

    // ── Result emitter (cache + signal + callback) ───────────────
    function _emitResult(best, candidates, source, cached) {
        var result = {
            plainLyrics: best ? (best.plainLyrics || "") : "",
            syncedLyrics: best ? (best.syncedLyrics || "") : "",
            instrumental: best ? !!best.instrumental : false,
            duration: best ? (best.duration || 0) : 0,
            trackName: best ? (best.trackName || best.name || "") : "",
            artistName: best ? (best.artistName || "") : "",
            albumName: best ? (best.albumName || "") : "",
            id: best ? (best.id || 0) : 0,
            source: source,
            cached: !!cached,
            candidates: candidates || (best ? [best] : [])
        }
        lyricsFetched(result)
        if (lyricsService._pendingCallback) {
            try { lyricsService._pendingCallback(result) } catch(e) { console.warn("LyricsService: callback error", e) }
        }
    }

    // ═══════════════════════════════════════════════════════════════
    //  PUBLIC API
    // ═══════════════════════════════════════════════════════════════

    // fetch(artist, title, album, duration, callback)
    // callback is optional; signal lyricsFetched always fires on success.
    // duration may be seconds (float) or 0/undefined.
    function fetch(artist, title, album, duration, callback) {
        if (!artist || !title) {
            var msg = "LyricsService: artist and title required"
            console.warn(msg)
            fetchFailed(msg)
            if (callback) try { callback(null) } catch(e) {}
            return
        }
        _pendingArtist = artist
        _pendingTitle = title
        _pendingAlbum = album || ""
        _pendingDuration = duration || 0
        _pendingCallback = (typeof callback === "function") ? callback : null
        _pendingHash = _hashKey(artist, title, album, duration)
        _pendingPath = cacheDir + "/" + _pendingHash + ".json"
        _phase = "cache"
        cacheReadProc.command = ["cat", _pendingPath]
        cacheReadProc.running = true
    }

    // search(artist, title, album) — manual selection, emits candidates
    function search(artist, title, album) {
        if (!artist || !title) {
            console.warn("LyricsService.search: artist and title required")
            searchCompleted([])
            return
        }
        // keep pending fields for ranking context
        _pendingArtist = artist
        _pendingTitle = title
        _pendingAlbum = album || ""
        _phase = "manual-search"
        var url = _buildSearchUrl(artist, title, album)
        curlSearchProc.command = ["curl", "-s", url]
        curlSearchProc.running = true
    }

    // Optional: pick a specific candidate from last search/fetch
    // index refers to the ranked candidates array emitted.
    // Re-emits lyricsFetched with that candidate as the best.
    property var _lastCandidates: []
    function selectCandidate(index) {
        if (!_lastCandidates || index < 0 || index >= _lastCandidates.length) {
            console.warn("LyricsService.selectCandidate: invalid index " + index)
            return
        }
        var c = _lastCandidates[index]
        // Move chosen candidate to front for display
        var reordered = [c]
        for (var i = 0; i < _lastCandidates.length; i++) if (i !== index) reordered.push(_lastCandidates[i])
        _emitResult(c, reordered, "manual-select", false)
        // also update cache with the user-chosen pick
        if (_pendingHash) {
            _writeCache(_pendingHash, {
                plainLyrics: c.plainLyrics || "",
                syncedLyrics: c.syncedLyrics || "",
                instrumental: !!c.instrumental,
                duration: c.duration || 0,
                trackName: c.trackName || c.name || "",
                artistName: c.artistName || "",
                albumName: c.albumName || "",
                id: c.id || 0,
                source: "manual-select"
            })
        }
    }

    // ── Internal request dispatchers ─────────────────────────────
    function _requestGet() {
        _phase = "get"
        var url = _buildGetUrl(_pendingArtist, _pendingTitle, _pendingAlbum, _pendingDuration)
        curlGetProc.command = ["curl", "-s", url]
        curlGetProc.running = true
    }

    function _requestSearch() {
        _phase = "search"
        var url = _buildSearchUrl(_pendingArtist, _pendingTitle, _pendingAlbum)
        curlSearchProc.command = ["curl", "-s", url]
        curlSearchProc.running = true
    }

    // ═══════════════════════════════════════════════════════════════
    //  PROCESSES
    // ═══════════════════════════════════════════════════════════════

    Process {
        id: cacheReadProc
        command: []
        stdout: StdioCollector { id: cacheReadOut }
        onExited: (code, status) => {
            if (code === 0 && cacheReadOut.text && cacheReadOut.text.trim() !== "") {
                try {
                    var obj = JSON.parse(cacheReadOut.text)
                    var entry = obj  // cached payload is already normalized
                    // Compat: older caches may nest under different keys
                    var best = {
                        plainLyrics: entry.plainLyrics || entry.plain || "",
                        syncedLyrics: entry.syncedLyrics || entry.synced || "",
                        instrumental: !!entry.instrumental,
                        duration: entry.duration || lyricsService._pendingDuration || 0,
                        trackName: entry.trackName || entry.name || lyricsService._pendingTitle,
                        artistName: entry.artistName || lyricsService._pendingArtist,
                        albumName: entry.albumName || lyricsService._pendingAlbum,
                        id: entry.id || 0
                    }
                    console.info("LyricsService: cache hit " + lyricsService._pendingHash)
                    lyricsService._lastCandidates = [best]
                    lyricsService._emitResult(best, [best], entry.source || "cache", true)
                    return
                } catch(e) {
                    console.warn("LyricsService: cache parse failed, falling back to network", e)
                }
            }
            // cache miss or parse error → network
            lyricsService._requestGet()
        }
    }

    Process {
        id: cacheWriteProc
        command: []
        onExited: (code, status) => {
            if (code !== 0) console.warn("LyricsService: cache write failed (" + code + ")")
        }
    }

    Process {
        id: curlGetProc
        command: []
        stdout: StdioCollector { id: curlGetOut }
        onExited: (code, status) => {
            var text = curlGetOut.text || ""
            var trimmed = text.trim()
            if (trimmed !== "") {
                try {
                    var obj = JSON.parse(trimmed)
                    // LRCLIB error shape: { statusCode: 404, message: ... }
                    // Success shape: { id, trackName, artistName, plainLyrics, ... }
                    if (obj && (obj.plainLyrics || obj.syncedLyrics || obj.instrumental === true)) {
                        console.info("LyricsService: /api/get hit for " + lyricsService._pendingArtist + " - " + lyricsService._pendingTitle)
                        var payload = {
                            plainLyrics: obj.plainLyrics || "",
                            syncedLyrics: obj.syncedLyrics || "",
                            instrumental: !!obj.instrumental,
                            duration: obj.duration || lyricsService._pendingDuration || 0,
                            trackName: obj.trackName || obj.name || lyricsService._pendingTitle,
                            artistName: obj.artistName || lyricsService._pendingArtist,
                            albumName: obj.albumName || lyricsService._pendingAlbum,
                            id: obj.id || 0,
                            source: "get"
                        }
                        lyricsService._lastCandidates = [obj]
                        lyricsService._writeCache(lyricsService._pendingHash, payload)
                        lyricsService._emitResult(obj, [obj], "get", false)
                        return
                    }
                    // 404 or empty lyrics → fall through to search
                    if (obj && obj.statusCode === 404) {
                        console.info("LyricsService: /api/get 404, falling back to search")
                    }
                } catch(e) {
                    console.warn("LyricsService: /api/get parse failed", e, trimmed.slice(0, 200))
                }
            } else if (code !== 0) {
                console.warn("LyricsService: /api/get curl failed (" + code + ")")
            }
            // Fallback to search
            // If we are offline (curl exit !=0 and no cached hit already), search will also fail
            // and the search handler will emit fetchFailed with cache-aware message.
            lyricsService._requestSearch()
        }
    }

    Process {
        id: curlSearchProc
        command: []
        stdout: StdioCollector { id: curlSearchOut }
        onExited: (code, status) => {
            var text = curlSearchOut.text || ""
            var trimmed = text.trim()
            if (trimmed !== "" && code === 0) {
                try {
                    var arr = JSON.parse(trimmed)
                    // LRCLIB search returns array; error returns object
                    if (Array.isArray(arr) && arr.length > 0) {
                        var ranked = lyricsService._rankCandidates(arr, lyricsService._pendingArtist, lyricsService._pendingTitle, lyricsService._pendingDuration)
                        var sorted = ranked.sorted
                        var best = sorted[0]
                        console.info("LyricsService: /api/search got " + arr.length + " candidates, best score via ranking")
                        lyricsService._lastCandidates = sorted
                        if (lyricsService._phase === "manual-search") {
                            // Manual search: expose full ranked list
                            lyricsService.searchCompleted(sorted)
                            // Do not auto-emit lyricsFetched for manual path
                            return
                        }
                        // Fetch fallback path: auto-pick best, emit lyricsFetched
                        var payload2 = {
                            plainLyrics: best.plainLyrics || "",
                            syncedLyrics: best.syncedLyrics || "",
                            instrumental: !!best.instrumental,
                            duration: best.duration || lyricsService._pendingDuration || 0,
                            trackName: best.trackName || best.name || lyricsService._pendingTitle,
                            artistName: best.artistName || lyricsService._pendingArtist,
                            albumName: best.albumName || lyricsService._pendingAlbum,
                            id: best.id || 0,
                            source: "search"
                        }
                        lyricsService._writeCache(lyricsService._pendingHash, payload2)
                        lyricsService._emitResult(best, sorted, "search", false)
                        // Also surface candidates for dropdown consumers
                        lyricsService.searchCompleted(sorted)
                        return
                    } else if (Array.isArray(arr) && arr.length === 0) {
                        console.info("LyricsService: /api/search returned 0 candidates")
                        if (lyricsService._phase === "manual-search") {
                            lyricsService.searchCompleted([])
                            return
                        }
                        // fetch path: no results
                        var failMsg = "LyricsService: no lyrics found for " + lyricsService._pendingArtist + " - " + lyricsService._pendingTitle
                        console.info(failMsg)
                        // Emit empty result so panel can show "not found" vs spinner forever
                        lyricsService._lastCandidates = []
                        var emptyResult = {
                            plainLyrics: "",
                            syncedLyrics: "",
                            instrumental: false,
                            duration: lyricsService._pendingDuration || 0,
                            trackName: lyricsService._pendingTitle,
                            artistName: lyricsService._pendingArtist,
                            albumName: lyricsService._pendingAlbum,
                            id: 0,
                            source: "none",
                            cached: false,
                            candidates: []
                        }
                        lyricsService.lyricsFetched(emptyResult)
                        if (lyricsService._pendingCallback) try { lyricsService._pendingCallback(emptyResult) } catch(e) {}
                        lyricsService.fetchFailed("No lyrics found")
                        lyricsService.searchCompleted([])
                        return
                    } else if (arr && arr.statusCode) {
                        console.warn("LyricsService: /api/search error " + arr.statusCode + " " + (arr.message || ""))
                    }
                } catch(e) {
                    console.warn("LyricsService: /api/search parse failed", e, trimmed.slice(0, 300))
                }
            }
            // Network failure or parse failure
            if (lyricsService._phase === "manual-search") {
                console.warn("LyricsService: manual search failed (curl " + code + ")")
                lyricsService.searchCompleted([])
                return
            }
            // Fetch path: offline or error with no cache hit
            console.warn("LyricsService: search failed (curl " + code + "), no cache available — offline?")
            var offlineResult = {
                plainLyrics: "",
                syncedLyrics: "",
                instrumental: false,
                duration: lyricsService._pendingDuration || 0,
                trackName: lyricsService._pendingTitle,
                artistName: lyricsService._pendingArtist,
                albumName: lyricsService._pendingAlbum,
                id: 0,
                source: "none",
                cached: false,
                candidates: []
            }
            // Still emit lyricsFetched with empty so caller can clear loading state
            lyricsService.lyricsFetched(offlineResult)
            if (lyricsService._pendingCallback) try { lyricsService._pendingCallback(offlineResult) } catch(e) {}
            lyricsService.fetchFailed(code !== 0 ? "Network unavailable and no cached lyrics" : "No lyrics found")
            lyricsService.searchCompleted([])
        }
    }
}
