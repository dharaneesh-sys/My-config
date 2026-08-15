pragma Singleton
import QtQuick

import qs.tokens

QtObject {
    id: themeState

    // ═══════════════════════════════════════════════════════════════
    //  ThemeState
    //
    //  Reactive theme properties. Synced with frozen Theme/Colors.
    //  Written by ThemeService (persistence).
    // ═══════════════════════════════════════════════════════════════

    // ── Current theme ──────────────────────────────────────────────
    // Mirrors Theme.current from the frozen token system.
    property int currentTheme: Theme.current
    readonly property string currentKey: Colors.key
    readonly property string currentLabel: Colors.label

    // ── Available themes ───────────────────────────────────────────
    // Delegates to Colors.availableThemes from the frozen system.
    readonly property var availableThemes: Colors.availableThemes

    // ── Dark mode ──────────────────────────────────────────────────
    readonly property bool isDark: Colors.isDark

    // ── Real system theme ──────────────────────────────────────────
    // The shell's own palette (above) is synced to the system theme
    // by ThemeService. These two properties mirror the REAL system
    // theme — the one theme-switcher applies system-wide — whose
    // source of truth is ~/.cache/wallpaper/current_theme.
    property string systemTheme: ""         // e.g. "Catppuccin-Mocha"
    property var systemThemes: []           // [{name, color, icon, active}]

    // ── Actions ────────────────────────────────────────────────────
    signal setThemeRequested(int theme)
    signal setSystemThemeRequested(string name)
    signal nextRequested()
    signal previousRequested()
}
