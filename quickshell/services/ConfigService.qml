import Quickshell
import QtQuick
import Quickshell.Io

import qs.settings
import qs.state
import qs.tokens

Item {
    id: configService

    // ═══════════════════════════════════════════════════════════════
    //  ConfigService
    //
    //  Loads configuration at startup. Saves on change (debounced).
    //  Creates defaults if no config file exists.
    //  Handles version migration.
    //  Supports import/export.
    //
    //  Flow:
    //    startup → FileView reads disk → JsonAdapter populated → push to SettingsStore
    //    SettingsStore.settingsChanged → debounced push to JsonAdapter → writeAdapter()
    //
    //  Uses Quickshell.Io FileView + JsonAdapter (atomic writes, no shell).
    //  JsonAdapter LOADS automatically; writes are explicit via
    //  writeAdapter() — verified empirically (0.3.0 does not auto-write).
    // ═══════════════════════════════════════════════════════════════

    // ── Config file path ───────────────────────────────────────────
    // Set this from shell.qml before Component.onCompleted fires.
    property string configPath: ""

    // ── Internal state ─────────────────────────────────────────────
    property bool _loaded: false

    // ── Debounce interval (ms) ─────────────────────────────────────
    readonly property int _debounceMs: 500

    // ═══════════════════════════════════════════════════════════════
    //  DISK VIEW (single source of file truth)
    //
    //  The JsonAdapter declares one typed property per persistent
    //  setting. Keys must match SettingsSerializer._knownKeys and
    //  SettingsStore property names exactly.
    // ═══════════════════════════════════════════════════════════════

    FileView {
        id: configFile
        path: configService.configPath
        preload: true
        atomicWrites: true
        printErrors: true

        onLoaded: function() { configService._pullFromDisk() }
        onLoadFailed: function(error) { configService._onLoadFailed(error) }

        JsonAdapter {
            id: disk

            // ── Config version ────────────────────────────────
            property int configVersion: 1

            // ── Appearance ────────────────────────────────────
            property string theme: "catppuccin-mocha"
            property string wallpaper: ""
            property string wallpaperBackend: "awww"
            property real shellOpacity: 1.0
            property bool animationsEnabled: true
            property real animationSpeed: 1.0

            // ── Bar & Pill ────────────────────────────────────
            property real pillWidth: 136
            property real pillHeight: 48
            property real pillTopMargin: 12
            property real pillBottomMargin: 4
            property real pillCornerRadius: 9999

            // ── Panels ────────────────────────────────────────
            property real panelMaxWidth: 420
            property real panelPadding: 16
            property real panelCornerRadius: 16
            property bool notchEnabled: false

            // ── Control Center ────────────────────────────────
            property bool ccShowQuickToggles: true
            property bool ccShowVolume: true
            property bool ccShowBrightness: true
            property bool ccShowMedia: true
            property bool ccShowNotifications: true
            property bool ccShowBattery: true

            // ── Launcher ──────────────────────────────────────
            property int launcherMaxResults: 8
            property bool launcherShowDescriptions: true
            property string launcherDefaultAction: "launch"
            property string launcherUsage: "{}"

            // ── Notifications ─────────────────────────────────
            property string notificationPosition: "top-right"
            property int notificationMaxVisible: 5
            property int notificationTimeout: 5000
            property bool notificationShowBody: true
            property bool notificationShowActions: true

            // ── Media ─────────────────────────────────────────
            property bool mediaShowAlbumArt: true
            property bool mediaShowProgress: true
            property string mediaPreferredPlayer: ""

            // ── Clock & Date ──────────────────────────────────
            property bool clockUse24h: true
            property bool clockShowSeconds: false
            property string clockTimezone: ""
            property string clockDateFormat: "long"
            property bool clockShowInPill: true

            // ── Audio ─────────────────────────────────────────
            property int audioStepPercent: 5
            property bool audioShowInput: true

            // ── Brightness ────────────────────────────────────
            property int brightnessStepPercent: 5
            property bool nightLightEnabled: false

            // ── Network ───────────────────────────────────────
            property bool wifiAutoConnect: true

            // ── Power ─────────────────────────────────────────
            property int powerAutoSuspendMinutes: 0
            property int powerAutoScreenOffMinutes: 0
            property bool powerShowBatteryInCC: true

            // ── Motion / Transitions ──────────────────────────
            property real springDamping: 0.85
            property real springStiffness: 3.0
            property int expandDuration: 300
            property int collapseDuration: 300

            // ── Keybinds ──────────────────────────────────────
            property string keybindLauncher: "Super+Space"
            property string keybindThemeSwitcher: "Super+T"
            property string keybindWallpaperSelector: "Super+W"
            property string keybindNotificationCenter: "Super+N"
            property string keybindMedia: "Super+M"
            property string keybindSettings: "Super+Comma"

            // ── System ────────────────────────────────────────
            property string wallpaperDirectory: "/home/dinusus/Pictures/Wallpapers"

            // ── Window state ──────────────────────────────────
            property real settingsX: -1
            property real settingsY: -1
            property real settingsW: 800
            property real settingsH: 600
            property string settingsPageId: ""
        }
    }

    // ═══════════════════════════════════════════════════════════════
    //  LOAD (disk → adapter → SettingsStore)
    // ═══════════════════════════════════════════════════════════════

    function _pullFromDisk() {
        var keys = SettingsSerializer._knownKeys
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i]
            // Only copy keys the adapter declares (protects against
            // newer config files with unknown keys).
            if (typeof disk[k] === "undefined") continue
            SettingsStore[k] = disk[k]
        }

        _loaded = true

        // Version migration
        _migrate()

        _applyToRuntime()

        console.info("ConfigService: loaded from " + configPath)
    }

    function _onLoadFailed(error) {
        // Guard: configPath may not be bound yet when FileView first
        // evaluates its path (shell.qml wires it at construction).
        if (configPath === "") return

        console.info("ConfigService: config file missing/unreadable — creating defaults")
        // SettingsStore already has defaults. Persist them so the
        // file exists on disk for the next session.
        _loaded = true
        _applyToRuntime()
        _pushToDisk()
    }

    // ═══════════════════════════════════════════════════════════════
    //  SAVE (SettingsStore → adapter → disk, debounced)
    // ═══════════════════════════════════════════════════════════════

    Timer {
        id: saveDebounce
        interval: configService._debounceMs
        onTriggered: configService._pushToDisk()
    }

    function _scheduleSave() {
        if (!_loaded) return
        saveDebounce.restart()
    }

    function _pushToDisk() {
        // Canonical key list lives in SettingsSerializer._knownKeys —
        // add new settings there AND to the JsonAdapter above.
        if (configPath === "") return
        var keys = SettingsSerializer._knownKeys
        for (var i = 0; i < keys.length; i++) {
            var k = keys[i]
            if (typeof disk[k] === "undefined") continue
            disk[k] = SettingsStore[k]
        }
        configFile.writeAdapter()
    }

    // ═══════════════════════════════════════════════════════════════
    //  VERSION MIGRATION
    // ═══════════════════════════════════════════════════════════════

    function _migrate() {
        var version = SettingsStore.configVersion

        if (version < 1) {
            // No migration needed — version 1 is the initial schema.
        }

        // Future migrations go here:
        // if (version < 2) { ... migrate v1 → v2 ... }
        // if (version < 3) { ... migrate v2 → v3 ... }

        // Ensure version is up-to-date after all migrations
        if (SettingsStore.configVersion !== _currentVersion) {
            SettingsStore.configVersion = _currentVersion
        }
    }

    readonly property int _currentVersion: 1

    // ═══════════════════════════════════════════════════════════════
    //  APPLY TO RUNTIME
    // ═══════════════════════════════════════════════════════════════
    //  Push persisted settings into runtime State singletons
    //  that need to observe them. This is one-way:
    //    SettingsStore → Runtime State
    //  Runtime state changes do NOT write back to SettingsStore
    //  (that would be the settings page's job).
    // ═══════════════════════════════════════════════════════════════

    function _applyToRuntime() {
        // ── Theme → Colors/ThemeState ─────────────────────────
        var themeKey = SettingsStore.theme
        var themes = Colors.availableThemes
        for (var i = 0; i < themes.length; i++) {
            if (themes[i].key === themeKey) {
                Theme.setTheme(themes[i].value)
                ThemeState.currentTheme = themes[i].value
                break
            }
        }

        // ── Wallpaper → WallpaperState ────────────────────────
        WallpaperState.backend = SettingsStore.wallpaperBackend
        if (SettingsStore.wallpaper !== "")
            WallpaperState.setWallpaperRequested(SettingsStore.wallpaper)

        // ── Clock → ClockState ────────────────────────────────
        ClockState.use24h = SettingsStore.clockUse24h
        ClockState.showSeconds = SettingsStore.clockShowSeconds
        ClockState.timezone = SettingsStore.clockTimezone
        ClockState.dateFormat = SettingsStore.clockDateFormat

        // ── ShellMetrics is live-bound to SettingsStore ───────
        // No explicit bridge needed — pill/panel dimensions,
        // blur, opacity, animation durations are all reactive
        // via ShellMetrics → SettingsStore bindings.
    }

    // ═══════════════════════════════════════════════════════════════
    //  IMPORT / EXPORT
    // ═══════════════════════════════════════════════════════════════

    /** Export current settings as a JSON string. */
    function exportSettings() {
        return SettingsSerializer.serialize(SettingsStore)
    }

    /** Import settings from a JSON string. Returns true on success. */
    function importSettings(jsonString) {
        var validation = SettingsSerializer.validate(jsonString)
        if (!validation.valid) {
            console.warn("ConfigService: import failed — " + validation.error)
            return false
        }

        var ok = SettingsSerializer.deserialize(jsonString, SettingsStore)
        if (ok) {
            _migrate()
            _applyToRuntime()
            _pushToDisk()
        }
        return ok
    }

    // ═══════════════════════════════════════════════════════════════
    //  OBSERVE SETTINGS STORE CHANGES
    // ═══════════════════════════════════════════════════════════════

    Connections {
        target: SettingsStore

        function onSettingsChanged() {
            configService._scheduleSave()
        }
    }
}
