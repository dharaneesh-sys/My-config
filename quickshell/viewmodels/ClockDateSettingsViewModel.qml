import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  ClockDateSettingsViewModel
    //
    //  Presentation adapter for the Clock & Date settings page.
    //  Reads SettingsStore for clock/date configuration values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Time ───────────────────────────────────────────────────────
    readonly property bool use24h: SettingsStore.clockUse24h
    readonly property bool showSeconds: SettingsStore.clockShowSeconds
    readonly property bool showInPill: SettingsStore.clockShowInPill

    // ── Date ───────────────────────────────────────────────────────
    readonly property string dateFormat: SettingsStore.clockDateFormat
    readonly property string dateFormatLabel: _dateFormatLabel(SettingsStore.clockDateFormat)

    readonly property var dateFormatOptions: [
        { key: "long",     label: "Long",     active: SettingsStore.clockDateFormat === "long" },
        { key: "short",    label: "Short",    active: SettingsStore.clockDateFormat === "short" },
        { key: "iso",      label: "ISO",      active: SettingsStore.clockDateFormat === "iso" },
        { key: "relative", label: "Relative", active: SettingsStore.clockDateFormat === "relative" }
    ]

    // ── Timezone ──────────────────────────────────────────────────
    readonly property string timezone: SettingsStore.clockTimezone
    readonly property string timezoneLabel: SettingsStore.clockTimezone !== ""
                                           ? SettingsStore.clockTimezone
                                           : "System default"

    // Common IANA timezones for quick selection.
    // The user can also type a custom timezone via
    // SettingsStore.clockTimezone directly.
    readonly property var timezoneOptions: [
        { key: "",              label: "System" },
        { key: "UTC",           label: "UTC" },
        { key: "America/New_York",    label: "New York" },
        { key: "America/Chicago",    label: "Chicago" },
        { key: "America/Los_Angeles", label: "Los Angeles" },
        { key: "Europe/London",      label: "London" },
        { key: "Europe/Paris",       label: "Paris" },
        { key: "Europe/Berlin",      label: "Berlin" },
        { key: "Asia/Kolkata",       label: "Kolkata" },
        { key: "Asia/Tokyo",         label: "Tokyo" },
        { key: "Asia/Shanghai",      label: "Shanghai" },
        { key: "Australia/Sydney",   label: "Sydney" }
    ]

    readonly property var timezoneButtons: _buildTimezoneButtons()

    function _buildTimezoneButtons() {
        var out = []
        for (var i = 0; i < timezoneOptions.length; i++) {
            out.push({
                key: timezoneOptions[i].key,
                label: timezoneOptions[i].label,
                active: SettingsStore.clockTimezone === timezoneOptions[i].key
            })
        }
        return out
    }

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setUse24h(val)          { SettingsStore.clockUse24h = val }
    function setShowSeconds(val)     { SettingsStore.clockShowSeconds = val }
    function setShowInPill(val)      { SettingsStore.clockShowInPill = val }
    function setDateFormat(key)      { SettingsStore.clockDateFormat = key }
    function setTimezone(key)        { SettingsStore.clockTimezone = key }

    // ── Helpers ────────────────────────────────────────────────────
    function _dateFormatLabel(key) {
        switch (key) {
        case "long":     return "Long (e.g. Monday, January 1)"
        case "short":    return "Short (e.g. Jan 1)"
        case "iso":      return "ISO 8601 (e.g. 2024-01-01)"
        case "relative": return "Relative (e.g. Today, Yesterday)"
        default:         return key
        }
    }
}
