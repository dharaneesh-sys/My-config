import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  ClipboardViewModel
    //
    //  Presentation adapter for the Clipboard panel.
    //  Reads ClipboardState, exposes a reconciled ListModel for the
    //  list view. Actions flow through State signals.
    //
    //  • Reads:  ClipboardState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Query ──────────────────────────────────────────────────────
    property string query: ClipboardState.query

    // ── Results (ListModel, reconciled in place) ───────────────────
    // Mirrors the LauncherViewModel reconcile pattern: remove stale
    // rows, update changed fields in place, append new — so delegates
    // keep hover/selection state while typing a filter.
    property ListModel resultsModel: ListModel {}

    // ── Image previews (reactive pass-through) ─────────────────────
    // Reassigned as a whole object by ClipboardState on every change,
    // so indexed reads (imagePaths[id]) re-evaluate on update.
    readonly property var imagePaths: ClipboardState.imagePaths

    function _syncResults() {
        var items = ClipboardState.filteredEntries
        var count = items.length
        var m = vm.resultsModel

        // Clear-and-refill instead of O(n²) reconcile.  The clipboard
        // panel resets currentIndex on every query change, so there is
        // no hover/selection state to preserve during filtering.
        m.clear()
        for (var k = 0; k < count; k++) {
            var e = items[k]
            m.append({
                id: e.id,
                preview: e.preview,
                isImage: e.isImage,
                imageFormat: e.imageFormat,
                imageWidth: e.imageWidth,
                imageHeight: e.imageHeight
            })
        }
    }

    function _findIndex(model, role, key) {
        for (var i = 0; i < model.count; i++) {
            if (model.get(i)[role] === key)
                return i
        }
        return -1
    }

    // ── Presentation state ─────────────────────────────────────────
    readonly property int totalCount: ClipboardState.filteredEntries.length
    readonly property bool showEmptyState: query !== "" && resultsModel.count === 0
    readonly property bool loading: ClipboardState.loading

    // ── Sync on state changes ──────────────────────────────────────
    property Connections _stateConn: Connections {
        target: ClipboardState
        function onFilteredEntriesChanged() { vm._syncResults() }
    }

    Component.onCompleted: _syncResults()

    // ── Actions ────────────────────────────────────────────────────
    function setQuery(q)   { ClipboardState.setQueryRequested(q) }
    function refresh()     { ClipboardState.refreshRequested() }
    function copy(id)      { ClipboardState.copyRequested(id) }
    function remove(id)    { ClipboardState.deleteRequested(id) }
    function requestImagePreview(id) {
        ClipboardState.imagePreviewRequested(id)
    }
}