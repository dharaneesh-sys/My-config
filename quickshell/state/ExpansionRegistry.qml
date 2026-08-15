pragma Singleton
import QtQuick

QtObject {
    id: registry

    // ═══════════════════════════════════════════════════════════════
    //  ExpansionRegistry
    //
    //  Decouples panel registration from expansion logic.
    //  Panels register themselves at startup; ExpansionManager
    //  never needs modification when a panel is added.
    //
    //  Registration:
    //    ExpansionRegistry.register("launcher", Qt.resolvedUrl("…"), 420, 450)
    //
    //  Lookup:
    //    ExpansionRegistry.lookup("launcher")
    //      → { component, preferredWidth, preferredHeight }
    //
    //  Iteration:
    //    ExpansionRegistry.allIds() → ["launcher", "control-center", …]
    // ═══════════════════════════════════════════════════════════════

    // ─── Internal storage ─────────────────────────────────────────
    // Keys: panel ID strings
    // Values: { component: url, preferredWidth: real, preferredHeight: real }

    property var _entries: ({})

    // ─── Registration ─────────────────────────────────────────────

    /** Register a panel with the expansion system. */
    function register(id, component, preferredWidth, preferredHeight) {
        var entry = {}
        entry[id] = {
            component: component,
            preferredWidth: preferredWidth,
            preferredHeight: preferredHeight
        }
        _entries = Object.assign({}, _entries, entry)
    }

    /** Unregister a panel (used for dynamic panel removal). */
    function unregister(id) {
        var copy = Object.assign({}, _entries)
        delete copy[id]
        _entries = copy
    }

    // ─── Lookup ───────────────────────────────────────────────────

    /** Look up a registered panel. Returns object or null. */
    function lookup(id) {
        return _entries[id] || null
    }

    /** Check if a panel ID is registered. */
    function isRegistered(id) {
        return _entries.hasOwnProperty(id)
    }

    // ─── Iteration ────────────────────────────────────────────────

    /** All registered panel IDs. */
    function allIds() {
        return Object.keys(_entries)
    }

    /** Number of registered panels. */
    readonly property int count: Object.keys(_entries).length

    // ─── Field accessors ──────────────────────────────────────────

    /** Component URL for a panel ID. Null if unregistered. */
    function componentFor(id) {
        var e = lookup(id)
        return e ? e.component : null
    }

    /** Preferred width for a panel ID. 0 if unregistered. */
    function widthFor(id) {
        var e = lookup(id)
        return e ? e.preferredWidth : 0
    }

    /** Preferred height for a panel ID. 0 if unregistered. */
    function heightFor(id) {
        var e = lookup(id)
        return e ? e.preferredHeight : 0
    }
}
