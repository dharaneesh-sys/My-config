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
        ListElement { iconName: "do_not_disturb_on"; title: "DND";        subtitle: ""; active: false }
        ListElement { iconName: "contrast";          title: "Theme";      subtitle: ""; active: false }
    }

    // Index → action closure. Must mirror quickTilesModel row order.
    property var tileActions: [
        function() { NetworkState.setWifiEnabledRequested(!NetworkState.wifiEnabled) },
        function() { BluetoothState.setEnabledRequested(!BluetoothState.enabled) },
        function() { NotificationState.setDndRequested(!NotificationState.dnd) },
        function() { ThemeState.nextRequested() }
    ]

    // Update ListModel in-place when state changes (no delegate churn)
    function _syncModel() {
        if (quickTilesModel.count < 4) return
        quickTilesModel.setProperty(0, "subtitle", NetworkState.connected ? NetworkState.ssid : "Off")
        quickTilesModel.setProperty(0, "active",   NetworkState.wifiEnabled)
        quickTilesModel.setProperty(1, "subtitle", BluetoothState.enabled ? "On" : "Off")
        quickTilesModel.setProperty(1, "active",   BluetoothState.enabled)
        quickTilesModel.setProperty(2, "subtitle", NotificationState.dnd ? "On" : "Off")
        quickTilesModel.setProperty(2, "active",   NotificationState.dnd)
        quickTilesModel.setProperty(3, "subtitle", ThemeState.currentLabel)
    }

    Component.onCompleted: _syncModel()

    // Sync model on state changes (in-place updates, no delegate churn)
    Connections {
        target: NetworkState
        function onWifiEnabledChanged() { vm._syncModel() }
        function onConnectedChanged()   { vm._syncModel() }
        function onSsidChanged()        { vm._syncModel() }
    }
    Connections {
        target: BluetoothState
        function onEnabledChanged() { vm._syncModel() }
    }
    Connections {
        target: NotificationState
        function onDndChanged() { vm._syncModel() }
    }
    Connections {
        target: ThemeState
        function onCurrentLabelChanged() { vm._syncModel() }
    }

    // ── Volume ─────────────────────────────────────────────────────
    readonly property string volumeIcon: AudioState.muted ? "volume_off" : "volume_up"
    readonly property real volumeValue: AudioState.volume
    readonly property bool volumeMuted: AudioState.muted
    readonly property string volumeText: Math.round(AudioState.volume * 100) + "%"

    // ── Brightness ──────────────────────────────────────────────────
    readonly property string brightnessIcon: "brightness_6"
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
    readonly property bool hasBattery: BatteryState.percentage > 0
    readonly property string batteryIcon: BatteryState.charging
                                        ? "battery_charging_full"
                                        : "battery_full"
    readonly property string batteryText: Math.round(BatteryState.percentage) + "%"

    // ── Actions ────────────────────────────────────────────────────
    function setVolume(val)        { AudioState.setVolumeRequested(val) }
    function setBrightness(val)    { BrightnessState.setBrightnessRequested(val) }
    function playPause()           { MediaState.playPauseRequested() }
    function next()                { MediaState.nextRequested() }
    function previous()            { MediaState.previousRequested() }
    function openNotificationCenter() { ExpansionManager.requestExpand("notification-center") }
}
