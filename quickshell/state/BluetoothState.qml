pragma Singleton
import QtQuick
import Quickshell.Bluetooth
import Quickshell.Io

QtObject {
    id: bluetoothState

    // ═══════════════════════════════════════════════════════════════
    //  BluetoothState
    //
    //  Reactive Bluetooth properties bound directly to the native
    //  BlueZ service. No bluetoothctl subprocesses, no poll timer.
    //
    //  adapter.devices is a live model; we mirror it into the JS-array
    //  contract. A short timer reconciles device property changes
    //  (connected/paired) that fire on the device objects rather than
    //  the model — cheap in-process reads, no subprocesses.
    // ═══════════════════════════════════════════════════════════════

    // ── Adapter ────────────────────────────────────────────────────
    property var adapter: Bluetooth.defaultAdapter

    readonly property bool enabled: adapter ? adapter.enabled : false
    readonly property bool scanning: adapter ? adapter.discovering : false
    property string actionStatus: ""
    property string lastError: ""
    property string pendingAddress: ""

    // ── Devices ────────────────────────────────────────────────────
    property var devices: _collectDevices()

    function _collectDevices() {
        var out = []
        var a = bluetoothState.adapter
        if (!a) return out
        var vals = a.devices ? a.devices.values : []
        for (var i = 0; i < vals.length; i++) {
            var d = vals[i]
            out.push({
                name: d.name || d.deviceName || "Unknown",
                address: d.address,
                type: d.icon || "unknown",
                connected: d.connected,
                paired: d.paired || d.bonded
            })
        }
        return out
    }

    readonly property string connectedDevice: _firstConnectedName()

    function _firstConnectedName() {
        var list = bluetoothState.devices
        for (var i = 0; i < list.length; i++) {
            if (list[i].connected)
                return list[i].name
        }
        return ""
    }

    // ── Actions (kept as signals for API compatibility) ────────────
    signal setEnabledRequested(bool enabled)
    signal connectRequested(string address)
    signal disconnectRequested(string address)
    signal pairRequested(string address)
    signal unpairRequested(string address)
    signal scanRequested()

    // A soft rfkill block prevents BlueZ from enabling an otherwise healthy
    // adapter. Unblock first, then enable only after rfkill confirms the
    // request completed; this avoids the rejected assignment seen in logs.
    property bool _enableAfterUnblock: false
    property Process _rfkillUnblock: Process {
        command: ["rfkill", "unblock", "bluetooth"]
        onExited: (code, status) => {
            if (bluetoothState._enableAfterUnblock && code === 0
                    && bluetoothState.adapter)
                bluetoothState.adapter.enabled = true
            bluetoothState._enableAfterUnblock = false
        }
    }

    property Connections _actions: Connections {
        target: bluetoothState
        function onSetEnabledRequested(e) {
            if (!bluetoothState.adapter) return
            if (e) {
                bluetoothState._enableAfterUnblock = true
                bluetoothState._rfkillUnblock.running = true
            } else {
                bluetoothState.adapter.enabled = e
            }
        }
        function onConnectRequested(address) {
            var d = bluetoothState._findDevice(address)
            if (!d) return
            bluetoothState.pendingAddress = address
            bluetoothState.actionStatus = "Connecting to " + (d.name || "device") + "…"
            bluetoothState.lastError = ""
            d.connect()
        }
        function onDisconnectRequested(address) {
            var d = bluetoothState._findDevice(address)
            if (!d) return
            bluetoothState.actionStatus = "Disconnecting " + (d.name || "device") + "…"
            bluetoothState.lastError = ""
            d.disconnect()
        }
        function onPairRequested(address) {
            var d = bluetoothState._findDevice(address)
            if (!d) return
            bluetoothState.pendingAddress = address
            bluetoothState.actionStatus = "Pairing " + (d.name || "device") + "…"
            bluetoothState.lastError = ""
            d.pair()
        }
        function onUnpairRequested(address) {
            var d = bluetoothState._findDevice(address)
            if (d) d.forget()
        }
        function onScanRequested() {
            if (!bluetoothState.adapter) return
            bluetoothState.adapter.discovering = true
            bluetoothState._scanTimer.restart()
        }
    }

    function _findDevice(address) {
        var a = bluetoothState.adapter
        if (!a) return null
        var vals = a.devices ? a.devices.values : []
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].address === address)
                return vals[i]
        }
        return null
    }

    // ── Reconcile devices ──────────────────────────────────────────
    property Timer _reconcileTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            bluetoothState.devices = bluetoothState._collectDevices()
            var pending = bluetoothState._findDevice(bluetoothState.pendingAddress)
            if (pending && pending.connected) {
                bluetoothState.actionStatus = "Connected to " + (pending.name || "device")
                bluetoothState.pendingAddress = ""
            }
        }
    }

    property Timer _scanTimer: Timer {
        interval: 10000
        onTriggered: {
            if (bluetoothState.adapter)
                bluetoothState.adapter.discovering = false
            bluetoothState.devices = bluetoothState._collectDevices()
        }
    }

    property Connections _adapterConn: Connections {
        target: Bluetooth
        function onDefaultAdapterChanged() {
            bluetoothState.devices = bluetoothState._collectDevices()
        }
    }
}
