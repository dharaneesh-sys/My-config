import QtQuick

import qs.state
import qs.tokens

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  ControlCenterViewModel
    //
    //  Presentation adapter between State singletons and the
    //  ControlCenter panel UI. Prepares sorted, formatted data.
    //
    //  • Reads: AudioState, BrightnessState, NetworkState,
    //           BluetoothState, MediaState, NotificationState,
    //           BatteryState, ThemeState
    //  • Writes: nothing (pure read-only presentation)
    //  • Emits: nothing (actions flow through State signals)
    //
    //  UI never formats, filters, or sorts — ViewModel does it here.
    // ═══════════════════════════════════════════════════════════════

    // ── Quick toggle tiles ──────────────────────────────────────────
    // Single owner of the tile data: quickTilesModel is the ONLY source
    // the grid Repeater binds to. No JS-array mirror is built anymore
    // (that used to force a full array + delegate rebuild per state
    // change). Properties are updated in-place via setProperty(), so only
    // the changed delegate re-renders.
    //
    // Actions are dispatched by tile index via the stable tileActions
    // array (index → closure), which reads State at click time.

    property ListModel quickTilesModel: ListModel {
        ListElement { iconName: "wifi";              title: "Wi-Fi";      subtitle: ""; active: false }
        ListElement { iconName: "bluetooth";         title: "Bluetooth";  subtitle: ""; active: false }
        ListElement { iconName: "bedtime";           title: "Night Light";subtitle: ""; active: false }
        ListElement { iconName: "battery_saver";     title: "Battery Saver"; subtitle: ""; active: false }
    }

    // Index → action closure. Must mirror quickTilesModel row order.
    property var tileActions: [
        function() { ExpansionManager.requestExpand("wifi") },
        function() { ExpansionManager.requestExpand("bluetooth") },
        function() { vm.toggleNightLight() },
        function() { GameModeState.toggleRequested() }
    ]

    // Update ListModel in-place when state changes (no delegate churn)
    function _syncModel() {
        if (quickTilesModel.count < 4) return
        // Icons reflect state: wifi_off when disabled, signal bars when connected
        quickTilesModel.setProperty(0, "iconName", NetworkState.wifiEnabled ? (NetworkState.connected ? "wifi" : "wifi_off") : "wifi_off")
        quickTilesModel.setProperty(0, "subtitle", NetworkState.connected ? NetworkState.ssid : (NetworkState.wifiEnabled ? "On" : "Off"))
        quickTilesModel.setProperty(0, "active",   NetworkState.wifiEnabled)
        // Bluetooth: show connected vs plain
        quickTilesModel.setProperty(1, "iconName", BluetoothState.enabled ? (BluetoothState.connectedDevice !== "" ? "bluetooth_connected" : "bluetooth") : "bluetooth_disabled")
        quickTilesModel.setProperty(1, "subtitle", BluetoothState.enabled ? (BluetoothState.connectedDevice !== "" ? "Connected" : "On") : "Off")
        quickTilesModel.setProperty(1, "active",   BluetoothState.enabled)
        quickTilesModel.setProperty(2, "iconName", "bedtime")
        quickTilesModel.setProperty(2, "subtitle", vm.nightLightOn ? "On" : "Off")
        quickTilesModel.setProperty(2, "active",   vm.nightLightOn)
        quickTilesModel.setProperty(3, "subtitle", GameModeState.active ? "On" : "Off")
        quickTilesModel.setProperty(3, "active",   GameModeState.active)
    }

    Component.onCompleted: _syncModel()

    // Sync model on state changes (in-place updates, no delegate churn).
    // QtObject cannot hold bare child objects in Qt6 — each Connections
    // must be assigned to a named property or the type fails to load.
    property Connections _networkConn: Connections {
        target: NetworkState
        function onWifiEnabledChanged() { vm._syncModel() }
        function onConnectedChanged()   { vm._syncModel() }
        function onSsidChanged()        { vm._syncModel() }
    }
    property Connections _bluetoothConn: Connections {
        target: BluetoothState
        function onEnabledChanged() { vm._syncModel() }
    }
    property Connections _themeConn: Connections {
        target: ThemeState
        function onCurrentLabelChanged() { vm._syncModel() }
    }
    property Connections _nightLightConn: Connections {
        target: NightLightState
        function onEnabledChanged() { vm._syncModel() }
    }
    property Connections _gameModeConn: Connections {
        target: GameModeState
        function onActiveChanged() { vm._syncModel() }
    }

    // ── Volume ─────────────────────────────────────────────────────
    // Level-accurate Material glyph: off (muted), down (quiet), up.
    readonly property string volumeIcon: AudioState.muted ? "volume_off"
                                       : AudioState.volume < 0.35 ? "volume_down"
                                       : "volume_up"
    readonly property real volumeValue: AudioState.volume
    readonly property bool volumeMuted: AudioState.muted
    readonly property string volumeText: Math.round(AudioState.volume * 100) + "%"

    // ── Brightness ──────────────────────────────────────────────────
    // Level-accurate Material glyph: low / medium / high.
    readonly property string brightnessIcon: BrightnessState.brightness < 0.3 ? "brightness_low"
                                             : BrightnessState.brightness < 0.7 ? "brightness_medium"
                                             : "brightness_high"
    readonly property real brightnessValue: BrightnessState.brightness
    readonly property string brightnessText: Math.round(BrightnessState.brightness * 100) + "%"

    // ── Media ──────────────────────────────────────────────────────
    readonly property bool hasMedia: MediaState.title !== ""
    readonly property string mediaTitle: MediaState.title
    readonly property string mediaArtist: MediaState.artist
    readonly property url mediaArtwork: MediaState.artwork
    readonly property bool mediaPlaying: MediaState.playing

    // ── Notifications summary ──────────────────────────────────────
    readonly property int unreadCount: NotificationState.unreadCount
    readonly property string unreadText: NotificationState.unreadCount > 0
                                        ? NotificationState.unreadCount + " new"
                                        : "No notifications"

    // ── Battery ────────────────────────────────────────────────────
    // Show the widget whenever a device exists — even at exactly 0%
    // charge (percentage > 0 would hide it at empty).
    readonly property bool hasBattery: BatteryState.device !== null
    readonly property string batteryIcon: _batteryIconFor(BatteryState.percentage, BatteryState.charging)
    readonly property real batteryPercentage: BatteryState.percentage
    readonly property bool batteryCharging: BatteryState.charging
    readonly property string batteryText: Math.round(BatteryState.percentage) + "%"

    // Level-accurate Material battery glyph (battery_5_bar etc.) so the
    // icon reflects the real charge, not a generic "full".
    function _batteryIconFor(p, charging) {
        if (charging) {
            if (p >= 95) return "battery_charging_full"
            if (p >= 70) return "battery_charging_80"
            if (p >= 50) return "battery_charging_60"
            if (p >= 30) return "battery_charging_50"
            return "battery_charging_30"
        }
        if (p >= 95) return "battery_full"
        if (p >= 80) return "battery_6_bar"
        if (p >= 60) return "battery_5_bar"
        if (p >= 40) return "battery_4_bar"
        if (p >= 20) return "battery_3_bar"
        if (p >= 10) return "battery_2_bar"
        if (p > 0)   return "battery_1_bar"
        return "battery_0_bar"
    }

    // ── Actions ────────────────────────────────────────────────────
    function setVolume(val)        { AudioState.setVolumeRequested(val) }
    function setBrightness(val)    { BrightnessState.setBrightnessRequested(val) }
    function playPause()           { MediaState.playPauseRequested() }
    function next()                { MediaState.nextRequested() }
    function previous()            { MediaState.previousRequested() }
    function openNotificationCenter() { ExpansionManager.requestExpand("notification-center") }
    
    // ── Night Light ────────────────────────────────────────────────
    // State belongs to the shell, not this loader-created view model.
    readonly property bool nightLightOn: NightLightState.enabled
    function toggleNightLight() {
        NightLightState.toggle()
    }
}
