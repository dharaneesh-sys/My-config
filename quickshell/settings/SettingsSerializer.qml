pragma Singleton
import QtQuick

QtObject {
    id: serializer

    // ═══════════════════════════════════════════════════════════════
    //  SettingsSerializer
    //
    //  Converts SettingsStore ↔ JSON for persistence.
    //
    //  Two operations:
    //    serialize(store) → JSON string
    //    deserialize(json, store) → applies values to store
    //
    //  Only known keys are written/read. Unknown keys in the
    //  JSON file are preserved (not deleted) to support
    //  forward-compatible config files.
    //
    //  Does NOT touch the filesystem — that is ConfigService's job.
    // ═══════════════════════════════════════════════════════════════

    // ── Known property names (whitelist) ────────────────────────────
    readonly property var _knownKeys: [
        "configVersion",
        // Appearance
        "theme",
        "wallpaper",
        "wallpaperBackend",
        "blurEnabled",
        "blurStrength",
        "shellOpacity",
        "animationsEnabled",
        "animationSpeed",
        // Bar & Pill
        "pillWidth",
        "pillHeight",
        "pillTopMargin",
        "pillBottomMargin",
        "pillCornerRadius",
        // Panels
        "panelMaxWidth",
        "panelPadding",
        "panelCornerRadius",
        "panelBlur",
        // Control Center
        "ccShowQuickToggles",
        "ccShowVolume",
        "ccShowBrightness",
        "ccShowMedia",
        "ccShowNotifications",
        "ccShowBattery",
        // Launcher
        "launcherMaxResults",
        "launcherShowDescriptions",
        "launcherDefaultAction",
        // Notifications
        "notificationPosition",
        "notificationMaxVisible",
        "notificationTimeout",
        "notificationShowBody",
        "notificationShowActions",
        // Media
        "mediaShowAlbumArt",
        "mediaShowProgress",
        "mediaPreferredPlayer",
        // Clock & Date
        "clockUse24h",
        "clockShowSeconds",
        "clockTimezone",
        "clockDateFormat",
        "clockShowInPill",
        // Audio
        "audioStepPercent",
        "audioShowInput",
        // Brightness
        "brightnessStepPercent",
        "nightLightEnabled",
        // Network
        "wifiAutoConnect",
        // Power
        "powerAutoSuspendMinutes",
        "powerAutoScreenOffMinutes",
        "powerShowBatteryInCC",
        // Motion
        "springDamping",
        "springStiffness",
        "expandDuration",
        "collapseDuration",
        // Keybinds
        "keybindLauncher",
        "keybindThemeSwitcher",
        "keybindWallpaperSelector",
        "keybindNotificationCenter",
        "keybindMedia",
        "keybindSettings",
        // System
        "wallpaperDirectory",
        // Window state
        "settingsX",
        "settingsY",
        "settingsW",
        "settingsH",
        "settingsPageId"
    ]

    // ═══════════════════════════════════════════════════════════════
    //  SERIALIZE:  SettingsStore → JSON string
    // ═══════════════════════════════════════════════════════════════

    function serialize(store) {
        var obj = {}
        for (var i = 0; i < _knownKeys.length; i++) {
            var key = _knownKeys[i]
            try {
                obj[key] = store[key]
            } catch(e) {
                // Property not found — skip
            }
        }
        return JSON.stringify(obj, null, 2)
    }

    // ═══════════════════════════════════════════════════════════════
    //  DESERIALIZE:  JSON string → SettingsStore
    // ═══════════════════════════════════════════════════════════════

    function deserialize(jsonString, store) {
        var obj
        try {
            obj = JSON.parse(jsonString)
        } catch(e) {
            console.warn("SettingsSerializer: invalid JSON — " + e.message)
            return false
        }

        if (typeof obj !== "object" || obj === null) {
            console.warn("SettingsSerializer: parsed value is not an object")
            return false
        }

        var applied = 0
        for (var i = 0; i < _knownKeys.length; i++) {
            var key = _knownKeys[i]
            if (key in obj) {
                try {
                    store[key] = obj[key]
                    applied++
                } catch(e) {
                    console.warn("SettingsSerializer: failed to set '" + key + "' — " + e.message)
                }
            }
        }

        console.info("SettingsSerializer: applied " + applied + " settings from config")
        return true
    }

    // ═══════════════════════════════════════════════════════════════
    //  VALIDATE:  Check a JSON string has known keys
    // ═══════════════════════════════════════════════════════════════

    function validate(jsonString) {
        var obj
        try {
            obj = JSON.parse(jsonString)
        } catch(e) {
            return { valid: false, error: "Invalid JSON: " + e.message }
        }

        var known = 0
        var unknown = 0
        var keys = Object.keys(obj)
        for (var i = 0; i < keys.length; i++) {
            if (_knownKeys.indexOf(keys[i]) !== -1)
                known++
            else
                unknown++
        }

        return {
            valid: true,
            knownKeys: known,
            unknownKeys: unknown,
            totalKeys: keys.length
        }
    }
}
