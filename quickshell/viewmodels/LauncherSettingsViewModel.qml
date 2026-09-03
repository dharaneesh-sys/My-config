import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  LauncherSettingsViewModel
    //
    //  Presentation adapter for the Launcher settings page.
    //  Reads SettingsStore for launcher configuration values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Show descriptions ──────────────────────────────────────────
    readonly property bool showDescriptions: SettingsStore.launcherShowDescriptions

    // ── Default action ─────────────────────────────────────────────
    readonly property string defaultAction: SettingsStore.launcherDefaultAction
    readonly property string defaultActionLabel: SettingsStore.launcherDefaultAction === "terminal"
                                                ? "Run in terminal"
                                                : "Launch directly"

    readonly property var actionOptions: [
        { key: "launch",  label: "Launch",   active: SettingsStore.launcherDefaultAction === "launch" },
        { key: "terminal", label: "Terminal", active: SettingsStore.launcherDefaultAction === "terminal" }
    ]

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setShowDescriptions(val)    { SettingsStore.launcherShowDescriptions = val }
    function setDefaultAction(key)       { SettingsStore.launcherDefaultAction = key }
}
