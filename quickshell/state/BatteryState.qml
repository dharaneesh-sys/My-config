pragma Singleton
import QtQuick
import Quickshell.Services.UPower

QtObject {
    id: batteryState

    // ═══════════════════════════════════════════════════════════════
    //  BatteryState
    //
    //  Reactive battery properties bound directly to the native UPower
    //  service. No upower subprocess, no poll timer, no hardcoded BAT0
    //  path — UPower.displayDevice is the kernel's chosen display
    //  battery.
    // ═══════════════════════════════════════════════════════════════

    property UPowerDevice device: UPower.displayDevice

    // displayDevice is property-constant (NO notify signal) in this
    // Quickshell build — the binding above evaluates once, often before
    // UPower has finished enumerating devices, and never re-evaluates.
    // Re-read it a few times right after startup so the battery actually
    // appears in the panel.
    property int _deviceRetries: 0

    // QtObject cannot hold bare child objects in Qt6 (no default
    // property), so the Timer must be assigned to a named property.
    property Timer deviceRetryTimer: Timer {
        id: retryTimer
        interval: 400
        running: true
        repeat: true
        onTriggered: {
            if (batteryState.device || batteryState._deviceRetries > 20) {
                retryTimer.stop()
                if (batteryState.device)
                    console.log("BatteryState: device resolved ", Math.round(batteryState.device.percentage * 100), "% state", batteryState.device.state)
                return
            }
            batteryState._deviceRetries++
            batteryState.device = UPower.displayDevice
        }
    }

    // ── Battery ────────────────────────────────────────────────────
    // UPower's percentage is a 0–1 fraction (0.48 = 48%) in this build,
    // NOT a 0–100 integer — scale to percent so Math.round() displays
    // correctly everywhere.
    readonly property real percentage: device ? Math.min(100, device.percentage * 100) : 0.0
    readonly property string state: device ? _stateName(device.state) : "Unknown"
    readonly property bool charging: device
                                     ? (device.state === UPowerDeviceState.Charging
                                        || device.state === UPowerDeviceState.PendingCharge)
                                     : false
    readonly property bool acConnected: device ? !UPower.onBattery : false

    // ── Estimated time (seconds, 0 when not applicable) ────────────
    readonly property real timeToFull: device ? device.timeToFull : 0.0
    readonly property real timeToEmpty: device ? device.timeToEmpty : 0.0

    // ── Enum → string mapping ──────────────────────────────────────
    function _stateName(s) {
        switch (s) {
        case UPowerDeviceState.Charging:        return "Charging"
        case UPowerDeviceState.PendingCharge:   return "Charging"
        case UPowerDeviceState.Discharging:     return "Discharging"
        case UPowerDeviceState.PendingDischarge:return "Discharging"
        case UPowerDeviceState.FullyCharged:    return "Full"
        default:                                return "Unknown"
        }
    }
}
