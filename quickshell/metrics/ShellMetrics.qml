pragma Singleton
import QtQuick
import qs.tokens
import qs.settings

QtObject {
    id: m

    // ═══════════════════════════════════════════════════════════════
    //  Shell-wide layout dimensions.
    //
    //  Every dimension that controls the shell's spatial layout
    //  lives here. No other file may hardcode panel widths, pill
    //  sizes, or margins — they reference ShellMetrics.
    //
    //  Pill and panel dimensions are LIVE-bound to SettingsStore
    //  so changing them in the Bar & Pill settings page updates
    //  the shell immediately.
    //
    //  Values still fall back to Spacing tokens as defaults.
    // ═══════════════════════════════════════════════════════════════

    // ─── Pill (live from SettingsStore) ─────────────────────────
    readonly property real pillHeight:       SettingsStore.pillHeight
    readonly property real pillWidth:        SettingsStore.pillWidth
    readonly property real pillTopMargin:    SettingsStore.pillTopMargin
    readonly property real pillBottomMargin: SettingsStore.pillBottomMargin
    readonly property real pillCornerRadius: SettingsStore.pillCornerRadius
    // Shared boundary between the exclusive pill bar and every floating
    // expanded panel. Keep this pixel-aligned so both layer surfaces agree.
    readonly property int pillReservedHeight: Math.ceil(pillTopMargin
                                                        + pillHeight
                                                        + pillBottomMargin)
    // Visual attachment point for expanded panels. Unlike the reserved
    // height, this intentionally excludes the bottom safety margin.
    readonly property real pillBottomEdge: pillTopMargin + pillHeight

    // ─── Expanded surface (live from SettingsStore) ─────────────
    readonly property real expandedPadding:  SettingsStore.panelPadding
    readonly property real expandedWidth:    SettingsStore.panelMaxWidth
    // The floating layer surface stays this tall while a panel animates.
    // Keeping its geometry stable prevents compositor configure jitter.
    readonly property real panelSurfaceHeight: 600

    // ─── Panel blur/opacity (live from SettingsStore) ──────────
    readonly property bool panelBlurEnabled: SettingsStore.blurEnabled
    readonly property real panelBlurStrength: SettingsStore.blurStrength
    readonly property real shellOpacity:     SettingsStore.shellOpacity

    // ─── Panel preferred widths ──────────────────────────────────
    // Three base widths capture the design intent.
    // Individual panels reference these via semantic aliases.
    // panelFullWidth is live from SettingsStore.

    readonly property real panelFullWidth:    SettingsStore.panelMaxWidth
    readonly property real panelCompactWidth: 340                     // narrower panels (CC, calendar, audio)
    readonly property real panelMediumWidth:  440                     // browsing and rich-content panels
    readonly property real panelNarrowWidth:  280                     // minimal panels (power menu)

    readonly property real launcherWidth:           panelFullWidth    // live
    readonly property real controlCenterWidth:      panelCompactWidth // 340
    // Theme selection is a compact palette popover, not a browser panel.
    readonly property real themeSwitcherWidth:      420
    // Wallpaper browsing benefits from a wide, two-row thumbnail tray.
    readonly property real wallpaperSelectorWidth:  720
    readonly property real notificationCenterWidth: panelFullWidth    // live
    readonly property real mediaPlayerWidth:        panelCompactWidth
    readonly property real calendarWidth:           panelCompactWidth // 340
    readonly property real bluetoothWidth:          panelCompactWidth // 340
    readonly property real wifiWidth:               panelFullWidth    // live
    readonly property real audioWidth:              panelCompactWidth // 340
    readonly property real powerMenuWidth:          panelNarrowWidth  // 280

    // ─── Settings window ─────────────────────────────────────────
    readonly property real settingsDefaultWidth:  Spacing.settings.defaultW   // 576
    readonly property real settingsDefaultHeight: Spacing.settings.defaultH   // 432
    readonly property real settingsMinWidth:      Spacing.settings.minWindowW // 336
    readonly property real settingsMinHeight:     Spacing.settings.minWindowH // 288
    readonly property real sidebarWidth:          Spacing.settings.sidebarWidth // 80

    // ─── Common dimensions ───────────────────────────────────────
    readonly property real searchFieldHeight: Spacing.input.height    // 36
    readonly property real cardSpacing:       Spacing.panel.gap       // 12 — between ControlCenter cards
    readonly property real panelPadding:      SettingsStore.panelPadding // live
}
