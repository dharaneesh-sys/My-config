import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  BarAndPillViewModel
    //
    //  Presentation adapter for the Bar & Pill settings page.
    //  Reads SettingsStore for all bar/pill/panel values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Pill ───────────────────────────────────────────────────────
    readonly property real pillWidth: SettingsStore.pillWidth
    readonly property string pillWidthText: Math.round(SettingsStore.pillWidth) + "px"

    readonly property real pillHeight: SettingsStore.pillHeight
    readonly property string pillHeightText: Math.round(SettingsStore.pillHeight) + "px"

    readonly property real pillTopMargin: SettingsStore.pillTopMargin
    readonly property string pillTopMarginText: Math.round(SettingsStore.pillTopMargin) + "px"

    readonly property real pillCornerRadius: SettingsStore.pillCornerRadius
    readonly property string pillCornerRadiusText: SettingsStore.pillCornerRadius >= 9999
                                                   ? "Pill (∞)"
                                                   : Math.round(SettingsStore.pillCornerRadius) + "px"

    // ── Panels ────────────────────────────────────────────────────
    readonly property real panelMaxWidth: SettingsStore.panelMaxWidth
    readonly property string panelMaxWidthText: Math.round(SettingsStore.panelMaxWidth) + "px"

    readonly property real panelPadding: SettingsStore.panelPadding
    readonly property string panelPaddingText: Math.round(SettingsStore.panelPadding) + "px"

    readonly property real panelCornerRadius: SettingsStore.panelCornerRadius
    readonly property string panelCornerRadiusText: Math.round(SettingsStore.panelCornerRadius) + "px"
    // ── Notch (Apple-style) ──────────────────────────────────────
    readonly property bool notchEnabled: SettingsStore.notchEnabled

    // ── Opacity ────────────────────────────────────────────────────
    readonly property real shellOpacity: SettingsStore.shellOpacity
    readonly property string shellOpacityText: Math.round(SettingsStore.shellOpacity * 100) + "%"

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setPillWidth(val)        { SettingsStore.pillWidth = val }
    function setPillHeight(val)       { SettingsStore.pillHeight = val }
    function setPillTopMargin(val)    { SettingsStore.pillTopMargin = val }
    function setPillCornerRadius(val) { SettingsStore.pillCornerRadius = val }

    function setPanelMaxWidth(val)    { SettingsStore.panelMaxWidth = val }
    function setPanelPadding(val)     { SettingsStore.panelPadding = val }
    function setPanelCornerRadius(val){ SettingsStore.panelCornerRadius = val }
    function setNotchEnabled(val)     { SettingsStore.notchEnabled = val }

    function setShellOpacity(val)     { SettingsStore.shellOpacity = val }
}
