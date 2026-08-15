import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  ControlCenterSettingsViewModel
    //
    //  Presentation adapter for the Control Center settings page.
    //  Reads SettingsStore for all control center and panel values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Section visibility ─────────────────────────────────────────
    readonly property bool showQuickToggles: SettingsStore.ccShowQuickToggles
    readonly property bool showVolume: SettingsStore.ccShowVolume
    readonly property bool showBrightness: SettingsStore.ccShowBrightness
    readonly property bool showMedia: SettingsStore.ccShowMedia
    readonly property bool showNotifications: SettingsStore.ccShowNotifications
    readonly property bool showBattery: SettingsStore.ccShowBattery

    // ── Panel dimensions ───────────────────────────────────────────
    readonly property real panelMaxWidth: SettingsStore.panelMaxWidth
    readonly property string panelMaxWidthText: Math.round(SettingsStore.panelMaxWidth) + "px"

    readonly property real panelPadding: SettingsStore.panelPadding
    readonly property string panelPaddingText: Math.round(SettingsStore.panelPadding) + "px"

    // ── Visible section count (formatted) ──────────────────────────
    readonly property int visibleCount: (showQuickToggles ? 1 : 0)
                                       + (showVolume ? 1 : 0)
                                       + (showBrightness ? 1 : 0)
                                       + (showMedia ? 1 : 0)
                                       + (showNotifications ? 1 : 0)
                                       + (showBattery ? 1 : 0)
    readonly property string visibleCountText: visibleCount + " of 6 sections visible"

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setShowQuickToggles(val)     { SettingsStore.ccShowQuickToggles = val }
    function setShowVolume(val)           { SettingsStore.ccShowVolume = val }
    function setShowBrightness(val)       { SettingsStore.ccShowBrightness = val }
    function setShowMedia(val)            { SettingsStore.ccShowMedia = val }
    function setShowNotifications(val)    { SettingsStore.ccShowNotifications = val }
    function setShowBattery(val)          { SettingsStore.ccShowBattery = val }

    function setPanelMaxWidth(val)        { SettingsStore.panelMaxWidth = val }
    function setPanelPadding(val)         { SettingsStore.panelPadding = val }
}
