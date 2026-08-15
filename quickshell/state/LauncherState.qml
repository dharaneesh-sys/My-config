pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: launcherState

    // ═══════════════════════════════════════════════════════════════
    //  LauncherState
    //
    //  Reactive launcher properties bound directly to the native
    //  DesktopEntries service. No `find + grep` subprocess scans.
    //
    //  applications is mirrored from the DesktopEntry model; filtering
    //  happens in-process. desktopFile doubles as the stable entry id.
    // ═══════════════════════════════════════════════════════════════

    // ── All applications ───────────────────────────────────────────
    property var applications: _collectApplications()

    function _collectApplications() {
        var vals = DesktopEntries.applications ? DesktopEntries.applications.values : []
        var out = []
        for (var i = 0; i < vals.length; i++) {
            var e = vals[i]
            out.push({
                name: e.name || "",
                icon: e.icon || "",
                description: e.comment || "",
                exec: e.execString || "",
                category: (e.categories && e.categories.length > 0) ? e.categories[0] : "",
                terminal: e.runInTerminal,
                desktopFile: e.id || ""
            })
        }
        return out
    }

    // ── Search ─────────────────────────────────────────────────────
    property string query: ""
    property var filteredApplications: _applyFilter()

    function _applyFilter() {
        var q = launcherState.query.toLowerCase()
        var apps = launcherState.applications
        if (q === "")
            return apps
        var filtered = []
        for (var i = 0; i < apps.length; i++) {
            var a = apps[i]
            if (a.name.toLowerCase().indexOf(q) !== -1 ||
                a.description.toLowerCase().indexOf(q) !== -1) {
                filtered.push(a)
            }
        }
        return filtered
    }

    // ── Recent / pinned ────────────────────────────────────────────
    property var pinned: []            // [name, …]
    property var recent: []            // [{name, icon, timestamp}, …]

    // ── Launch ─────────────────────────────────────────────────────
    property string launchingApp: ""
    property bool launching: false

    // ── Actions (kept as signals for API compatibility) ────────────
    signal setQueryRequested(string query)
    signal launchRequested(string exec, bool terminal)
    signal pinRequested(string name)
    signal unpinRequested(string name)

    property Connections _actions: Connections {
        target: launcherState
        function onSetQueryRequested(q) {
            launcherState.query = q
            launcherState.filteredApplications = launcherState._applyFilter()
        }
        function onLaunchRequested(exec, terminal) {
            launcherState.launchingApp = exec
            launcherState.launching = true
            launcherState._launchClearTimer.restart()
            var entry = launcherState._findEntry(exec)
            if (entry)
                entry.execute()
        }
        function onPinRequested(name) {
            launcherState._togglePin(name, true)
        }
        function onUnpinRequested(name) {
            launcherState._togglePin(name, false)
        }
    }

    function _findEntry(idOrExec) {
        var vals = DesktopEntries.applications ? DesktopEntries.applications.values : []
        for (var i = 0; i < vals.length; i++) {
            // The viewmodel passes a.exec (execString); match on any of
            // id / execString / name so execute() actually fires.
            if (vals[i].id === idOrExec
                || vals[i].execString === idOrExec
                || vals[i].name === idOrExec)
                return vals[i]
        }
        return null
    }

    function _togglePin(name, add) {
        var list = launcherState.pinned.slice()
        var idx = list.indexOf(name)
        if (add && idx === -1)
            list.push(name)
        else if (!add && idx !== -1)
            list.splice(idx, 1)
        launcherState.pinned = list
    }

    // ── Sync on model changes ──────────────────────────────────────
    property Connections _appsConn: Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            launcherState.applications = launcherState._collectApplications()
            launcherState.filteredApplications = launcherState._applyFilter()
        }
    }

    property Timer _launchClearTimer: Timer {
        interval: 2000
        onTriggered: {
            launcherState.launching = false
            launcherState.launchingApp = ""
        }
    }
}
