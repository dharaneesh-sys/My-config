import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  NotificationSettingsViewModel
    //
    //  Presentation adapter for the Notifications settings page.
    //  Reads SettingsStore for notification configuration values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Display ────────────────────────────────────────────────────
    readonly property bool showBody: SettingsStore.notificationShowBody
    readonly property bool showActions: SettingsStore.notificationShowActions

    readonly property int maxVisible: SettingsStore.notificationMaxVisible
    readonly property string maxVisibleText: SettingsStore.notificationMaxVisible + " notifications"

    // ── Behavior ───────────────────────────────────────────────────
    readonly property int timeout: SettingsStore.notificationTimeout
    readonly property string timeoutText: (SettingsStore.notificationTimeout / 1000).toFixed(1) + "s"

    readonly property string position: SettingsStore.notificationPosition
    readonly property string positionLabel: _positionLabel(SettingsStore.notificationPosition)

    readonly property var positionOptions: [
        { key: "top-left",      label: "Top Left",      active: SettingsStore.notificationPosition === "top-left" },
        { key: "top-right",     label: "Top Right",     active: SettingsStore.notificationPosition === "top-right" },
        { key: "bottom-left",   label: "Bottom Left",   active: SettingsStore.notificationPosition === "bottom-left" },
        { key: "bottom-right",  label: "Bottom Right",  active: SettingsStore.notificationPosition === "bottom-right" }
    ]

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setShowBody(val)       { SettingsStore.notificationShowBody = val }
    function setShowActions(val)    { SettingsStore.notificationShowActions = val }
    function setMaxVisible(val)     { SettingsStore.notificationMaxVisible = Math.round(val) }
    function setTimeout(val)        { SettingsStore.notificationTimeout = Math.round(val) }
    function setPosition(key)       { SettingsStore.notificationPosition = key }

    // ── Helpers ────────────────────────────────────────────────────
    function _positionLabel(key) {
        switch (key) {
        case "top-left":      return "Top Left"
        case "top-right":     return "Top Right"
        case "top-center":    return "Top Center"
        case "bottom-left":   return "Bottom Left"
        case "bottom-right":  return "Bottom Right"
        case "bottom-center": return "Bottom Center"
        default:              return key
        }
    }
}
