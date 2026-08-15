pragma Singleton
import QtQuick

QtObject {
    id: powerState

    // ═══════════════════════════════════════════════════════════════
    //  PowerState
    //
    //  Reactive power/session properties. Written by PowerService.
    //  Read by PowerMenuViewModel and SystemSettingsViewModel.
    // ═══════════════════════════════════════════════════════════════

    // ── Lock ───────────────────────────────────────────────────────
    property bool locked: false

    // ── Suspend ────────────────────────────────────────────────────
    property bool suspending: false

    // ── Actions: session (called by ViewModel, delegated to Service) ─
    signal lockRequested()
    signal suspendRequested()
    signal rebootRequested()
    signal shutdownRequested()

    // ── Actions: system management (from System page) ──────────────
    signal reloadShellRequested()
    signal restartShellRequested()
    signal quitShellRequested()
    signal openConfigDirRequested()
    signal showLogsRequested()
}
