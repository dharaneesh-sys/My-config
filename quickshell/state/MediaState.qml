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

    // Tick to force position binding re-evaluation (see _positionMonitor)
    property int _positionTick: 0

    // Keep _active fresh when preferred player changes
    onPreferredPlayerNameChanged: _active = _pickActivePlayer()

    // ── Active player ──────────────────────────────────────────────
    readonly property string playerName: _active ? _active.identity : ""
    readonly property string title: _active ? _active.trackTitle : ""
    readonly property string artist: _active ? _active.trackArtist : ""
    readonly property string album: _active ? _active.trackAlbum : ""
    readonly property url artwork: _active && _active.trackArtUrl ? _active.trackArtUrl : ""
    readonly property string trackUrl: _active && _active.metadata ? (_active.metadata["xesam:url"] || "") : ""
    readonly property string trackId: _active && _active.metadata ? (_active.metadata["mpris:trackId"] || "") : ""

    // ── Playback (seconds) ─────────────────────────────────────────
    readonly property bool playing: _active ? _active.isPlaying : false
    readonly property real position: {
        // Depend on _positionTick so 500ms pokes force re-evaluation + notify
        mediaState._positionTick;
        return mediaState._active ? mediaState._active.position / 1000000 : 0.0
    }
    readonly property real length: _active ? _active.length / 1000000 : 0.0
    readonly property string shuffle: _active ? (_active.shuffle ? "on" : "off") : "off"
    readonly property string repeat: _active ? _loopName(_active.loopState) : "off"

    function _loopName(s) {
        if (s === MprisLoopState.Track) return "track"
        if (s === MprisLoopState.Playlist) return "playlist"
        return "off"
    }

    // ── Video / song gating ────────────────────────────────────────
    // Heuristic to decide if the current track is a video so lyrics
    // are only shown for songs. kdeconnect ("KDE Connect") is always
    // treated as song when title/artist present.
    function _isVideo(player) {
        if (!player)
            return false
        var identity = (player.identity || "").toLowerCase()
        var rawUrl = player.metadata ? (player.metadata["xesam:url"] || "") : ""
        var url = rawUrl.toLowerCase()
        var title = (player.trackTitle || "").toLowerCase()

        // KDE Connect — phone media, never video if title/artist present
        if (identity.indexOf("kde connect") !== -1)
            return false

        // Known music-only players — never video
        var musicIds = ["spotify", "youtube music", "youtube-music", "youtube_music", "ytmdesktop", "elisa", "amberol", "lollypop", "rhythmbox", "audacious", "clementine", "strawberry", "kde connect", "metrolist"]
        for (var mi = 0; mi < musicIds.length; mi++) {
            if (identity.indexOf(musicIds[mi]) !== -1)
                return false
        }
        // music.youtube.com inside a browser is still music
        if (url.indexOf("music.youtube.com") !== -1)
            return false

        // Video file extensions in xesam:url
        if (url.match(/\.(mp4|mkv|avi|webm|mov)(\?|#|$)/))
            return true

        // Browser + title hints (YouTube / Netflix / video)
        var isBrowser = identity.indexOf("firefox") !== -1 || identity.indexOf("chrome") !== -1 || identity.indexOf("chromium") !== -1 || identity.indexOf("vivaldi") !== -1 || identity.indexOf("brave") !== -1
        if (isBrowser) {
            if (title.indexOf("youtube") !== -1 || title.indexOf("netflix") !== -1 || url.indexOf("youtube.com/watch") !== -1)
                return true
            // generic "video" keyword in title for browsers -> treat as video
            // (avoid false positive for "video killed the radio star" is rare)
            if (title.indexOf("video") !== -1)
                return true
        }

        // Dedicated video players (mpv/vlc/mplayer etc.)
        var isVideoPlayer = identity.indexOf("mpv") !== -1 || identity.indexOf("vlc") !== -1 || identity.indexOf("mplayer") !== -1 || identity.indexOf("haruna") !== -1 || identity.indexOf("celluloid") !== -1 || identity.indexOf("smplayer") !== -1
        if (isVideoPlayer) {
            var art = player.trackArtUrl || ""
            if (!art)
                return true
            if (player.length && player.length / 1000000 > 1800)
                return true
            // already checked extension above
        }

        // Fallback: length > 30min with browser/video player, or video mime hint
        // (supportedMimeTypes not exposed directly; artwork-empty check covers it)
        return false
    }

    readonly property bool isVideo: _isVideo(_active)
    readonly property bool isSong: !isVideo && title !== ""
    readonly property bool canShowLyrics: isSong && !isVideo

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
                playing: vals[i].isPlaying,
                trackUrl: vals[i].metadata ? (vals[i].metadata["xesam:url"] || "") : "",
                trackId: vals[i].metadata ? (vals[i].metadata["mpris:trackId"] || "") : "",
                isVideo: mediaState._isVideo(vals[i])
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
        function onValuesChanged() {
            mediaState._active = mediaState._pickActivePlayer()
            mediaState.players = mediaState._collectPlayers()
            if (mediaState.playing && mediaState._active !== null)
                mediaState._positionMonitor.restart()
        }
    }

    // Fallback: when active player's playing state flips, ensure monitor restarts
    property Connections _activeIsPlayingConn: Connections {
        target: mediaState._active
        enabled: mediaState._active !== null
        function onIsPlayingChanged() {
            if (mediaState._active && mediaState._active.isPlaying)
                mediaState._positionMonitor.restart()
            else
                mediaState._positionMonitor.stop()
        }
    }

    // ── Position monitor ────────────────────────────────────────
    // Quickshell suppresses reactive position updates unless something is
    // monitoring them (docs WARNING on MprisPlayer.position): reading it
    // always returns the live value, but positionChanged only fires on
    // nonlinear jumps (seek). Poking the signal every 500ms while playing
    // makes every MediaState.position binding (progress bar, lyrics
    // auto-sync) re-evaluate with fresh D-Bus data — the exact pattern
    // used by ony-boom/live-lrc and recommended by quickshell.org docs.
    property Timer _positionMonitor: Timer {
        interval: 500
        running: mediaState.playing && mediaState._active !== null
        repeat: true
        onTriggered: {
            if (mediaState._active) {
                mediaState._active.positionChanged()
                mediaState._positionTick++
                // Explicit notify — ensures LyricsState.onPositionChanged fires even if
                // QML binding coalesces the tick dependency in some engine versions
                mediaState.positionChanged()
            }
        }
    }
}
