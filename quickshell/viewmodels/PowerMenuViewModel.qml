import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  PowerMenuViewModel
    //
    //  Presentation adapter for the PowerMenu panel.
    //  Reads PowerState, formats presentation data.
    //  Emits user intent to PowerState — never executes Process.
    //
    //  • Reads:  PowerState
    //  • Writes: nothing (actions flow through State signals)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── State ──────────────────────────────────────────────────────
    readonly property bool locked: PowerState.locked
    readonly property bool suspending: PowerState.suspending

    // ── Actions (emit intent only — Service handles execution) ─────
    function lock()     { PowerState.lockRequested() }
    function suspend()  { PowerState.suspendRequested() }
    function reboot()   { PowerState.rebootRequested() }
    function shutdown() { PowerState.shutdownRequested() }
}
