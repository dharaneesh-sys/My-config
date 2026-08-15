import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  NotificationCenterViewModel
    //
    //  Presentation adapter for the NotificationCenter panel.
    //  Reads NotificationState, formats/sorts presentation data.
    //
    //  • Reads:  NotificationState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Header subtitle ────────────────────────────────────────────
    readonly property string headerSubtitle: NotificationState.unreadCount > 0
                                           ? NotificationState.unreadCount + " unread"
                                           : ""

    // ── DND ────────────────────────────────────────────────────────
    readonly property bool dnd: NotificationState.dnd

    // ── Notifications (ListModel, reconciled in place) ─────────────
    // NotificationState rebuilds notifications from the native server on
    // every trackedNotifications change (and dismiss/mark-read). A fresh JS array per change
    // would destroy + recreate every NotificationCard delegate — breaking
    // hover state and causing flicker. Reconcile instead: remove stale
    // rows, setProperty only changed fields, append new. Steady-state
    // polls mutate nothing. (docs/KNOWN_LIMITATIONS.md:160)
    property ListModel notificationsModel: ListModel {}

    function _formatEntry(n) {
        return {
            notifId: n.id,
            appName: n.appName || "",
            iconName: n.iconName || "",
            title: n.title || "",
            body: n.body || "",
            timestamp: n.timestamp || ""
        }
    }

    function _syncNotifications() {
        var raw = NotificationState.notifications
        var m = vm.notificationsModel

        // 1) Remove rows whose key is no longer in the raw data
        for (var i = m.count - 1; i >= 0; i--) {
            var key = m.get(i).notifId
            var found = false
            for (var j = 0; j < raw.length; j++) {
                if (raw[j].id === key) { found = true; break }
            }
            if (!found)
                m.remove(i)
        }

        // 2) Update in place (only changed fields) or append new
        for (var k = 0; k < raw.length; k++) {
            var e = _formatEntry(raw[k])
            var idx = _findIndex(m, "notifId", e.notifId)
            if (idx === -1) {
                m.append(e)
            } else {
                var cur = m.get(idx)
                if (cur.appName  !== e.appName)  m.setProperty(idx, "appName", e.appName)
                if (cur.iconName !== e.iconName) m.setProperty(idx, "iconName", e.iconName)
                if (cur.title    !== e.title)    m.setProperty(idx, "title", e.title)
                if (cur.body     !== e.body)     m.setProperty(idx, "body", e.body)
                if (cur.timestamp !== e.timestamp) m.setProperty(idx, "timestamp", e.timestamp)
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

    // ── Has notifications ──────────────────────────────────────────
    readonly property bool hasNotifications: NotificationState.notifications.length > 0

    // ── Sync on state changes ──────────────────────────────────────
    property Connections _stateConn: Connections {
        target: NotificationState
        function onNotificationsChanged() { vm._syncNotifications() }
    }

    Component.onCompleted: _syncNotifications()

    // ── Actions ────────────────────────────────────────────────────
    function toggleDnd() {
        NotificationState.setDndRequested(!NotificationState.dnd)
    }

    function dismiss(id) {
        NotificationState.dismissRequested(id)
    }

    function markRead(id) {
        NotificationState.markReadRequested(id)
    }

    function actionsFor(id) { return NotificationState.actionsFor(id) }
    function hasActionIconsFor(id) { return NotificationState.hasActionIconsFor(id) }
    function invokeAction(id, actionIndex) {
        NotificationState.invokeActionRequested(id, actionIndex)
    }

    function dismissAll() {
        NotificationState.dismissAllRequested()
    }
}
