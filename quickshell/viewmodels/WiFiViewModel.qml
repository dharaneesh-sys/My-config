import QtQuick

import qs.state

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  WiFiViewModel
    //
    //  Presentation adapter for the WiFi panel.
    //  Reads NetworkState, formats presentation data.
    //
    //  • Reads:  NetworkState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits:  nothing (actions flow through State signals)
    // ═══════════════════════════════════════════════════════════════

    // ── Header ─────────────────────────────────────────────────────
    readonly property string headerSubtitle: NetworkState.connected
                                          ? NetworkState.ssid
                                          : "Not connected"

    // ── WiFi toggle ────────────────────────────────────────────────
    readonly property bool wifiEnabled: NetworkState.wifiEnabled

    // ── Current connection ─────────────────────────────────────────
    readonly property bool connected: NetworkState.connected
    readonly property string currentSsid: NetworkState.ssid
    readonly property string strengthLabel: "Strength: " + NetworkState.strength + "%"

    // ── Available networks (ListModel, reconciled in place) ─────────
    // NetworkService wholesale-reassigns NetworkState.availableNetworks
    // on every poll. A fresh JS array per poll would destroy + recreate
    // every Repeater delegate (killing hover state and causing jitter).
    // Instead we keep a ListModel and reconcile: remove rows whose key
    // vanished, setProperty only the fields that actually changed, and
    // append new rows. Steady-state polls perform zero model mutations,
    // so delegates do zero work. (docs/KNOWN_LIMITATIONS.md:160)
    property ListModel availableNetworksModel: ListModel {}

    function _formatEntry(n) {
        return {
            ssid: n.ssid || "Unknown",
            iconName: n.connected
                     ? "signal_wifi_4_bar"
                     : "signal_wifi_status_bar_not_connected",
            subtitle: (n.security || "Open") + " · " + n.strength + "%",
            connected: n.connected,
            rawSsid: n.ssid
        }
    }

    function _syncNetworks() {
        var raw = NetworkState.availableNetworks
        var m = vm.availableNetworksModel

        // 1) Remove rows whose key is no longer in the raw data
        for (var i = m.count - 1; i >= 0; i--) {
            var key = m.get(i).ssid
            var found = false
            for (var j = 0; j < raw.length; j++) {
                if (raw[j].ssid === key) { found = true; break }
            }
            if (!found)
                m.remove(i)
        }

        // 2) Update in place (only changed fields) or append new
        for (var k = 0; k < raw.length; k++) {
            var e = _formatEntry(raw[k])
            var idx = _findIndex(m, "ssid", e.ssid)
            if (idx === -1) {
                m.append(e)
            } else {
                var cur = m.get(idx)
                if (cur.iconName !== e.iconName) m.setProperty(idx, "iconName", e.iconName)
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

    readonly property bool hasNetworks: NetworkState.availableNetworks.length > 0

    // ── Sync on state changes ──────────────────────────────────────
    Connections {
        target: NetworkState
        function onAvailableNetworksChanged() { vm._syncNetworks() }
    }

    Component.onCompleted: _syncNetworks()

    // ── Actions ────────────────────────────────────────────────────
    function toggleWifi()              { NetworkState.setWifiEnabledRequested(!NetworkState.wifiEnabled) }
    function connectToNetwork(ssid)    { NetworkState.connectRequested(ssid, "") }
}
