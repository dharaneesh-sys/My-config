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
    // Papirus-Dark is the active GTK theme; Papirus provides its apps
    // icons (the -Dark apps dir is a symlink find won't follow). The
    // user's ~/.local/share/icons themes (MacTahoe, WhiteSur, Win11,
    // kora, …) serve as fallbacks, then hicolor and the rest.
    readonly property var _dirs: [
        "/usr/share/icons/Papirus-Dark",
        "/usr/share/icons/Papirus",
        Quickshell.env("HOME") + "/.local/share/icons",
        "/usr/share/icons/hicolor",
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
        // Only index what the launcher/notification app icons need:
        // the apps context at usable sizes, plus flat pixmaps files.
        // This drops the index from ~134k lines to ~19k — the JS
        // _index() parse is the startup cost, so fewer lines = faster
        // icon availability. Flat themes (MacTahoe, kora) put icons
        // directly under apps/ with no size dir; size-prefixed themes
        // (Papirus, hicolor) use 48x48/apps etc. Tiny sizes (<=32px)
        // and @2x variants are pruned — the launcher renders 24px
        // icons at a 48px sourceSize, so they're never needed.
        var args = ["find"]
        for (var i = 0; i < registry._dirs.length; i++)
            args.push(registry._dirs[i])
        args.push("(")
        args.push("-type", "d", "(")
        args.push("-name", "8x8")
        args.push("-o", "-name", "16x16")
        args.push("-o", "-name", "16x16@2x")
        args.push("-o", "-name", "18x18")
        args.push("-o", "-name", "18x18@2x")
        args.push("-o", "-name", "22x22")
        args.push("-o", "-name", "22x22@2x")
        args.push("-o", "-name", "24x24")
        args.push("-o", "-name", "24x24@2x")
        args.push("-o", "-name", "32x32")
        args.push("-o", "-name", "32x32@2x")
        args.push("-o", "-name", "42x42")
        args.push("-o", "-name", "42x42@2x")
        args.push("-o", "-name", "48x48@2x")
        args.push("-o", "-name", "64x64")
        args.push("-o", "-name", "64x64@2x")
        args.push("-o", "-name", "84x84")
        args.push("-o", "-name", "96x96")
        args.push("-o", "-name", "96x96@2x")
        args.push("-o", "-name", "128x128")
        args.push("-o", "-name", "128x128@2x")
        args.push("-o", "-name", "256x256")
        args.push("-o", "-name", "256x256@2x")
        args.push("-o", "-name", "512x512")
        args.push("-o", "-name", "512x512@2x")
        args.push("-o", "-name", "1024x1024")
        args.push(")")
        args.push("-prune")
        args.push(")")
        args.push("-o", "(")
        args.push("-path", "*/apps/*")
        args.push("-o", "-path", "*/pixmaps/*")
        args.push(")")
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
