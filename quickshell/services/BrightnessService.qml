import Quickshell
import QtQuick
import Quickshell.Io

import qs.state

Item {
    id: brightnessService

    // ═══════════════════════════════════════════════════════════════
    //  BrightnessService
    //
    //  No native Quickshell API for backlight control, so brightnessctl
    //  polling stays. The exitCode race has been fixed: parsing moved
    //  into onExited where the real exit code is available, instead of
    //  onStreamFinished (which fires before onExited).
    // ═══════════════════════════════════════════════════════════════

    // Hardware brightness keys run an external brightnessctl helper. Poll at
    // a short interval so its change reaches the pill OSD promptly, while
    // remaining far lighter than a per-frame watcher.
    property int pollInterval: 300

    // ── Get brightness ─────────────────────────────────────────────
    Process {
        id: getBrightness
        command: ["brightnessctl", "info"]
        stdout: StdioCollector { id: getBrightnessOut }
        onExited: (code, status) => {
            if (code !== 0) return
            var curMatch = getBrightnessOut.text.match(/\((\d+)%\)/)
            if (curMatch)
                BrightnessState.brightness = parseInt(curMatch[1]) / 100
        }
    }

    function setBrightness(v) {
        var pct = Math.round(Math.max(0, Math.min(1, v)) * 100)
        setBrightnessCmd.command = ["brightnessctl", "set", pct + "%"]
        setBrightnessCmd.running = true
    }

    Process { id: setBrightnessCmd; command: [] }

    // ── Keyboard backlight ─────────────────────────────────────────
    Process {
        id: getKbdBrightness
        command: ["brightnessctl", "-d", "kbd_backlight", "info"]
        stdout: StdioCollector { id: getKbdBrightnessOut }
        onExited: (code, status) => {
            if (code !== 0) return
            var curMatch = getKbdBrightnessOut.text.match(/\((\d+)%\)/)
            if (curMatch)
                BrightnessState.kbdBrightness = parseInt(curMatch[1]) / 100
        }
    }

    function setKbdBrightness(v) {
        var pct = Math.round(Math.max(0, Math.min(1, v)) * 100)
        setKbdCmd.command = ["brightnessctl", "-d", "kbd_backlight", "set", pct + "%"]
        setKbdCmd.running = true
    }

    Process { id: setKbdCmd; command: [] }

    Timer {
        interval: brightnessService.pollInterval
        running: true
        repeat: true
        onTriggered: {
            getBrightness.running = true
            getKbdBrightness.running = true
        }
    }

    Component.onCompleted: {
        getBrightness.running = true
        getKbdBrightness.running = true
    }

    Connections {
        target: BrightnessState
        function onSetBrightnessRequested(v) { brightnessService.setBrightness(v) }
        function onSetKbdBrightnessRequested(v) { brightnessService.setKbdBrightness(v) }
    }
}
