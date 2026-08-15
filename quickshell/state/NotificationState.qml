pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: notificationState

    // ═══════════════════════════════════════════════════════════════
    //  NotificationState
    //
    //  Hosts Quickshell's native NotificationServer (org.freedesktop.
    //  Notifications). swaync has been dropped from the session — it
    //  previously held the DBus name this server now owns.
    //
    //  Notifications are tracked via the server's `notification`
    //  signal (fires once per received notification) instead of the
    //  `trackedNotifications` model — in this Quickshell build the
    //  model's Changed signal never fired, so the panel stayed empty.
    //  Each Notification's `closed` signal removes it from the list.
    //  A best-effort model mirror on startup covers keepOnReload.
    // ═══════════════════════════════════════════════════════════════

    // ── Native server ──────────────────────────────────────────────
    property NotificationServer server: NotificationServer {
        keepOnReload: true
        persistenceSupported: false
    }

    // ── Notifications (newest first) ───────────────────────────────
    // [{id, appName, iconName, title, body, timestamp, urgency, read}]
    property var notifications: []

    // id → native Notification object (dismiss + closed wiring)
    property var _objects: ({})

    // ── Counts ─────────────────────────────────────────────────────
    readonly property int unreadCount: _countUnread()
    readonly property int totalCount: notifications.length

    // ── DND (local flag; no native DND in 0.3.0) ───────────────────
    property bool dnd: false

    // ── Read-state tracking (survives model resyncs) ───────────────
    property var _readIds: []

    // ── Actions (kept as signals for API compatibility) ────────────
    signal dismissRequested(string id)
    signal dismissAllRequested()
    signal markReadRequested(string id)
    signal markAllReadRequested()
    signal setDndRequested(bool enabled)
    signal invokeActionRequested(string id, int actionIndex)

    // ── Track a newly received notification ────────────────────────
    function _add(n) {
        var id = String(n.id)
        console.log("NotificationState: received", id, n.appName || "",
                    (n.summary || "").replace(/\n/g, " ").slice(0, 48))
        notificationState._objects[id] = n

        var list = notificationState.notifications.filter(x => x.id !== id)
        list.unshift({
            id: id,
            appName: n.appName || "",
            iconName: n.appIcon || "",
            title: n.summary || "",
            body: n.body || "",
            timestamp: "",
            urgency: _urgencyName(n.urgency),
            read: notificationState._readIds.indexOf(id) !== -1
        })
        notificationState.notifications = list

        // Drop from the list when the server closes/dismisses it.
        if (n.closed) {
            n.closed.connect(function() { notificationState._remove(id) })
        }
    }

    function _remove(id) {
        if (!notificationState._objects[id]) return
        delete notificationState._objects[id]
        notificationState.notifications =
            notificationState.notifications.filter(x => x.id !== id)
    }

    // ── Best-effort mirror of the tracked model (reload recovery) ──
    // Only useful right after a keepOnReload restart; live arrivals
    // always flow through the `notification` signal.
    function _sync() {
        var model = notificationState.server.trackedNotifications
        var vals = model ? model.values : []
        if (!vals || vals.length === 0) return
        for (var i = 0; i < vals.length; i++) {
            var n = vals[i]
            if (n) notificationState._add(n)
        }
    }

    function _urgencyName(u) {
        switch (u) {
        case NotificationUrgency.Low:      return "low"
        case NotificationUrgency.Critical: return "critical"
        default:                           return "normal"
        }
    }

    function _countUnread() {
        var count = 0
        var list = notificationState.notifications
        for (var i = 0; i < list.length; i++) {
            if (!list[i].read)
                count++
        }
        return count
    }

    // ── Actions ────────────────────────────────────────────────────
    property Connections _actions: Connections {
        target: notificationState
        function onDismissRequested(id) {
            var obj = notificationState._objects[id]
            if (obj)
                obj.dismiss()
            notificationState._remove(id)
        }
        function onDismissAllRequested() {
            var ids = notificationState.notifications.map(x => x.id)
            for (var i = 0; i < ids.length; i++)
                notificationState._remove(ids[i])
        }
        function onMarkReadRequested(id) {
            if (notificationState._readIds.indexOf(id) === -1)
                notificationState._readIds.push(id)
            var list = notificationState.notifications
            for (var i = 0; i < list.length; i++) {
                if (list[i].id === id)
                    list[i].read = true
            }
            notificationState.notifications = list
        }
        function onMarkAllReadRequested() {
            var list = notificationState.notifications
            for (var i = 0; i < list.length; i++)
                list[i].read = true
            notificationState._readIds = list.map(x => x.id)
            notificationState.notifications = list
        }
        function onSetDndRequested(e) {
            notificationState.dnd = e
        }
        function onInvokeActionRequested(id, actionIndex) {
            var notification = notificationState._objects[id]
            var actions = notification && notification.actions
                ? notification.actions : []
            if (actionIndex >= 0 && actionIndex < actions.length)
                actions[actionIndex].invoke()
        }
    }

    // ── Live arrivals from the server ──────────────────────────────
    property Connections _serverConn: Connections {
        target: notificationState.server
        function onNotification(n) {
            if (n) notificationState._add(n)
        }
    }

    Component.onCompleted: {
        notificationState._sync()
    }

    function actionsFor(id) {
        var notification = _objects[id]
        return notification && notification.actions ? notification.actions : []
    }

    function hasActionIconsFor(id) {
        var notification = _objects[id]
        return notification ? notification.hasActionIcons : false
    }
}
