pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: registry

    // ═══════════════════════════════════════════════════════════════
    //  IconRegistry
    //
    //  One-time index of the system icon themes. Resolves
    //  desktop-entry icon *names* ("firefox", "org.gnome.Nautilus")
    //  to file:// URLs that QtQuick.Image can actually render.
    //
    //  Built by running `find` once over the standard icon dirs
    //  (user icons first, then hicolor, then the rich themes) and
    //  mapping each file's basename → first matching path. Scalable
    //  SVG wins over raster. No polling, no per-lookup processes.
    //
    //  Until the index is built, iconSource() returns "" — callers
    //  fall back to a Material glyph, then swap in the real icon.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    readonly property bool ready: _ready

    // Absolute paths pass through untouched; everything else is
    // looked up in the index (case-insensitive).
    function iconSource(name) {
        if (!name) return ""
        var s = String(name)
        if (s.charAt(0) === "/")
            return "file://" + s
        var p = registry._icons[s.toLowerCase()]
        return p ? "file://" + p : ""
    }

    // ── Index ──────────────────────────────────────────────────────
    property var _icons: ({})
    property bool _ready: false

    // Most-specific / prettiest first — first match wins per name.
    readonly property var _dirs: [
        Quickshell.env("HOME") + "/.local/share/icons",
        "/usr/share/icons/hicolor",
        "/usr/share/icons/Papirus-Dark",
        "/usr/share/icons/Papirus",
        "/usr/share/icons/breeze-dark",
        "/usr/share/icons/breeze",
        "/usr/share/icons/Adwaita",
        "/usr/share/pixmaps"
    ]

    property Process _finder: Process {
        command: registry._buildFindCommand()
        running: true
        stdout: StdioCollector {
            onStreamFinished: registry._index(text)
        }
        // If find fails entirely (missing dirs, permission), still flip
        // ready so callers fall back to Material glyphs instead of
        // showing a forever-empty slot.
        onExited: function(code) {
            registry._ready = true
        }
    }

    function _buildFindCommand() {
        var args = ["find"]
        for (var i = 0; i < registry._dirs.length; i++)
            args.push(registry._dirs[i])
        args.push("-type", "f")
        args.push("(")
        args.push("-name", "*.png")
        args.push("-o", "-name", "*.svg")
        args.push("-o", "-name", "*.svgz")
        args.push("-o", "-name", "*.xpm")
        args.push(")")
        args.push("-print")
        return args
    }

    function _index(output) {
        var lines = String(output).split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (line === "") continue
            var slash = line.lastIndexOf("/")
            if (slash === -1) continue
            var base = line.substring(slash + 1)
            var dot = base.lastIndexOf(".")
            var key = (dot === -1 ? base : base.substring(0, dot)).toLowerCase()
            if (key === "") continue

            var existing = registry._icons[key]
            if (existing === undefined) {
                registry._icons[key] = line
            } else if (existing.indexOf(".svg") === -1 && line.indexOf(".svg") !== -1) {
                registry._icons[key] = line   // prefer scalable when found later
            }
        }
        registry._ready = true
        var count = 0
        for (var k in registry._icons) count++
        console.log("IconRegistry ready:", count, "icons | firefox ->", registry._icons["firefox"] || "missing")
    }
}
