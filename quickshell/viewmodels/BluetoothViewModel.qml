import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  BluetoothViewModel
    //
    //  Presentation adapter for the Bluetooth panel.
    //  Reads BluetoothState, formats presentation data.
    //
    //  • Reads:  BluetoothState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Header ─────────────────────────────────────────────────────
    readonly property string headerSubtitle: BluetoothState.enabled ? "On" : "Off"

    // ── Adapter ────────────────────────────────────────────────────
    readonly property bool enabled: BluetoothState.enabled
    readonly property bool scanning: BluetoothState.enabled && BluetoothState.scanning
    readonly property string scanLabel: BluetoothState.scanning ? "Scanning…" : "Scan"

    // ── Devices (ListModel, reconciled in place) ────────────────────
    // BluetoothService wholesale-reassigns BluetoothState.devices on
    // every poll. See WiFiViewModel for the reconcile rationale:
    // remove stale rows, setProperty only changed fields, append new.
    property ListModel devicesModel: ListModel {}

    function _formatEntry(d) {
        return {
            name: d.name || "Unknown",
            address: d.address,
            subtitle: d.connected ? "Connected" : (d.paired ? "Paired" : ""),
            connected: d.connected
        }
    }

    function _syncDevices() {
        var raw = BluetoothState.devices
        var m = vm.devicesModel

        // 1) Remove rows whose key is no longer in the raw data
        for (var i = m.count - 1; i >= 0; i--) {
            var key = m.get(i).address
            var found = false
            for (var j = 0; j < raw.length; j++) {
                if (raw[j].address === key) { found = true; break }
            }
            if (!found)
                m.remove(i)
        }

        // 2) Update in place (only changed fields) or append new
        for (var k = 0; k < raw.length; k++) {
            var e = _formatEntry(raw[k])
            var idx = _findIndex(m, "address", e.address)
            if (idx === -1) {
                m.append(e)
            } else {
                var cur = m.get(idx)
                if (cur.name      !== e.name)      m.setProperty(idx, "name", e.name)
                if (cur.subtitle  !== e.subtitle)  m.setProperty(idx, "subtitle", e.subtitle)
                if (cur.connected !== e.connected) m.setProperty(idx, "connected", e.connected)
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

    readonly property bool hasDevices: BluetoothState.devices.length > 0
    readonly property bool showEmptyState: BluetoothState.devices.length === 0 && BluetoothState.enabled

    // ── Sync on state changes ──────────────────────────────────────
    Connections {
        target: BluetoothState
        function onDevicesChanged() { vm._syncDevices() }
    }

    Component.onCompleted: _syncDevices()

    // ── Actions ────────────────────────────────────────────────────
    function toggleEnabled()  { BluetoothState.setEnabledRequested(!BluetoothState.enabled) }
    function scan()           { BluetoothState.scanRequested() }

    function connectDevice(address)    { BluetoothState.connectRequested(address) }
    function disconnectDevice(address)  { BluetoothState.disconnectRequested(address) }
}
