import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  WallpaperSelectorViewModel
    //
    //  Presentation adapter for the WallpaperSelector panel.
    //  Reads WallpaperState, formats presentation data.
    //
    //  • Reads:  WallpaperState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Wallpaper cards (formatted for display) ────────────────────
    readonly property var wallpapers: _formatWallpapers()

    function _formatWallpapers() {
        var raw = WallpaperState.wallpapers
        var out = []
        for (var i = 0; i < raw.length; i++) {
            out.push({
                name: raw[i].name || "",
                thumbnail: raw[i].thumbnail || "",
                path: raw[i].path,
                selected: raw[i].path === WallpaperState.currentWallpaper
            })
        }
        return out
    }

    // ── Empty state ────────────────────────────────────────────────
    readonly property bool isEmpty: WallpaperState.wallpapers.length === 0

    // ── Actions ────────────────────────────────────────────────────
    function selectWallpaper(path) {
        WallpaperState.setWallpaperRequested(path)
    }
}
