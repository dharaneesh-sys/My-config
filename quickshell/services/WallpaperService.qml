import Quickshell
import QtCore
import QtQuick
import Quickshell.Io

import qs.state
import qs.tokens
import qs.settings

Item {
    id: wallpaperService

    // ═══════════════════════════════════════════════════════════════
    //  WallpaperService
    //
    //  Bridges the shell to the real wallpaper tooling:
    //    awww (the daemon matuwall uses) + the shared state files in
    //    ~/.cache/wallpaper/ that every wallpaper app on the system
    //    reads and writes (wallpaper-app, apply-wallpaper, matuwall).
    //
    //  - Lists wallpapers from the configured directory (the same
    //    ~/Pictures/Wallpapers the GTK wallpaper-app browses).
    //  - Applying writes ~/.cache/wallpaper/last_wallpaper so the
    //    whole desktop agrees on the current wallpaper.
    //  - When the active theme is "Dynamic", a wallpaper change runs
    //    wallpaper-to-theme.sh (matugen → theme-switcher) exactly
    //    like wallpaper-app does.
    //
    //  The shared cache is watched (FileView) so external changes
    //  (theme-switcher picking a random wallpaper, wallpaper-app)
    //  are reflected live in the shell.
    // ═══════════════════════════════════════════════════════════════

    // Directory fed by SettingsStore (the "all" scope source).
    property string wallpaperDir: ""
    // Directory actually listed — "all" resolves to wallpaperDir,
    // "theme" resolves to ~/Pictures/Themes/<active theme>/. Kept as a
    // separate property so the SettingsStore binding never fights the
    // theme-scoped picker.
    property string _activeDir: ""
    // Mirrors WallpaperState.scope; kept here because the find command
    // binding needs it synchronously at refresh time.
    property string scope: "all"

    // Plain path, NOT a URL: StandardPaths.writableLocation stringifies
    // as "file:///home/..." in this build, which breaks Process argv
    // (find, mkdir) and shell scripts. Quickshell.env returns a plain
    // path — the same source IconRegistry uses.
    readonly property string home: Quickshell.env("HOME")
    readonly property string cacheDir: home + "/.cache/wallpaper"
    // Separate from the shared wallpaper-state cache: this contains only
    // small display previews and is safe to rebuild at any time.
    readonly property string thumbnailDir: home + "/.cache/quickshell/wallpaper-thumbnails"
    readonly property string lastWallpaperFile: cacheDir + "/last_wallpaper"
    readonly property string wallpaperToThemeScript: home + "/.config/hypr/scripts/wallpaper-to-theme.sh"

    // ── List wallpapers ────────────────────────────────────────────
    Process {
        id: listWallpapers
        // Process runs argv directly (no shell), so grouping parens are
        // literal "(" / ")" tokens for find's expression.
        command: ["find", wallpaperService._activeDir, "-type", "f", "(",
                  "-name", "*.png", "-o", "-name", "*.jpg", "-o", "-name", "*.jpeg",
                  "-o", "-name", "*.webp", "-o", "-name", "*.gif", "-o", "-name", "*.bmp",
                  "-o", "-name", "*.avif", ")"]
        stdout: StdioCollector { id: listWallpapersOut }
        onExited: (code, status) => {
            if (code !== 0) return
            var lines = listWallpapersOut.text.trim().split("\n")
            var wps = []
            for (var i = 0; i < lines.length; i++) {
                var path = lines[i].trim()
                if (path) {
                    var name = path.split("/").pop()
                    wps.push({ name: name, path: path, thumbnail: path })
                }
            }
            WallpaperState.wallpapers = wps
            wallpaperService._buildThumbnails()
        }
    }

    // Build fixed-size previews once and reuse them on every panel open.
    // Full wallpaper files are often multi-megabyte WebPs; feeding those
    // straight to dozens of QML Image items stalls the thumbnail tray.
    Process {
        id: buildThumbnails
        command: []
        stdout: StdioCollector { id: thumbnailBuildOut }
        onExited: (code, status) => {
            if (code !== 0) {
                console.warn("WallpaperService: thumbnail generation failed with code " + code)
                return
            }

            var byPath = ({})
            var lines = thumbnailBuildOut.text.trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var parts = lines[i].split("\t")
                if (parts.length >= 2 && parts[0] !== "" && parts[1] !== "")
                    byPath[parts[0]] = parts[1]
            }

            var updated = []
            var wallpapers = WallpaperState.wallpapers
            for (var j = 0; j < wallpapers.length; j++) {
                var wallpaper = wallpapers[j]
                updated.push({
                    name: wallpaper.name,
                    path: wallpaper.path,
                    thumbnail: byPath[wallpaper.path] || wallpaper.thumbnail
                })
            }
            WallpaperState.wallpapers = updated
        }
    }

    function _buildThumbnails() {
        if (_activeDir === "" || buildThumbnails.running) return
        // File names are hashed so duplicates from nested folders cannot
        // collide. Magick only rebuilds a preview when its source is newer.
        buildThumbnails.command = ["sh", "-c",
            "mkdir -p \"$2\"; find \"$1\" -type f \\(" +
            " -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg'" +
            " -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.avif' \\) -print0" +
            " | while IFS= read -r -d '' source; do" +
            " key=$(printf '%s' \"$source\" | sha256sum | cut -c1-20);" +
            " target=\"$2/$key.webp\";" +
            " if [ ! -s \"$target\" ] || [ \"$source\" -nt \"$target\" ]; then" +
            " magick \"$source[0]\" -auto-orient -thumbnail '240x140^' -gravity center -extent 240x140 \"$target\" 2>/dev/null || continue; fi;" +
            " printf '%s\\t%s\\n' \"$source\" \"$target\"; done",
            "sh", _activeDir, thumbnailDir]
        buildThumbnails.running = true
    }

    // ── Scope ──────────────────────────────────────────────────────
    function setScope(s) {
        wallpaperService.scope = (s === "theme") ? "theme" : "all"
        WallpaperState.scope = wallpaperService.scope
        wallpaperService._applyScope()
    }

    function _applyScope() {
        if (wallpaperService.scope === "theme") {
            var t = ThemeState.systemTheme || ""
            wallpaperService._activeDir = (t !== "") ? home + "/Pictures/Themes/" + t : ""
        } else {
            wallpaperService._activeDir = wallpaperService.wallpaperDir
        }
        console.log("WallpaperService: scope=" + wallpaperService.scope +
                    " activeDir=" + wallpaperService._activeDir +
                    " systemTheme=" + ThemeState.systemTheme)
        wallpaperService.refresh()
    }

    // ── Apply wallpaper (awww + shared last_wallpaper cache) ───────
    // Same flags the GTK wallpaper-app and matuwall pass.
    function setWallpaper(path) {
        if (!path) return
        awwwCmd.command = [
            "awww", "img", path,
            "--transition-type", "random",
            "--transition-step", "18",
            "--transition-fps", "60",
            "--transition-duration", "2.5"
        ]
        awwwCmd.running = true

        // Persist as the shell's configured wallpaper.
        if (SettingsStore.wallpaper !== path)
            SettingsStore.wallpaper = path

        WallpaperState.currentWallpaper = path
        WallpaperState.currentWallpaperUrl = path
        _writeLastWallpaper(path)

        // Dynamic theme: regenerate the palette from the new wallpaper.
        // Staged via _pendingDynamicPath so it runs AFTER the cache write
        // completes (writeLastCmd.onExited) — theme-switcher Dynamic, which
        // wallpaper-to-theme.sh invokes, must see the fresh wallpaper.
        _pendingDynamicPath = (ThemeState.systemTheme === "Dynamic") ? path : ""
    }

    Process { id: awwwCmd; command: [] }
    Process {
        id: dynamicCmd
        command: []
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("WallpaperService: wallpaper-to-theme.sh failed with code " + code)
        }
    }

    // Quickshell Dynamic: matugen → Dynamic palette writable proxy
    Process {
        id: matugenProc
        command: []
        stdout: StdioCollector { id: matugenOut }
        onExited: (code, status) => {
            if (code !== 0) {
                console.warn("WallpaperService: matugen failed with code " + code)
                return
            }
            try {
                var data = JSON.parse(matugenOut.text)
                Dynamic.applyMatugen(data)
                console.info("WallpaperService: quickshell Dynamic palette updated from " + WallpaperState.currentWallpaper)
            } catch(e) {
                console.warn("WallpaperService: matugen JSON parse failed — " + e.message)
            }
        }
    }

    function _updateQuickshellDynamic(path) {
        if (!path) return
        matugenProc.command = ["matugen", "image", path, "--json", "hex"]
        matugenProc.running = true
    }

    // Set by setWallpaper() for Dynamic applies; consumed (and cleared)
    // by writeLastCmd.onExited. Avoids mutating signal handlers, so no
    // stale closure can fire a Dynamic apply after the theme was switched.
    property string _pendingDynamicPath: ""

    function _writeLastWallpaper(path) {
        // Quote-safe: the path travels as an argv argument, not inline.
        writeLastCmd.command = ["sh", "-c",
            "mkdir -p \"$1\" && printf '%s\\n' \"$2\" > \"$3\"",
            "sh", cacheDir, path, lastWallpaperFile]
        writeLastCmd.running = true
    }

    Process {
        id: writeLastCmd
        command: []
        onExited: (code, status) => {
            var p = wallpaperService._pendingDynamicPath
            if (p !== "") {
                wallpaperService._pendingDynamicPath = ""
                dynamicCmd.command = [wallpaperService.wallpaperToThemeScript, p]
                dynamicCmd.running = true
                // Quickshell Dynamic: same wallpaper, update palette
                wallpaperService._updateQuickshellDynamic(p)
            }
        }
    }

    // ── Watch shared last_wallpaper cache (external truth) ─────────
    FileView {
        id: lastWallpaperView
        path: wallpaperService.lastWallpaperFile
        preload: true
        watchChanges: true
        onFileChanged: lastWallpaperView.reload()
        onLoaded: wallpaperService._syncFromLastWallpaper(lastWallpaperView.text())
    }

    function _syncFromLastWallpaper(text) {
        var path = text.trim()
        if (path === "") return
        WallpaperState.currentWallpaper = path
        WallpaperState.currentWallpaperUrl = path
        // Keep the persisted picker selection aligned with the shared cache
        // when another wallpaper tool changes it.
        if (SettingsStore.wallpaper !== path)
            SettingsStore.wallpaper = path
    }

    // ── Refresh ────────────────────────────────────────────────────
    function refresh() {
        if (_activeDir !== "")
            listWallpapers.running = true
    }

    function setWallpaperDir(dir) {
        wallpaperDir = dir
        if (scope !== "theme")
            _activeDir = dir
        refresh()
    }

    Connections {
        target: WallpaperState
        function onSetWallpaperRequested(p) { wallpaperService.setWallpaper(p) }
        function onSetBackendRequested(b) { WallpaperState.backend = b }
        function onSetScopeRequested(s) { wallpaperService.setScope(s) }
        function onRefreshRequested() { wallpaperService.refresh() }
    }

    // Theme switch → re-point the theme-scoped list live.
    Connections {
        target: ThemeState
        function onSystemThemeChanged() {
            if (wallpaperService.scope === "theme")
                wallpaperService._applyScope()
            // If switched to Dynamic, generate palette from current wallpaper
            if (ThemeState.systemTheme === "Dynamic" && WallpaperState.currentWallpaper !== "") {
                wallpaperService._updateQuickshellDynamic(WallpaperState.currentWallpaper)
            }
        }
    }

    Component.onCompleted: {
        wallpaperService._applyScope()
        // Initial quickshell Dynamic generation if theme already Dynamic
        if (ThemeState.systemTheme === "Dynamic" && WallpaperState.currentWallpaper !== "") {
            Qt.callLater(function() { wallpaperService._updateQuickshellDynamic(WallpaperState.currentWallpaper) })
        }
    }
}
