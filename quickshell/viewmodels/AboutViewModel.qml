import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  AboutViewModel
    //
    //  Presentation adapter for the About settings page.
    //  Reads SettingsStore for config version. Provides static
    //  display data for shell identity, runtime, and credits.
    //  No mutations — this page is read-only.
    //
    //  • Reads:  SettingsStore
    //  • Writes: nothing
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Shell identity ─────────────────────────────────────────────
    readonly property string shellName:    "Quickshell"
    readonly property string shellVersion: "0.1.0"
    readonly property string shellCodename: "Ariadne"

    // ── Config ─────────────────────────────────────────────────────
    readonly property string configVersion: "v" + SettingsStore.configVersion

    // ── Runtime ────────────────────────────────────────────────────
    readonly property string qtVersion:     Qt.version
    readonly property string qtQuickVersion: {
        // Qt.version covers the framework; Quick version is the same
        // in Qt 6's unified versioning scheme.
        return Qt.version
    }

    // ── Links ─────────────────────────────────────────────────────
    readonly property string repositoryUrl: "https://github.com/outfoxxed/quickshell"
    readonly property string docsUrl:       "https://quickshell.outfoxxed.me"

    // ── Credits ───────────────────────────────────────────────────
    readonly property string licenseName: "LGPL-2.1"
    readonly property string licenseUrl:  "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.html"

    readonly property var credits: [
        { name: "Quickshell",     role: "Shell framework", url: "https://github.com/outfoxxed/quickshell" },
        { name: "Hyprland",       role: "Wayland compositor", url: "https://github.com/hyprwm/Hyprland" },
        { name: "Catppuccin",     role: "Color palettes", url: "https://github.com/catppuccin/catppuccin" },
        { name: "Material You",   role: "Dynamic theming", url: "https://m3.material.io" }
    ]

    // ── Theme info ────────────────────────────────────────────────
    readonly property string currentTheme: SettingsStore.theme
}
