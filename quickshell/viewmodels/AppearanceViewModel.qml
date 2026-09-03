import QtQuick

import qs.state
import qs.settings
import qs.tokens

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  AppearanceViewModel
    //
    //  Presentation adapter for Appearance, Theme, and Wallpaper
    //  settings pages. Reads SettingsStore for persistent values
    //  and ThemeState/WallpaperState for available options.
    //  All mutations write to SettingsStore (never to runtime state
    //  directly — ConfigService bridges one-way at startup).
    //
    //  • Reads:  SettingsStore, ThemeState, Colors, WallpaperState
    //  • Writes: SettingsStore only
    //  • Emits:  nothing (actions write SettingsStore directly)
    // ═══════════════════════════════════════════════════════════════

    // ═══════════════════════════════════════════════════════════════
    //  APPEARANCE PAGE
    // ═══════════════════════════════════════════════════════════════

    // ── Current theme (formatted) ──────────────────────────────────
    readonly property string currentThemeKey: SettingsStore.theme
    readonly property string currentThemeLabel: _themeLabelByKey(SettingsStore.theme)

    // ── Current wallpaper ──────────────────────────────────────────
    readonly property string currentWallpaper: SettingsStore.wallpaper

    // ── Opacity ────────────────────────────────────────────────────
    readonly property real shellOpacity: SettingsStore.shellOpacity
    readonly property string shellOpacityText: Math.round(SettingsStore.shellOpacity * 100) + "%"

    // ── Animations ─────────────────────────────────────────────────
    readonly property bool animationsEnabled: SettingsStore.animationsEnabled
    readonly property real animationSpeed: SettingsStore.animationSpeed
    readonly property string animationSpeedText: SettingsStore.animationSpeed.toFixed(1) + "×"

    // ── Appearance actions (write to SettingsStore) ────────────────
    function setShellOpacity(val)    { SettingsStore.shellOpacity = val }
    function setAnimationsEnabled(val) { SettingsStore.animationsEnabled = val }
    function setAnimationSpeed(val)  { SettingsStore.animationSpeed = val }

    // ═══════════════════════════════════════════════════════════════
    //  THEME PAGE
    // ═══════════════════════════════════════════════════════════════

    // ── Available themes (formatted for ThemeCard grid) ────────────
    // Uses ThemeState.systemThemes — the REAL system themes from
    // ~/.local/bin/theme-list — so the settings page matches the
    // Super+T panel and applies via theme-switcher.
    readonly property var themes: _formatThemes()

    function _formatThemes() {
        var raw = ThemeState.systemThemes
        var out = []
        for (var i = 0; i < raw.length; i++) {
            // Real palette for this theme (lowercase key → singleton),
            // so each card previews the theme's actual colors.
            var pal = Colors.paletteForKey(raw[i].name.toLowerCase())
            out.push({
                key: raw[i].name || "",
                label: raw[i].name || "",
                primaryColor: raw[i].color || (pal ? pal.accent : Colors.accent),
                bgColor: pal ? pal.bg : Colors.bg,
                surfaceColor: pal ? pal.surface : Colors.surface,
                onSurfaceColor: pal ? pal.fg : Colors.fg,
                selected: raw[i].active || raw[i].name === ThemeState.systemTheme
            })
        }
        return out
    }

    // ── Theme actions ──────────────────────────────────────────────
    function selectTheme(themeName) {
        ThemeState.setSystemThemeRequested(themeName)
    }

    // ═══════════════════════════════════════════════════════════════
    //  WALLPAPER PAGE
    // ═══════════════════════════════════════════════════════════════

    // ── Available wallpapers (formatted for WallpaperCard grid) ────
    readonly property var wallpapers: _formatWallpapers()

    function _formatWallpapers() {
        var raw = WallpaperState.wallpapers
        var out = []
        for (var i = 0; i < raw.length; i++) {
            out.push({
                name: raw[i].name || "",
                thumbnail: raw[i].thumbnail || "",
                path: raw[i].path,
                selected: raw[i].path === SettingsStore.wallpaper
            })
        }
        return out
    }

    readonly property bool wallpapersEmpty: WallpaperState.wallpapers.length === 0

    // ── Wallpaper backend ──────────────────────────────────────────
    readonly property string wallpaperBackend: SettingsStore.wallpaperBackend

    readonly property var backendOptions: [
        { key: "awww",     label: "awww",     active: SettingsStore.wallpaperBackend === "awww" },
        { key: "swww",     label: "swww",     active: SettingsStore.wallpaperBackend === "swww" },
        { key: "hyprpaper", label: "hyprpaper", active: SettingsStore.wallpaperBackend === "hyprpaper" }
    ]

    // ── Wallpaper directory ────────────────────────────────────────
    readonly property string wallpaperDirectory: SettingsStore.wallpaperDirectory

    // ── Wallpaper actions ──────────────────────────────────────────
    function selectWallpaper(path) {
        SettingsStore.wallpaper = path
        // The live bridge in shell.qml propagates to WallpaperState
        // automatically. No direct call here — avoids double execution.
    }

    function setBackend(key) {
        SettingsStore.wallpaperBackend = key
        // The live bridge in shell.qml propagates to WallpaperState
        // automatically. No direct call here — avoids double execution.
    }

    function setWallpaperDirectory(path) {
        SettingsStore.wallpaperDirectory = path
    }

    function refreshWallpapers() {
        WallpaperState.refreshRequested()
    }

    // ═══════════════════════════════════════════════════════════════
    //  HELPERS
    // ═══════════════════════════════════════════════════════════════

    function _themeLabelByKey(key) {
        // Prefer real system themes (name matches by case-insensitive compare).
        var sys = ThemeState.systemThemes
        for (var i = 0; i < sys.length; i++) {
            if (sys[i].name.toLowerCase() === key.toLowerCase())
                return sys[i].name
        }
        var themes = ThemeState.availableThemes
        for (var i = 0; i < themes.length; i++) {
            if (themes[i].key === key)
                return themes[i].label || key
        }
        return key
    }
}
