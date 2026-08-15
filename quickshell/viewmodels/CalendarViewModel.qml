import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  CalendarViewModel
    //
    //  Presentation adapter for the Calendar panel.
    //  Reads ClockState, formats presentation data.
    //
    //  • Reads:  ClockState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Date display ───────────────────────────────────────────────
    readonly property string dateLong: ClockState.dateLong
    readonly property string dayOfWeek: ClockState.dayOfWeek

    // ── Time display ───────────────────────────────────────────────
    readonly property string time: ClockState.showSeconds
                                ? ClockState.timeSeconds
                                : ClockState.time

    // ── Settings ───────────────────────────────────────────────────
    readonly property bool use24h: ClockState.use24h
    readonly property bool showSeconds: ClockState.showSeconds

    // ── Actions ────────────────────────────────────────────────────
    function toggle24h()       { ClockState.set24hRequested(!ClockState.use24h) }
    function toggleSeconds()   { ClockState.setShowSecondsRequested(!ClockState.showSeconds) }
}
