pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.settings

// Owns Night Light independently of any individual panel loader. Hyprsunset
// talks to Hyprland's compositor directly, avoiding the one-shot wlroots gamma
// path that made repeated gammastep toggles unreliable.
QtObject {
    id: nightLightState

    // Keep a local, immediately updated state for the tile. The persisted
    // setting is mirrored explicitly below so a config reload cannot break
    // the binding or leave the control centre in a stale visual state.
    property bool enabled: false
    readonly property int temperature: 3500

    function _apply(value) {
        // Quickshell may be launched by the user service without the live
        // Hyprland environment. Resolve the active compositor socket at call
        // time, then pass its environment explicitly to hyprsunset.
        var command = "runtime=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}; "
                    + "signature=$(find \"$runtime/hypr\" -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' 2>/dev/null | head -n 1); "
                    + "display=$(find \"$runtime\" -maxdepth 1 -type s -name 'wayland-*' -printf '%f\\n' 2>/dev/null | head -n 1); "
                    + "export XDG_RUNTIME_DIR=\"$runtime\" HYPRLAND_INSTANCE_SIGNATURE=\"$signature\" WAYLAND_DISPLAY=\"${display:-wayland-0}\"; "
                    + "exec hyprctl -i \"$signature\" hyprsunset " + (value ? "temperature \"$1\"" : "identity")
        sunsetCommand.command = value
            ? ["sh", "-c", command, "night-light", String(temperature)]
            : ["sh", "-c", command]
        sunsetCommand.running = true
    }

    Component.onCompleted: {
        enabled = SettingsStore.nightLightEnabled
        _apply(enabled)
    }

    property Connections _settingsConnection: Connections {
        target: SettingsStore
        function onNightLightEnabledChanged() {
            if (nightLightState.enabled === SettingsStore.nightLightEnabled)
                return
            nightLightState.enabled = SettingsStore.nightLightEnabled
            nightLightState._apply(nightLightState.enabled)
        }
    }

    function setEnabled(value) {
        if (enabled === value)
            return
        enabled = value
        SettingsStore.nightLightEnabled = value
        _apply(value)
    }

    function toggle() {
        setEnabled(!enabled)
    }

    property Process _sunsetCommand: Process {
        id: sunsetCommand
        command: []
        onExited: (code, status) => {
            if (code !== 0)
                console.warn("NightLight: Hyprland IPC command failed with code", code)
        }
    }
}
