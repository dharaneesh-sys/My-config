pragma Singleton
import QtQuick

QtObject {
    id: wallpaperState

    // ═══════════════════════════════════════════════════════════════
    //  WallpaperState
    //
    //  Reactive wallpaper properties. Written by WallpaperService.
    // ═══════════════════════════════════════════════════════════════

    // ── Current ────────────────────────────────────────────────────
    property string currentWallpaper: ""
    property url currentWallpaperUrl: ""

    // ── Available wallpapers ───────────────────────────────────────
    property var wallpapers: []        // [{name, path, thumbnail}]

    // ── Backend ────────────────────────────────────────────────────
    property string backend: "awww"    // awww (system uses matuwall/awww)

    // ── Scope ──────────────────────────────────────────────────────
    // "all"   → the configured wallpaper directory (Super+W)
    // "theme" → only the active theme's wallpaper dir
    //           ~/Pictures/Themes/<theme>/ (Super+Shift+I)
    property string scope: "all"

    // ── Actions ────────────────────────────────────────────────────
    signal setWallpaperRequested(string path)
    signal setBackendRequested(string backend)
    signal setScopeRequested(string scope)
    signal refreshRequested()
}
