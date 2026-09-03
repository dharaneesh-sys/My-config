pragma Singleton
import QtQuick

QtObject {
    id: clipboardState

    // ═══════════════════════════════════════════════════════════════
    //  ClipboardState
    //
    //  Reactive clipboard-history state backed by the cliphist
    //  database. This singleton is PURE — no Process, no OS calls.
    //  ClipboardService (qs.services) runs the cliphist subprocesses
    //  and writes results here; panels read state only.
    //
    //  Entries come from `cliphist list`, one line per entry:
    //    "<id>\t<preview>"
    //  Image entries show a placeholder preview:
    //    "[[ binary data <size> <unit> <format> <W>x<H> ]]"
    // ═══════════════════════════════════════════════════════════════

    // ── Entries (most-recent first, as cliphist lists them) ───────
    // Each entry: { id, line, preview, isImage, imageFormat,
    //               imageWidth, imageHeight }
    property var entries: []

    // ── Search ─────────────────────────────────────────────────────
    property string query: ""
    // Plain property, not a binding: _applyFilter() reads the mutable
    // entries array; every mutation path recomputes explicitly.
    property var filteredEntries: []

    // ── Loading ────────────────────────────────────────────────────
    property bool loading: false

    // ── Image previews ─────────────────────────────────────────────
    // id → file:// URL of the decoded thumbnail. Populated lazily by
    // ClipboardService when a visible row requests one. Always
    // reassigned as a whole object so bindings re-evaluate (mutating
    // a JS object property fires no change notification).
    property var imagePaths: ({})

    // ── Actions (kept as signals for API compatibility) ────────────
    signal setQueryRequested(string query)
    signal refreshRequested()
    signal copyRequested(string id)
    signal deleteRequested(string id)
    signal imagePreviewRequested(string id)

    // ── Parsing ────────────────────────────────────────────────────
    function _parseLine(line) {
        var tab = line.indexOf("\t")
        if (tab === -1) return null
        var id = line.substring(0, tab)
        var preview = line.substring(tab + 1)
        var img = /^\[\[ binary data (\d+) \w+ (\w+) (\d+)x(\d+) \]\]$/.exec(preview)
        return {
            id: id,
            line: line,
            preview: preview,
            isImage: !!img,
            imageFormat: img ? img[2] : "",
            imageWidth: img ? parseInt(img[3]) : 0,
            imageHeight: img ? parseInt(img[4]) : 0
        }
    }

    // Called by ClipboardService on every `cliphist list` run.
    function setEntries(lines) {
        var out = []
        for (var i = 0; i < lines.length; i++) {
            var e = clipboardState._parseLine(lines[i])
            if (e) out.push(e)
        }
        clipboardState.entries = out
        // imagePaths is intentionally preserved across refreshes: temp
        // files survive refreshes now (the service sweeps them only at
        // shell startup) and cliphist ids are immutable, so existing
        // thumbnails stay valid. Clearing here would force pointless
        // re-decodes of every visible row.
        clipboardState.filteredEntries = clipboardState._applyFilter()
    }

    function _applyFilter() {
        var q = clipboardState.query.toLowerCase()
        var list = clipboardState.entries
        if (q === "") return list.slice()
        var out = []
        for (var i = 0; i < list.length; i++) {
            var e = list[i]
            var hay = e.preview.toLowerCase()
            if (e.isImage)
                hay += " image " + e.imageFormat + " " + e.imageWidth + "x" + e.imageHeight
            if (hay.indexOf(q) !== -1) out.push(e)
        }
        return out
    }

    // ── Optimistic delete ──────────────────────────────────────────
    // Remove locally so the row vanishes instantly; ClipboardService
    // re-lists only if the cliphist delete actually failed.
    function _removeLocal(id) {
        var list = clipboardState.entries.slice()
        var flist = clipboardState.filteredEntries.slice()
        clipboardState._removeFrom(list, id)
        clipboardState._removeFrom(flist, id)
        clipboardState.entries = list
        clipboardState.filteredEntries = flist
    }

    function _removeFrom(arr, id) {
        for (var i = arr.length - 1; i >= 0; i--) {
            if (arr[i].id === id) arr.splice(i, 1)
        }
    }

    // ── Drop one thumbnail (after its temp file is removed) ────────
    function dropImagePath(id) {
        var copy = Object.assign({}, clipboardState.imagePaths)
        delete copy[id]
        clipboardState.imagePaths = copy
    }

    // ── Action routing ─────────────────────────────────────────────
    property Connections _actions: Connections {
        target: clipboardState
        function onSetQueryRequested(q) {
            clipboardState.query = q
            clipboardState.filteredEntries = clipboardState._applyFilter()
        }
        function onDeleteRequested(id) {
            clipboardState._removeLocal(id)
        }
    }

    Component.onCompleted: {
        clipboardState.filteredEntries = clipboardState._applyFilter()
    }
}