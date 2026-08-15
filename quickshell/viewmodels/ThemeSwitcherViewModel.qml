import QtQuick

import qs.state
import qs.tokens
import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  ThemeSwitcherViewModel
    //
    //  Presentation adapter for the ThemeSwitcher panel.
    //  Uses the built-in palette registry (Colors.availableThemes)
    //  as the source of truth for theme listing — no dependency on
    //  ~/.local/bin/theme-list. Palette colors are read directly from
    //  the palette singletons via Colors.paletteForKey(), so each card
    //  previews the theme's actual accent/bg/surface colors.
    //
    //  Theme application still routes through
    //  ThemeState.setSystemThemeRequested → ThemeService →
    //  ~/.local/bin/theme-switcher, which applies the system-wide theme
    //  (Hyprland colors, GTK, waybar, rofi, ghostty, nvim, …).
    //  ThemeService resolves the lowercase palette key to the real
    //  directory name that theme-switcher requires (case-sensitive match).
    //
    //  • Reads:  Colors, SettingsStore, ThemeState (action sink)
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  actions through State signals
    // ═══════════════════════════════════════════════════════════════

    // ── Available themes (formatted for display) ────────────────────
    readonly property var themes: _formatThemes()

    function _formatThemes() {
        // Source of truth: Colors.availableThemes (always available,
        // no external script dependency). Each palette singleton
        // provides the real accent/bg/surface colors for the card preview.
        var out = []
        var available = Colors.availableThemes
        for (var i = 0; i < available.length; i++) {
            var t = available[i]
            var pal = Colors.paletteForKey(t.key)
            out.push({
                key: t.key,                              // lowercase palette key
                label: t.label,                          // display name (e.g. "Catppuccin Mocha")
                primaryColor: pal ? pal.accent : Colors.accent,
                bgColor: pal ? pal.bg : Colors.bg,
                surfaceColor: pal ? pal.surface : Colors.surface,
                onSurfaceColor: pal ? pal.fg : Colors.fg,
                selected: SettingsStore.theme === t.key
            })
        }
        return out
    }

    // ── Actions ────────────────────────────────────────────────────
    // Passes the lowercase palette key; ThemeService resolves it to the
    // real theme directory name (e.g. "gruvbox" → "Gruvbox") before
    // invoking theme-switcher.
    function selectTheme(themeKey) {
        ThemeState.setSystemThemeRequested(themeKey)
    }
}
