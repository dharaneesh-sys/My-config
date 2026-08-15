pragma Singleton
import QtQuick

QtObject {
    id: store

    // ═══════════════════════════════════════════════════════════════
    //  SettingsStore
    //
    //  Owns every configurable preference that persists across
    //  sessions. Settings pages edit these properties.
    //  Runtime states observe SettingsStore where appropriate.
    //
    //  Runtime state is NOT persistent. SettingsStore IS persistent.
    //  Do not mix runtime state with configuration.
    //
    //  ConfigService loads/saves these via SettingsSerializer.
    //  Every property has a sensible default.
    // ═══════════════════════════════════════════════════════════════

    // ── Config version (for migration) ─────────────────────────────
    property int configVersion: 1

    // ═══════════════════════════════════════════════════════════════
    //  APPEARANCE
    // ═══════════════════════════════════════════════════════════════

    // ── Theme ──────────────────────────────────────────────────────
    // Pre-sync fallback. Used only in the brief window before
    // ThemeService mirrors ~/.cache/wallpaper/current_theme at startup,
    // or if config reload fails. Deliberately NOT "gruvbox" — that
    // palette's yellow accent (#d79221-class) is the exact fallback
    // that locked the shell to yellow when the live instance had not
    // yet re-synced after a theme-tool churn.
    property string theme: "catppuccin-mocha"

    // ── Wallpaper ─────────────────────────────────────────────────
    property string wallpaper: ""
    property string wallpaperBackend: "awww"         // awww (system uses matuwall/awww)

    // ── Blur ──────────────────────────────────────────────────────
    property bool blurEnabled: true
    property real blurStrength: 0.6                   // 0.0 – 1.0

    // ── Opacity ───────────────────────────────────────────────────
    property real shellOpacity: 1.0                   // 0.0 – 1.0

    // ── Animations ────────────────────────────────────────────────
    property bool animationsEnabled: true
    property real animationSpeed: 1.0                 // 0.5 – 2.0 (multiplier)

    // ═══════════════════════════════════════════════════════════════
    //  BAR & PILL
    // ═══════════════════════════════════════════════════════════════

    property real pillWidth: 136
    property real pillHeight: 48
    property real pillTopMargin: 12
    property real pillBottomMargin: 4
    property real pillCornerRadius: 9999              // 9999 = fully rounded

    // ═══════════════════════════════════════════════════════════════
    //  PANELS
    // ═══════════════════════════════════════════════════════════════

    property real panelMaxWidth: 420
    property real panelPadding: 16
    property real panelCornerRadius: 16
    property bool panelBlur: true

    // ═══════════════════════════════════════════════════════════════
    //  CONTROL CENTER
    // ═══════════════════════════════════════════════════════════════

    property bool ccShowQuickToggles: true
    property bool ccShowVolume: true
    property bool ccShowBrightness: true
    property bool ccShowMedia: true
    property bool ccShowNotifications: true
    property bool ccShowBattery: true

    // ═══════════════════════════════════════════════════════════════
    //  LAUNCHER
    // ═══════════════════════════════════════════════════════════════

    property int launcherMaxResults: 8
    property bool launcherShowDescriptions: true
    property string launcherDefaultAction: "launch"   // launch | terminal

    // ═══════════════════════════════════════════════════════════════
    //  NOTIFICATIONS
    // ═══════════════════════════════════════════════════════════════

    property string notificationPosition: "top-right"  // top-right | top-center | bottom-right | bottom-center
    property int notificationMaxVisible: 5
    property int notificationTimeout: 5000             // ms
    property bool notificationShowBody: true
    property bool notificationShowActions: true

    // ═══════════════════════════════════════════════════════════════
    //  MEDIA
    // ═══════════════════════════════════════════════════════════════

    property bool mediaShowAlbumArt: true
    property bool mediaShowProgress: true
    property string mediaPreferredPlayer: ""           // empty = auto

    // ═══════════════════════════════════════════════════════════════
    //  CLOCK & DATE
    // ═══════════════════════════════════════════════════════════════

    property bool clockUse24h: true
    property bool clockShowSeconds: false
    property string clockTimezone: ""                 // empty = system default
    property string clockDateFormat: "long"           // long | short | iso
    property bool clockShowInPill: true

    // ═══════════════════════════════════════════════════════════════
    //  AUDIO
    // ═══════════════════════════════════════════════════════════════

    property int audioStepPercent: 5                  // volume step per scroll/click
    property bool audioShowInput: true

    // ═══════════════════════════════════════════════════════════════
    //  BRIGHTNESS
    // ═══════════════════════════════════════════════════════════════

    property int brightnessStepPercent: 5
    property bool nightLightEnabled: false

    // ═══════════════════════════════════════════════════════════════
    //  NETWORK
    // ═══════════════════════════════════════════════════════════════

    property bool wifiAutoConnect: true

    // ═══════════════════════════════════════════════════════════════
    //  POWER
    // ═══════════════════════════════════════════════════════════════

    property int powerAutoSuspendMinutes: 0           // 0 = disabled
    property int powerAutoScreenOffMinutes: 0         // 0 = disabled
    property bool powerShowBatteryInCC: true

    // ═══════════════════════════════════════════════════════════════
    //  MOTION / TRANSITIONS
    // ═══════════════════════════════════════════════════════════════

    // Spring feel: stiffness drives how fast the geometry snaps back,
    // damping how quickly oscillation dies. 0.85 was under-damped → the
    // pill/panel visibly bounced (jittery). 1.4 settles in ~2 springs
    // with a hint of life instead of overshoot-forever.
    property real springDamping: 1.4
    property real springStiffness: 2.4
    property int expandDuration: 300                  // ms
    property int collapseDuration: 300                // ms

    // ═══════════════════════════════════════════════════════════════
    //  KEYBINDS
    // ═══════════════════════════════════════════════════════════════

    property string keybindLauncher: "Super+Space"
    property string keybindThemeSwitcher: "Super+T"
    property string keybindWallpaperSelector: "Super+W"
    property string keybindNotificationCenter: "Super+N"
    property string keybindMedia: "Super+M"
    property string keybindSettings: "Super+Comma"

    // ═══════════════════════════════════════════════════════════════
    //  SYSTEM
    // ═══════════════════════════════════════════════════════════════

    property string wallpaperDirectory: "/home/dinusus/Pictures/Wallpapers" // same dir the GTK wallpaper-app browses

    // ═══════════════════════════════════════════════════════════════
    //  WINDOW STATE
    // ═══════════════════════════════════════════════════════════════

    property real settingsX: -1
    property real settingsY: -1
    property real settingsW: 800
    property real settingsH: 600
    property string settingsPageId: ""

    // ═══════════════════════════════════════════════════════════════
    //  DIRTY TRACKING
    // ═══════════════════════════════════════════════════════════════

    // Emitted whenever any property changes. ConfigService listens
    // and schedules a save (debounced).
    signal settingsChanged()

    // All writable properties connect here so any change
    // emits settingsChanged() for dirty tracking.
    Component.onCompleted: _connectAll()

    function _connectAll() {
        // Explicit list of persistent property names.
        // Object.keys(store) is unreliable — it returns JS engine
        // internals, not QML-declared properties, so many settings
        // would miss dirty-tracking signals.
        var props = [
            "theme", "wallpaper", "wallpaperBackend",
            "blurEnabled", "blurStrength", "shellOpacity",
            "animationsEnabled", "animationSpeed",
            "pillWidth", "pillHeight", "pillTopMargin", "pillBottomMargin", "pillCornerRadius",
            "panelMaxWidth", "panelPadding", "panelCornerRadius", "panelBlur",
            "ccShowQuickToggles", "ccShowVolume", "ccShowBrightness", "ccShowMedia",
            "ccShowNotifications", "ccShowBattery",
            "launcherMaxResults", "launcherShowDescriptions", "launcherDefaultAction",
            "notificationPosition", "notificationMaxVisible", "notificationTimeout",
            "notificationShowBody", "notificationShowActions",
            "mediaShowAlbumArt", "mediaShowProgress", "mediaPreferredPlayer",
            "clockUse24h", "clockShowSeconds", "clockTimezone", "clockDateFormat", "clockShowInPill",
            "audioStepPercent", "audioShowInput",
            "brightnessStepPercent", "nightLightEnabled",
            "wifiAutoConnect",
            "powerAutoSuspendMinutes", "powerAutoScreenOffMinutes", "powerShowBatteryInCC",
            "springDamping", "springStiffness", "expandDuration", "collapseDuration",
            "keybindLauncher", "keybindThemeSwitcher", "keybindWallpaperSelector",
            "keybindNotificationCenter", "keybindMedia", "keybindSettings",
            "wallpaperDirectory",
            "settingsX", "settingsY", "settingsW", "settingsH", "settingsPageId"
        ]
        for (var i = 0; i < props.length; i++) {
            var p = props[i]
            try {
                var sig = p + "Changed"
                store[sig].connect(store.settingsChanged)
            } catch(e) {}
        }
    }
}
