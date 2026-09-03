pragma Singleton
import QtQuick
import Quickshell
import qs.settings

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
    // Plain property, not a binding: _applyFilter() reads the usage map
    // (a mutable var), which makes a declarative binding loop-prone when
    // _recordLaunch writes SettingsStore + reassigns in the same chain.
    // Every mutation path recomputes explicitly.
    property var filteredApplications: []

    // Sorted for display:
    //   1) the four most-opened apps (by persisted launch count)
    //   2) everything else, alphabetically (case-insensitive)
    // While typing a query the ordering stays purely alphabetical so
    // results don't jump around as usage counts change.
    function _applyFilter() {
        var q = launcherState.query.toLowerCase()
        var apps = launcherState.applications.slice()
        apps.sort(function(a, b) {
            var na = a.name.toLowerCase()
            var nb = b.name.toLowerCase()
            if (na < nb) return -1
            if (na > nb) return 1
            return 0
        })

        if (q === "") {
            // Top-4 most used first, then the rest alphabetical.
            var used = apps.filter(function(a) {
                return launcherState._usageCount(a.desktopFile) > 0
            })
            used.sort(function(a, b) {
                return launcherState._usageCount(b.desktopFile)
                     - launcherState._usageCount(a.desktopFile)
            })
            var top = used.slice(0, 4)
            var rest = apps.filter(function(a) {
                return top.indexOf(a) === -1
            })
            return top.concat(rest)
        }

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

    // ── Usage counts (most-opened tracking) ────────────────────────
    // desktopFile → launch count. Persisted as JSON in
    // SettingsStore.launcherUsage; loaded on startup, written back on
    // every launch (debounced by ConfigService).
    property var _usage: ({})
    property bool _usageLoaded: false

    function _ensureUsageLoaded() {
        if (launcherState._usageLoaded) return
        launcherState._usageLoaded = true
        try {
            launcherState._usage = JSON.parse(SettingsStore.launcherUsage || "{}")
        } catch (e) {
            launcherState._usage = {}
        }
    }

    function _usageCount(desktopFile) {
        launcherState._ensureUsageLoaded()
        return launcherState._usage[desktopFile] || 0
    }

    function _recordLaunch(desktopFile) {
        if (!desktopFile) return
        launcherState._ensureUsageLoaded()
        launcherState._usage[desktopFile] = launcherState._usage[desktopFile] || 0
        launcherState._usage[desktopFile]++
        // Persist via the settings pipeline (string so JsonAdapter
        // round-trips it cleanly).
        SettingsStore.launcherUsage = JSON.stringify(launcherState._usage)
        // Refresh the sorted view so the promoted app jumps to the top-4.
        launcherState.filteredApplications = launcherState._applyFilter()
    }

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
            if (entry) {
                launcherState._recordLaunch(entry.id)
                entry.execute()
            }
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

    // Populate the plain (non-binding) filteredApplications once the
    // DesktopEntries model is available.
    Component.onCompleted: {
        launcherState.applications = launcherState._collectApplications()
        launcherState.filteredApplications = launcherState._applyFilter()
    }
}
