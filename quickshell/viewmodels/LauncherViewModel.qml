import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  LauncherViewModel
    //
    //  Presentation adapter for the Launcher panel.
    //  Reads LauncherState, sorts/limits results for display.
    //
    //  • Reads:  LauncherState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Query ──────────────────────────────────────────────────────
    property string query: LauncherState.query

    // ── Results (ListModel, reconciled in place, unlimited) ────────
    // LauncherState recomputes filteredApplications in-process on every
    // query keystroke and applications change. A fresh JS array per change
    // would destroy + recreate every AppRow delegate (losing hover state
    // and causing flicker while typing). Reconcile instead: remove stale
    // rows, setProperty only changed fields, append new. Typing a query
    // that merely reorders/shrinks the match set mutates only what changed.
    // (docs/KNOWN_LIMITATIONS.md:160)
    //
    // No max-results cap: the full sorted list is shown and the panel's
    // Flickable scrolls it. (docs/KNOWN_LIMITATIONS.md:160)
    property ListModel resultsModel: ListModel {}

    function _syncResults() {
        var apps = LauncherState.filteredApplications
        var count = apps.length
        var m = vm.resultsModel

        // 1) Remove rows whose key is no longer in the (trimmed) raw data
        for (var i = m.count - 1; i >= 0; i--) {
            var key = m.get(i).desktopFile
            var found = false
            for (var j = 0; j < count; j++) {
                if (apps[j].desktopFile === key) { found = true; break }
            }
            if (!found)
                m.remove(i)
        }

        // 2) Update in place (only changed fields) or append new
        for (var k = 0; k < count; k++) {
            var a = apps[k]
            var idx = _findIndex(m, "desktopFile", a.desktopFile)
            if (idx === -1) {
                m.append(a)
            } else {
                var cur = m.get(idx)
                if (cur.name        !== a.name)        m.setProperty(idx, "name", a.name)
                if (cur.description !== a.description) m.setProperty(idx, "description", a.description)
                if (cur.icon        !== a.icon)        m.setProperty(idx, "icon", a.icon)
                if (cur.exec        !== a.exec)        m.setProperty(idx, "exec", a.exec)
                if (cur.terminal    !== a.terminal)    m.setProperty(idx, "terminal", a.terminal)
            }
        }
    }

    function _findIndex(model, role, key) {
        for (var i = 0; i < model.count; i++) {
            if (model.get(i)[role] === key)
                return i
        }
        return -1
    }

    readonly property int totalMatchCount: LauncherState.filteredApplications.length

    // ── Empty state ────────────────────────────────────────────────
    readonly property bool showEmptyState: query !== "" && resultsModel.count === 0

    // ── Pinned apps ────────────────────────────────────────────────
    readonly property var pinned: LauncherState.pinned

    // ── Launching indicator ────────────────────────────────────────
    function isLaunching(exec) {
        return LauncherState.launching && LauncherState.launchingApp === exec
    }

    // ── Sync on state changes ──────────────────────────────────────
    property Connections _stateConn: Connections {
        target: LauncherState
        function onFilteredApplicationsChanged() { vm._syncResults() }
    }

    Component.onCompleted: _syncResults()

    // ── Actions ────────────────────────────────────────────────────
    function setQuery(q) { LauncherState.setQueryRequested(q) }
    function launch(exec, terminal) { LauncherState.launchRequested(exec, terminal) }
}
