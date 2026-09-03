import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  KeybindsSettingsViewModel
    //
    //  Presentation adapter for the Keybinds settings page.
    //  Reads SettingsStore for keybind configuration values.
    //  Formats display labels. All mutations write to SettingsStore.
    //  Editing is placeholder-only — key capture UI is not yet
    //  implemented. Setter functions exist for future wiring.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Keybinds (read-through from SettingsStore) ─────────────────
    readonly property string launcher:           SettingsStore.keybindLauncher
    readonly property string themeSwitcher:      SettingsStore.keybindThemeSwitcher
    readonly property string wallpaperSelector:  SettingsStore.keybindWallpaperSelector
    readonly property string notificationCenter: SettingsStore.keybindNotificationCenter
    readonly property string media:             SettingsStore.keybindMedia
    readonly property string settings:          SettingsStore.keybindSettings
    readonly property string clipboard:         SettingsStore.keybindClipboard
    readonly property string lyrics:            SettingsStore.keybindLyrics

    // ── Editing state (placeholder) ────────────────────────────────
    // Tracks which keybind row is in "editing" mode.
    // Empty string means no row is editing.
    property string editingKey: ""

    // ── Display labels ─────────────────────────────────────────────
    readonly property var keybindEntries: [
        { key: "launcher",           title: "Launcher",           icon: "rocket_launch" },
        { key: "themeSwitcher",      title: "Theme Switcher",     icon: "contrast" },
        { key: "wallpaperSelector",  title: "Wallpaper Selector", icon: "wallpaper" },
        { key: "notificationCenter", title: "Notifications",      icon: "notifications" },
        { key: "media",             title: "Media",              icon: "music_note" },
        { key: "settings",          title: "Settings",           icon: "settings" },
        { key: "clipboard",         title: "Clipboard",          icon: "content_paste" },
        { key: "lyrics",            title: "Lyrics",             icon: "lyrics" }
    ]

    // ── Helper: read shortcut by key ──────────────────────────────
    function shortcut(key) {
        switch (key) {
        case "launcher":           return launcher
        case "themeSwitcher":      return themeSwitcher
        case "wallpaperSelector":  return wallpaperSelector
        case "notificationCenter": return notificationCenter
        case "media":             return media
        case "settings":          return settings
        case "clipboard":         return clipboard
        case "lyrics":            return lyrics
        default:                  return ""
        }
    }

    // ── Actions: start/stop editing (placeholder) ─────────────────
    function startEditing(key) {
        editingKey = key
    }

    function stopEditing() {
        editingKey = ""
    }

    // ── Actions: write keybind to SettingsStore ───────────────────
    // The KeybindsPage calls setShortcut(key, value) after key capture;
    // it dispatches to the per-key setters below.
    function setShortcut(key, value) {
        switch (key) {
        case "launcher":           return setLauncher(value)
        case "themeSwitcher":      return setThemeSwitcher(value)
        case "wallpaperSelector":  return setWallpaperSelector(value)
        case "notificationCenter": return setNotificationCenter(value)
        case "media":             return setMedia(value)
        case "settings":          return setSettingsKeybind(value)
        case "clipboard":         return setClipboard(value)
        case "lyrics":            return setLyrics(value)
        }
    }

    function setLauncher(value)            { SettingsStore.keybindLauncher = value }
    function setThemeSwitcher(value)       { SettingsStore.keybindThemeSwitcher = value }
    function setWallpaperSelector(value)   { SettingsStore.keybindWallpaperSelector = value }
    function setNotificationCenter(value)  { SettingsStore.keybindNotificationCenter = value }
    function setMedia(value)              { SettingsStore.keybindMedia = value }
    function setSettingsKeybind(value)    { SettingsStore.keybindSettings = value }
    function setClipboard(value)          { SettingsStore.keybindClipboard = value }
}
