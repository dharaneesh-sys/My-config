import Quickshell
import QtCore
import QtQuick
import Quickshell.Io

import qs.tokens
import qs.state
import qs.settings

Item {
    id: themeService

    // ═══════════════════════════════════════════════════════════════
    //  ThemeService
    //
    //  Bridges the shell to the real system theme tooling:
    //    theme-list      → JSON lines {name,color,icon,active} per theme
    //    theme-switcher  → applies a theme system-wide (Hyprland colors,
    //                      GTK, waybar, rofi, ghostty, nvim, tmux, …)
    //
    //  theme-switcher's own usage text says "GUI from Quickshell" —
    //  the script was built to be driven from this shell. This service
    //  is that driver: it lists real themes for the picker and applies
    //  the real system theme (not just the shell's frozen palette).
    //
    //  The source of truth for the ACTIVE theme is
    //  ~/.cache/wallpaper/current_theme (written by theme-switcher).
    //  We watch it and mirror into ThemeState + the frozen token
    //  system so the shell's own colors follow the desktop theme.
    // ═══════════════════════════════════════════════════════════════

    // Plain path, NOT a URL: StandardPaths.writableLocation stringifies
    // as "file:///home/..." in this build, which breaks Process argv
    // (find, mkdir) and shell scripts. Quickshell.env returns a plain
    // path — the same source IconRegistry uses.
    readonly property string home: Quickshell.env("HOME")
    readonly property string cacheDir: home + "/.cache/wallpaper"
    readonly property string currentThemeFile: cacheDir + "/current_theme"
    readonly property string colorsConfFile: home + "/.config/hypr/colors.conf"
    readonly property string themeListScript: home + "/.local/bin/theme-list"
    readonly property string themeSwitcherScript: home + "/.local/bin/theme-switcher"
    // `current_theme` is the canonical cache. colors.conf is only a
    // startup fallback and must never win a later asynchronous race.
    property bool hasCurrentThemeCache: false

    // ── Read real themes from theme-list ───────────────────────────
    Process {
        id: listThemes
        command: [themeService.themeListScript]
        stdout: StdioCollector { id: listThemesOut }
        onExited: (code, status) => {
            if (code !== 0) return
            var themes = themeService._parseThemeList(listThemesOut.text)
            ThemeState.systemThemes = themes
        }
    }

    function _parseThemeList(text) {
        var out = []
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line) continue
            try {
                var obj = JSON.parse(line)
                out.push({
                    name: obj.name || "",
                    color: obj.color || "",
                    icon: obj.icon || "",
                    active: obj.active === true
                })
            } catch(e) {}
        }
        return out
    }

    // ── Apply a real theme via theme-switcher ──────────────────────
    Process {
        id: applyTheme
        command: []
        onExited: (code, status) => {
            if (code !== 0) {
                console.warn("ThemeService: theme-switcher failed with code " + code)
                // Revert the optimistic SettingsStore.theme write: the
                // script only writes current_theme on success, so re-sync
                // from that file to keep persisted state truthful.
                themeService._syncFromFile(currentThemeView.text())
            }
            themeService.refreshThemes()
        }
    }

    function applySystemTheme(name) {
        if (!name) return
        // Optimistically update the shell + state; the script rewrites
        // current_theme and our FileView watcher confirms/refines it.
        _syncFromName(name)
        applyTheme.command = [themeSwitcherScript, name]
        applyTheme.running = true
    }

    // ── Watch current_theme cache (external truth) ─────────────────
    FileView {
        id: currentThemeView
        path: themeService.currentThemeFile
        preload: true
        watchChanges: true
        onFileChanged: currentThemeView.reload()
        onLoaded: themeService._syncFromFile(currentThemeView.text())
    }

    // ── Read matugen's colors.conf (startup fallback) ──────────────
    // matugen writes the applied theme as the first comment line:
    //   "# Theme: Gruvbox"
    // Sourced once at startup so the shell follows the system theme
    // even if the current_theme cache is missing.
    FileView {
        id: colorsConfView
        path: themeService.colorsConfFile
        preload: true
        onLoaded: {
            if (!themeService.hasCurrentThemeCache)
                themeService._syncFromColorsConf(colorsConfView.text())
        }
    }

    function _syncFromColorsConf(text) {
        var m = text.match(/^#\s*Theme:\s*(.+)$/m)
        if (m) themeService._syncFromName(m[1].trim())
    }

    function _syncFromFile(text) {
        var name = text.trim()
        if (name === "") return
        hasCurrentThemeCache = true
        _syncFromName(name)
    }

    function _syncFromName(name) {
        ThemeState.systemTheme = name
        var key = _nameToKey(name)

        // Mirror into the frozen token system so shell colors follow.
        var themes = Colors.availableThemes
        for (var i = 0; i < themes.length; i++) {
            if (themes[i].key === key) {
                Theme.setTheme(themes[i].value)
                ThemeState.currentTheme = themes[i].value
                break
            }
        }

        // Persist as the shell's configured theme (lowercase key).
        if (SettingsStore.theme !== key)
            SettingsStore.theme = key
    }

    function _nameToKey(name) {
        return name.toLowerCase()
    }

    // Real theme name for a lowercase key ("catppuccin-mocha" →
    // "Catppuccin-Mocha"). Empty string if not found — callers must
    // skip apply then (theme-switcher validates dir names case-sensitively).
    function _nameFromKey(key) {
        // First try the systemThemes list (if theme-list has populated it)
        var list = ThemeState.systemThemes
        for (var i = 0; i < list.length; i++) {
            if (list[i].name.toLowerCase() === key)
                return list[i].name
        }

        // Fallback: use the known kebab-case → PascalCase mapping
        // so theme switching works even when theme-list hasn't run yet.
        // The directory names in ~/.config/hypr/themes/ are case-sensitive:
        // "gruvbox" → "Gruvbox", "catppuccin-mocha" → "Catppuccin-Mocha"
        var mapping = {
            "ariadne": "Ariadne",
            "catppuccin-macchiato": "Catppuccin-Macchiato",
            "catppuccin-mocha": "Catppuccin-Mocha",
            "dracula": "Dracula",
            "dynamic": "Dynamic",
            "everforest": "Everforest",
            "gruvbox": "Gruvbox",
            "nightfox": "Nightfox",
            "noir": "Noir",
            "nord": "Nord",
            "rose-pine": "Rose-Pine",
            "solarized-dark": "Solarized-Dark",
            "tokyo-night": "Tokyo-Night"
        }
        return mapping[key] || ""
    }

    function refreshThemes() {
        listThemes.running = true
    }

    // ── Cycle next/previous through real themes ────────────────────
    function _cycleThemes() {
        // theme-list is asynchronous. The Control Center can be opened
        // before it returns, so retain a complete in-process fallback and
        // never leave the Theme tile as a no-op during startup.
        if (ThemeState.systemThemes.length > 0)
            return ThemeState.systemThemes

        var fallback = []
        var palettes = Colors.availableThemes
        for (var i = 0; i < palettes.length; i++) {
            var name = _nameFromKey(palettes[i].key)
            if (name !== "")
                fallback.push({ name: name })
        }
        return fallback
    }

    function next() {
        var list = _cycleThemes()
        if (list.length === 0) return
        var idx = _currentIndex(list)
        var nextIdx = (idx + 1) % list.length
        applySystemTheme(list[nextIdx].name)
    }

    function previous() {
        var list = _cycleThemes()
        if (list.length === 0) return
        var idx = _currentIndex(list)
        var prevIdx = (idx - 1 + list.length) % list.length
        applySystemTheme(list[prevIdx].name)
    }

    function _currentIndex(list) {
        for (var i = 0; i < list.length; i++) {
            if (list[i].name === ThemeState.systemTheme)
                return i
        }
        return 0
    }

    Connections {
        target: ThemeState
        function onSetThemeRequested(t) {
            // Legacy int-based request — resolve to the REAL theme name
            // (directory name), not the display label: theme-switcher
            // matches against ~/.config/hypr/themes/<name>/.
            var themes = Colors.availableThemes
            for (var i = 0; i < themes.length; i++) {
                if (themes[i].value === t) {
                    var name = themeService._nameFromKey(themes[i].key)
                    if (name !== "") themeService.applySystemTheme(name)
                    return
                }
            }
        }
        function onSetSystemThemeRequested(keyOrName) {
            // Accept either a lowercase palette key ("gruvbox") or a real
            // theme directory name ("Gruvbox"). ThemeService._nameFromKey
            // resolves keys via the systemThemes list; if the lookup fails
            // (e.g. theme-list unavailable), fall back to the raw string —
            // theme-switcher will reject it with a notification rather than
            // silently applying the wrong theme.
            var name = themeService._nameFromKey(keyOrName)
            themeService.applySystemTheme(name || keyOrName)
        }
        function onNextRequested() { themeService.next() }
        function onPreviousRequested() { themeService.previous() }
    }

    // Keep the shell's active label in sync even when nothing else fires.
    Component.onCompleted: {
        refreshThemes()
    }
}
