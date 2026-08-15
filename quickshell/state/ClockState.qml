pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: clockState

    // ═══════════════════════════════════════════════════════════════
    //  ClockState
    //
    //  Reactive clock/date properties bound directly to the native
    //  SystemClock service (updates once per second at Seconds
    //  precision). No 1s QML Timer, no manual Date juggling.
    // ═══════════════════════════════════════════════════════════════

    // ── Native ─────────────────────────────────────────────────────
    property SystemClock clock: SystemClock {
        precision: SystemClock.Seconds
        enabled: true
    }

    // ── Time ───────────────────────────────────────────────────────
    readonly property string time: clock ? _formatTime(false) : "00:00"
    readonly property string timeSeconds: clock ? _formatTime(true) : "00:00:00"
    readonly property int hours: clock ? clock.hours : 0
    readonly property int minutes: clock ? clock.minutes : 0
    readonly property int seconds: clock ? clock.seconds : 0

    // ── Date ───────────────────────────────────────────────────────
    readonly property string date: clock ? _formatDate() : ""
    readonly property string dayOfWeek: clock ? Qt.formatDate(clock.date, "dddd") : ""
    readonly property string dateLong: clock ? _formatDateLong() : ""

    // ── Config (mirrors SettingsStore; written by shell bridge) ────
    property bool use24h: true
    property bool showSeconds: false
    property string timezone: ""
    property string dateFormat: "long"  // long | short | iso

    // ── Actions (kept as signals for API compatibility) ────────────
    signal set24hRequested(bool use24h)
    signal setShowSecondsRequested(bool show)
    signal setTimezoneRequested(string tz)
    signal setDateFormatRequested(string format)

    property Connections _actions: Connections {
        target: clockState
        function onSet24hRequested(v) { clockState.use24h = v }
        function onSetShowSecondsRequested(s) { clockState.showSeconds = s }
        function onSetTimezoneRequested(tz) { clockState.timezone = tz }
        function onSetDateFormatRequested(f) { clockState.dateFormat = f }
    }

    // ── Formatting helpers ─────────────────────────────────────────
    function _formatTime(withSeconds) {
        var h = clockState.hours
        var m = clockState.minutes
        var mm = m < 10 ? "0" + m : "" + m
        var s = clockState.seconds
        var ss = s < 10 ? "0" + s : "" + s
        if (clockState.use24h)
            return withSeconds ? h + ":" + mm + ":" + ss : h + ":" + mm
        var h12 = h % 12 || 12
        var ampm = h < 12 ? "AM" : "PM"
        return withSeconds ? h12 + ":" + mm + ":" + ss + " " + ampm
                           : h12 + ":" + mm + " " + ampm
    }

    function _formatDate() {
        if (!clockState.clock) return ""
        var d = clockState.clock.date
        switch (clockState.dateFormat) {
        case "short": return Qt.formatDate(d, "M/d")
        case "iso":   return Qt.formatDate(d, "yyyy-MM-dd")
        default:      return Qt.formatDate(d, "MMMM d")
        }
    }

    function _formatDateLong() {
        if (!clockState.clock) return ""
        var d = clockState.clock.date
        switch (clockState.dateFormat) {
        case "short": return Qt.formatDate(d, "M/d")
        case "iso":   return Qt.formatDate(d, "yyyy-MM-dd")
        default:      return Qt.formatDate(d, "dddd, MMMM d, yyyy")
        }
    }
}
