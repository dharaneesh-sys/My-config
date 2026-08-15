import QtQuick

import qs.settings
import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  SystemSettingsViewModel
    //
    //  Presentation adapter for the System settings page.
    //  Reads SettingsStore for config state. Wires actions to
    //  ConfigService (import/export/reset) and PowerState
    //  (shell management, diagnostics, power).
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore (reset only)
    //  • Routes: signals → PowerState / ConfigService
    // ═══════════════════════════════════════════════════════════════

    // ── Config ─────────────────────────────────────────────────────
    readonly property string configVersion: "v" + SettingsStore.configVersion

    // ── Actions: Configuration ────────────────────────────────────
    signal importRequested()
    signal exportRequested()
    signal resetRequested()

    // ── Actions: Diagnostics ──────────────────────────────────────
    signal reloadShellRequested()
    signal openConfigDirRequested()
    signal showLogsRequested()

    // ── Actions: Power ────────────────────────────────────────────
    signal restartShellRequested()
    signal quitShellRequested()

    // ═══════════════════════════════════════════════════════════════
    //  WIRING: connect UI signals to State/Service chain
    //  ViewModel → PowerState → PowerService → OS
    //  ViewModel → ConfigService → filesystem
    // ═══════════════════════════════════════════════════════════════

    onImportRequested:   ConfigService.importSettings(/* JSON from file picker — placeholder */)
    onExportRequested:   ConfigService.exportSettings()
    onResetRequested:    _resetToDefaults()

    onReloadShellRequested:   PowerState.reloadShellRequested()
    onOpenConfigDirRequested: PowerState.openConfigDirRequested()
    onShowLogsRequested:      PowerState.showLogsRequested()

    onRestartShellRequested:  PowerState.restartShellRequested()
    onQuitShellRequested:     PowerState.quitShellRequested()

    // ── Reset helper ──────────────────────────────────────────────
    function _resetToDefaults() {
        // Restore every SettingsStore property to its default.
        // ConfigService will persist the result via dirty tracking.
        SettingsStore.configVersion     = 1
        SettingsStore.theme             = "tokyo-night"
        SettingsStore.wallpaper         = ""
        SettingsStore.wallpaperBackend  = "swww"
        SettingsStore.blurEnabled       = true
        SettingsStore.blurStrength      = 0.6
        SettingsStore.shellOpacity      = 1.0
        SettingsStore.animationsEnabled = true
        SettingsStore.animationSpeed    = 1.0
        SettingsStore.pillWidth         = 136
        SettingsStore.pillHeight        = 48
        SettingsStore.pillTopMargin     = 12
        SettingsStore.pillBottomMargin  = 4
        SettingsStore.pillCornerRadius  = 9999
        SettingsStore.panelMaxWidth     = 420
        SettingsStore.panelPadding      = 16
        SettingsStore.panelCornerRadius = 16
        SettingsStore.panelBlur         = true
        SettingsStore.ccShowQuickToggles = true
        SettingsStore.ccShowVolume       = true
        SettingsStore.ccShowBrightness   = true
        SettingsStore.ccShowMedia        = true
        SettingsStore.ccShowNotifications = true
        SettingsStore.ccShowBattery      = true
        SettingsStore.launcherMaxResults      = 8
        SettingsStore.launcherShowDescriptions = true
        SettingsStore.launcherDefaultAction   = "launch"
        SettingsStore.notificationPosition   = "top-right"
        SettingsStore.notificationMaxVisible = 5
        SettingsStore.notificationTimeout    = 5000
        SettingsStore.notificationShowBody   = true
        SettingsStore.notificationShowActions = true
        SettingsStore.mediaShowAlbumArt    = true
        SettingsStore.mediaShowProgress    = true
        SettingsStore.mediaPreferredPlayer = ""
        SettingsStore.clockUse24h       = true
        SettingsStore.clockShowSeconds  = false
        SettingsStore.clockTimezone     = ""
        SettingsStore.clockDateFormat   = "long"
        SettingsStore.clockShowInPill   = true
        SettingsStore.audioStepPercent   = 5
        SettingsStore.audioShowInput     = true
        SettingsStore.brightnessStepPercent = 5
        SettingsStore.wifiAutoConnect    = true
        SettingsStore.powerAutoSuspendMinutes  = 0
        SettingsStore.powerAutoScreenOffMinutes = 0
        SettingsStore.powerShowBatteryInCC     = true
        SettingsStore.springDamping     = 0.7
        SettingsStore.springStiffness   = 1.5
        SettingsStore.expandDuration    = 300
        SettingsStore.collapseDuration  = 300
        SettingsStore.keybindLauncher           = "Super+Space"
        SettingsStore.keybindThemeSwitcher      = "Super+T"
        SettingsStore.keybindWallpaperSelector  = "Super+W"
        SettingsStore.keybindNotificationCenter = "Super+N"
        SettingsStore.keybindMedia              = "Super+M"
        SettingsStore.keybindSettings           = "Super+Comma"
        SettingsStore.wallpaperDirectory = ""
    }
}
