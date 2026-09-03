pragma Singleton
import QtQuick
import Quickshell.Networking
import Quickshell.Io

QtObject {
    id: networkState

    // ═══════════════════════════════════════════════════════════════
    //  NetworkState
    //
    //  Reactive network properties bound directly to the native
    //  NetworkManager service. No nmcli subprocesses, no poll timer.
    //
    //  Networking.devices is a live model of NetworkDevice objects; the
    //  wifi device exposes a networks model of WifiNetwork objects.
    //  Both are mirrored into JS-array contracts below. A short timer
    //  reconciles per-network changes (strength/connected) that fire on
    //  the objects rather than the model — in-process reads only.
    // ═══════════════════════════════════════════════════════════════

    // ── WiFi ───────────────────────────────────────────────────────
    readonly property bool wifiEnabled: Networking.wifiEnabled

    property var _wifiDevice: _findDevice(DeviceType.Wifi)
    property var _wiredDevice: _findDevice(DeviceType.Wired)
    readonly property bool scanning: _wifiDevice ? _wifiDevice.scannerEnabled : false

    function _findDevice(type) {
        var vals = Networking.devices ? Networking.devices.values : []
        for (var i = 0; i < vals.length; i++) {
            if (vals[i].type === type)
                return vals[i]
        }
        return null
    }

    // ── Available networks ─────────────────────────────────────────
    property var availableNetworks: _collectNetworks()
    // NetworkManager profile names normally match the SSID. Keep a small
    // cached list so the UI can distinguish a saved network from a new one.
    property var savedNetworkNames: []

    function isSavedNetwork(ssid) {
        return savedNetworkNames.indexOf(ssid) !== -1
    }

    function _collectNetworks() {
        var out = []
        var w = networkState._wifiDevice
        if (!w || !w.networks) return out
        var vals = w.networks.values
        for (var i = 0; i < vals.length; i++) {
            var n = vals[i]
            // Quickshell builds expose signalStrength either as 0–1 or as
            // 0–100 depending on the NetworkManager backend version.
            var rawStrength = Number(n.signalStrength)
            var strengthPercent = rawStrength <= 1 ? rawStrength * 100 : rawStrength
            out.push({
                ssid: n.name || "",
                strength: Math.round(strengthPercent),
                security: _securityName(n.security),
                connected: n.connected,
                saved: networkState.isSavedNetwork(n.name || "")
            })
        }
        return out
    }

    function _securityName(s) {
        switch (s) {
        case WifiSecurityType.Wpa3SuiteB192: return "WPA3"
        case WifiSecurityType.Sae:            return "WPA3"
        case WifiSecurityType.Wpa2Eap:        return "WPA2-EAP"
        case WifiSecurityType.Wpa2Psk:        return "WPA2"
        case WifiSecurityType.WpaEap:         return "WPA-EAP"
        case WifiSecurityType.WpaPsk:         return "WPA"
        case WifiSecurityType.StaticWep:      return "WEP"
        default:                              return "Open"
        }
    }

    // ── Current connection (from the connected network) ────────────
    readonly property bool connected: _connectedNetwork() !== null
    readonly property string ssid: connected ? _connectedNetwork().ssid : ""
    readonly property int strength: connected ? _connectedNetwork().strength : 0
    readonly property string security: connected ? _connectedNetwork().security : ""

    function _connectedNetwork() {
        var list = networkState.availableNetworks
        for (var i = 0; i < list.length; i++) {
            if (list[i].connected)
                return list[i]
        }
        return null
    }

    // ── Wired ──────────────────────────────────────────────────────
    readonly property bool wiredConnected: _wiredDevice ? _wiredDevice.connected : false
    readonly property string wiredDevice: _wiredDevice ? _wiredDevice.name : ""

    // ── Actions (kept as signals for API compatibility) ────────────
    signal setWifiEnabledRequested(bool enabled)
    signal connectRequested(string ssid, string password)
    signal disconnectRequested()
    signal scanRequested()
    // Emitted when a connect attempt fails, so the panel can offer a
    // password fallback (a saved secret may be stale — e.g. the phone
    // hotspot password changed since the last successful connect).
    signal connectFailed(string ssid, string message)

    // Connection feedback is surfaced by the Wi-Fi panel. NetworkManager's
    // native connect API handles saved profiles, while nmcli gives us a
    // reliable password path for newly selected secured networks.
    property string connectingSsid: ""
    property string connectionStatus: ""
    property string lastError: ""
    property Process _connectProcess: Process {
        command: []
        stderr: StdioCollector { id: connectError }
        onExited: (code, status) => {
            var failedSsid = networkState.connectingSsid
            if (code === 0) {
                networkState.connectionStatus = "Connected to " + networkState.connectingSsid
                networkState.lastError = ""
                networkState.scanRequested()
            } else {
                networkState.connectionStatus = ""
                var msg = connectError.text.trim() || "Could not connect"
                networkState.lastError = msg
                // Surface a fallback signal so the panel can re-prompt for a
                // password when the saved secret is stale.
                if (failedSsid)
                    networkState.connectFailed(failedSsid, msg)
            }
            networkState.connectingSsid = ""
        }
    }

    property Process _savedProfilesProcess: Process {
        // The terse format is one profile per line: NAME:TYPE.  We only need
        // wireless profile names; passwords never leave NetworkManager.
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector { id: savedProfilesOutput }
        onExited: (code, status) => {
            if (code !== 0) return
            var names = []
            var lines = savedProfilesOutput.text.trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var suffix = ":802-11-wireless"
                if (!lines[i].endsWith(suffix)) continue
                // nmcli escapes literal colons in profile names as \\:, so
                // split from the known type suffix rather than on every colon.
                var name = lines[i].slice(0, -suffix.length).replace(/\\\\:/g, ":").replace(/\\\\\\\\/g, "\\\\")
                if (name.length > 0) names.push(name)
            }
            networkState.savedNetworkNames = names
            networkState.availableNetworks = networkState._collectNetworks()
        }
    }

    function refreshSavedProfiles() {
        if (!networkState._savedProfilesProcess.running)
            networkState._savedProfilesProcess.running = true
    }

    property Connections _actions: Connections {
        target: networkState
        function onSetWifiEnabledRequested(e) {
            Networking.wifiEnabled = e
        }
        function onConnectRequested(ssid, password) {
            if (!ssid || networkState._connectProcess.running) return
            networkState.connectingSsid = ssid
            networkState.connectionStatus = "Connecting to " + ssid + "…"
            networkState.lastError = ""
            var command
            if (password === "" && networkState.isSavedNetwork(ssid)) {
                // `device wifi connect` resolves the network by the scanned
                // access point, not by profile name. `connection up id` trusts
                // the profile name, which breaks when duplicate/stale profiles
                // exist for the same SSID (the wrong one gets activated and
                // the connection times out). nmcli still reuses the saved
                // secret from the matching profile, so no re-prompt occurs.
                command = ["nmcli", "--wait", "30", "device", "wifi", "connect", ssid]
            } else {
                command = ["nmcli", "--wait", "30", "device", "wifi", "connect", ssid]
                if (password !== "") command.push("password", password)
            }
            networkState._connectProcess.command = command
            networkState._connectProcess.running = true
        }
        function onDisconnectRequested() {
            var w = networkState._wifiDevice
            if (!w) return
            w.disconnect()
        }
        function onScanRequested() {
            var w = networkState._wifiDevice
            if (w)
                w.scannerEnabled = true
            networkState._scanTimer.restart()
            networkState.refreshSavedProfiles()
        }
    }

    // ── Reconcile networks ─────────────────────────────────────────
    // Networking.devices is a constant model reference; per-network
    // property changes fire on the objects, not the model. A light
    // timer re-reads the in-process model (no subprocesses).
    property Timer _reconcileTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            networkState._wifiDevice = networkState._findDevice(DeviceType.Wifi)
            networkState._wiredDevice = networkState._findDevice(DeviceType.Wired)
            networkState.availableNetworks = networkState._collectNetworks()
        }
    }

    Component.onCompleted: refreshSavedProfiles()

    property Timer _scanTimer: Timer {
        interval: 10000
        onTriggered: {
            var w = networkState._wifiDevice
            if (w)
                w.scannerEnabled = false
        }
    }
}
