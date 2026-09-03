import Quickshell
import QtQuick
import Quickshell.Io

import qs.state

Item {
    id: clipboardService

    // ═══════════════════════════════════════════════════════════════
    //  ClipboardService
    //
    //  Runs the cliphist subprocesses that back ClipboardState.
    //  No UI. Panels never import this — they read ClipboardState.
    //
    //  cliphist notes (verified against the installed CLI):
    //    • `list`   → "<id>\t<preview>" per line; newlines inside
    //      previews are stored as spaces, so parsing is line-safe.
    //    • `decode` and `delete` accept the bare id on stdin as long
    //      as it has no trailing newline (the parser is strict).
    //    • Image entries preview as
    //      "[[ binary data <size> <unit> <fmt> <W>x<H> ]]".
    // ═══════════════════════════════════════════════════════════════

    // ── List entries ───────────────────────────────────────────────
    Process {
        id: listProcess
        command: ["cliphist", "list"]
        stdout: StdioCollector { id: listOutput }
        onExited: (code, status) => {
            if (code !== 0) {
                console.warn("ClipboardService: cliphist list failed (" + code + ")")
                ClipboardState.loading = false
                return
            }
            var text = listOutput.text
            var lines = text === "" ? [] : text.split("\n")
            // cliphist always emits a trailing newline → drop the last empty item
            if (lines.length > 0 && lines[lines.length - 1] === "") lines.pop()
            // Clear loading BEFORE setEntries so the panel's first
            // onImagePathsChanged can fire preview requests.
            ClipboardState.loading = false
            ClipboardState.setEntries(lines)
        }
    }

    // ── Copy to clipboard (decode + wl-copy) ──────────────────────
    Process { id: copyProcess; command: [] }

    function copyEntry(id) {
        copyProcess.command = ["sh", "-c",
            "printf '%s' '" + id + "' | cliphist decode | wl-copy"]
        copyProcess.running = true
    }

    // ── Delete entry ───────────────────────────────────────────────
    Process { id: deleteProcess; command: [] }

    function deleteEntry(id) {
        deleteProcess.command = ["sh", "-c",
            "printf '%s' '" + id + "' | cliphist delete"]
        deleteProcess.running = true
    }

    // ── Image preview (decode to temp file) ────────────────────────
    // Temp files live in /tmp with a fixed prefix; cleaned once at shell
    // startup (Component.onCompleted below) — NEVER per refresh. Entries
    // are immutable, so an existing file is always valid, and deleting
    // one mid-flight breaks any Qt Image reader holding its URL.
    // The extension is irrelevant — Qt sniffs image content.
    //
    // Quickshell Process passes command as argv[0], argv[1]... When
    // using `sh -c`, positional params ($1, $2) are unreliable across
    // Process implementations. Instead we embed the id/path directly
    // in the command string — ids are numeric-only (safe to embed).
    property string _pendingPreviewId: ""

    // Serialized decode queue. The preview Process is shared, so a new
    // request must NEVER restart it mid-run — the killed run's onExited
    // would fire against the wrong _pendingPreviewId and misroute the
    // decoded file. Requests queue up; one decodes at a time.
    property var _previewQueue: []
    property bool _previewBusy: false

    // Ids successfully decoded this shell session. Entry content is
    // immutable for a given id, so a completed decode is final;
    // re-running it would only truncate the temp file under any active
    // reader (libpng Read Error). Cleared per-id on delete.
    property var _decodedIds: ({})

    function imagePathFor(id) {
        var safe = String(id).replace(/[^a-zA-Z0-9]/g, "_")
        return "/tmp/qsh-clipboard-" + safe + ".img"
    }

    Process {
        id: previewProcess
        command: []
        onExited: (code, status) => {
            var id = clipboardService._pendingPreviewId
            clipboardService._previewBusy = false
            clipboardService._pendingPreviewId = ""
            if (code !== 0) {
                console.warn("ClipboardService: image decode failed (" + code + ") for id " + id)
            } else if (id !== "") {
                var url = "file://" + clipboardService.imagePathFor(id)
                clipboardService._decodedIds[id] = true
                var copy = Object.assign({}, ClipboardState.imagePaths)
                copy[id] = url
                ClipboardState.imagePaths = copy
            }
            clipboardService._drainPreviewQueue()
        }
    }

    function decodePreview(id) {
        var key = String(id)
        // Dedupe: already decoded this session, currently decoding,
        // or queued.
        if (clipboardService._decodedIds[key]) return
        if (clipboardService._previewBusy && clipboardService._pendingPreviewId === key) return
        if (clipboardService._previewQueue.indexOf(key) !== -1) return
        clipboardService._previewQueue.push(key)
        clipboardService._drainPreviewQueue()
    }

    function _drainPreviewQueue() {
        if (clipboardService._previewBusy || clipboardService._previewQueue.length === 0) return
        var id = String(clipboardService._previewQueue.shift())
        clipboardService._previewBusy = true
        clipboardService._pendingPreviewId = id
        var path = clipboardService.imagePathFor(id)
        // Embed id and path directly — ids are always numeric, safe for shell.
        previewProcess.command = ["sh", "-c",
            "printf '%s' '" + id + "' | cliphist decode > '" + path + "'"]
        previewProcess.running = true
    }

    // ── Temp-file cleanup ──────────────────────────────────────────
    Process { id: cleanupProcess; command: [] }

    function _cleanupTempFiles() {
        cleanupProcess.command = ["sh", "-c", "rm -f /tmp/qsh-clipboard-*.img"]
        cleanupProcess.running = true
    }

    // One-time sweep at shell start (leftovers from a previous session).
    // Runs long before the first panel open can decode anything.
    Component.onCompleted: clipboardService._cleanupTempFiles()
    // Remove a single entry's temp file (used on delete).
    function _removeTempFile(id) {
        var safe = String(id).replace(/[^a-zA-Z0-9]/g, "_")
        cleanupProcess.command = ["sh", "-c", "rm -f /tmp/qsh-clipboard-" + safe + ".img"]
        cleanupProcess.running = true
    }

    // ── Routing ────────────────────────────────────────────────────
    Connections {
        target: ClipboardState
        function onRefreshRequested() {
            ClipboardState.loading = true
            listProcess.running = true
        }
        function onCopyRequested(id) { clipboardService.copyEntry(id) }
        function onDeleteRequested(id) {
            clipboardService.deleteEntry(id)
            clipboardService._removeTempFile(id)
            delete clipboardService._decodedIds[String(id)]
            ClipboardState.dropImagePath(id)
        }
        function onImagePreviewRequested(id) { clipboardService.decodePreview(id) }
    }
}
