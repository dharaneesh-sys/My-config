pragma Singleton
import QtCore
import QtQuick
import Quickshell
import Quickshell.Io
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
        // REQUIRED for inline replies (WhatsApp/Telegram/Signal "Reply"
        // field): with this disabled the app's "inline-reply" action is
        // misparsed as a plain button and sendInlineReply() hard-fails
        // ("Inline reply support disabled on server").
        inlineReplySupported: true
    }

    // ── Notifications (newest first) ───────────────────────────────
    // [{id, appName, iconName, title, body, timestamp, urgency, read}]
    property var notifications: []

    // ── History (newest first, persists across shell restarts) ─────
    // A log of received notifications. Survives `quickshell` process
    // restarts but NOT a system reboot: persisted to $XDG_RUNTIME_DIR
    // (wiped on logout/reboot). Dismissed/expired notifications stay in
    // history — it is a LOG, not the live list. Capped at 50 entries.
    // [{id, appName, iconName, title, body, timestamp, urgency}]
    property var history: []

    // id → native Notification object (dismiss + closed wiring)
    property var _objects: ({})

    // ── Counts ─────────────────────────────────────────────────────
    readonly property int unreadCount: _countUnread()
    readonly property int totalCount: notifications.length

    // ── DND (local flag; no native DND in 0.3.0) ───────────────────
    property bool dnd: false

    // ── Sync gate: prevents OSD popups during startup re-sync ────
    // _sync() re-adds tracked notifications on startup/reload; each
    // _add() triggers notificationsChanged, which PillPanel reacts to
    // by showing an OSD. This flag suppresses that until sync finishes.
    property bool _syncComplete: false

    // ── Read-state tracking (survives model resyncs) ───────────────
    property var _readIds: []

    // ── History persistence ($XDG_RUNTIME_DIR, survives shell
    //    restart, NOT reboot — the runtime dir is wiped on logout) ──
    readonly property string _historyPath: StandardPaths.writableLocation(StandardPaths.RuntimeLocation)
                                           + "/quickshell/notification-history.json"

    // QtObject has no default child property, so the FileView (and its
    // JsonAdapter) must be assigned to a named property — same pattern
    // as the `_actions` Connections below.
    property FileView _historyFile: FileView {
        id: historyFile
        path: notificationState._historyPath
        preload: true
        atomicWrites: true
        printErrors: true

        onLoaded: function() {
            // Disk → adapter → history. The adapter's `entries` var is
            // populated by JsonAdapter from the file; copy it into the
            // singleton property (which the UI binds).
            var raw = historyDisk.entries
            notificationState.history = Array.isArray(raw) ? raw : []
            notificationState.historyChanged()
        }

        onLoadFailed: function() {
            // Missing/corrupt file → empty history; nothing to restore.
            notificationState.history = []
            notificationState.historyChanged()
        }

        JsonAdapter {
            id: historyDisk
            property var entries: []
        }
    }

    function _saveHistory() {
        if (notificationState._historyPath === "") return
        historyDisk.entries = notificationState.history
        historyFile.writeAdapter()
    }

    function _pushHistory(entry) {
        var list = notificationState.history.slice()
        list.unshift(entry)
        // Cap at 50 entries (newest first).
        if (list.length > 50)
            list = list.slice(0, 50)
        notificationState.history = list
        notificationState.historyChanged()
        notificationState._saveHistory()
    }

    // ── Actions (kept as signals for API compatibility) ────────────
    signal dismissRequested(string id)
    signal dismissAllRequested()
    signal markReadRequested(string id)
    signal markAllReadRequested()
    signal setDndRequested(bool enabled)
    signal invokeActionRequested(string id, int actionIndex)
    signal sendInlineReplyRequested(string id, string text)
    signal clearHistoryRequested()

    // ── Track a newly received notification ────────────────────────
    function _add(n) {
        var id = String(n.id)
        console.log("NotificationState: received", id, n.appName || "",
                    (n.summary || "").replace(/\n/g, " ").slice(0, 48))

        // REQUIRED: keep the native Notification object alive past this
        // signal handler. Without this the server destroys the object as
        // soon as onNotification returns, nulling every property (actions,
        // hasInlineReply, ...) and leaving the trackedNotifications model
        // empty. Every production config (end-4, omarchy, iNiR, ...) sets
        // this before capturing the notification reference.
        n.tracked = true

        notificationState._objects[id] = n

        var ts = Qt.formatTime(new Date(), "hh:mm")

        var list = notificationState.notifications.filter(x => x.id !== id)
        list.unshift({
            id: id,
            appName: n.appName || "",
            iconName: n.appIcon || "",
            title: n.summary || "",
            body: n.body || "",
            timestamp: ts,
            urgency: _urgencyName(n.urgency),
            read: notificationState._readIds.indexOf(id) !== -1
        })
        notificationState.notifications = list

        // Log to history (survives shell restart; dismissed/expired
        // notifications remain in the log).
        notificationState._pushHistory({
            id: id,
            appName: n.appName || "",
            iconName: n.appIcon || "",
            title: n.summary || "",
            body: n.body || "",
            timestamp: ts,
            urgency: _urgencyName(n.urgency)
        })

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
        if (!vals || vals.length === 0) {
            notificationState._syncComplete = true
            return
        }
        for (var i = 0; i < vals.length; i++) {
            var n = vals[i]
            if (n) notificationState._add(n)
        }
        notificationState._syncComplete = true
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
        function onClearHistoryRequested() {
            notificationState.history = []
            notificationState.historyChanged()
            notificationState._saveHistory()
        }
        function onInvokeActionRequested(id, actionIndex) {
            var notification = notificationState._objects[id]
            var actions = notification && notification.actions
                ? notification.actions : []
            if (actionIndex >= 0 && actionIndex < actions.length)
                actions[actionIndex].invoke()
        }
        function onSendInlineReplyRequested(id, text) {
            if (!text || text.trim() === "") return
            var notification = notificationState._objects[id]
            if (!notification) return
            // Emits NotificationReplied over DBus; the app receives the
            // reply. Quickshell closes the notification afterwards (unless
            // it is resident), which removes the card via `closed`.
            notification.sendInlineReply(text)
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

    /** True when the app advertised an "inline-reply" action (reply field). */
    function hasInlineReplyFor(id) {
        var notification = _objects[id]
        return notification ? notification.hasInlineReply : false
    }

    /** Placeholder text the app requested for the inline reply field. */
    function inlineReplyPlaceholderFor(id) {
        var notification = _objects[id]
        return notification ? notification.inlineReplyPlaceholder : ""
    }
}
