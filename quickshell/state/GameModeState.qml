pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: gameMode

    // ═══════════════════════════════════════════════════════════════
    //  GameModeState
    //
    //  Toggled by Super+F1 (hyprland-lua bind → quickshell IPC).
    //  Game mode disables ALL Hyprland animations + decorations (blur, shadow)
    //  and all quickshell decorative/animative (via MotionConfig/GameModeState)
    //  — functional kept (launcher, control center, etc.).
    //
    //  The compositor state is applied with `hyprctl keyword`, which is
    //  surgical — it never touches the other decoration settings. On
    //  shell startup the active flag is re-synced from Hyprland so a
    //  quickshell reload can't desync from the compositor.
    // ═══════════════════════════════════════════════════════════════

    property bool active: false

    signal toggleRequested()

    onToggleRequested: function() {
        gameMode.active = !gameMode.active
        _apply()
    }

    // Process helpers (QtObject has no default child property, so they
    // must be assigned to named properties — same pattern as the
    // FileView in NotificationState).
    property Process hyprctlAnim: Process {
        id: animProc
        command: []
        onExited: function(code) {
            if (code !== 0)
                console.warn("GameMode: hyprctl animations failed (" + code + ")")
        }
    }

    property Process hyprctlBlur: Process {
        id: blurProc
        command: []
        onExited: function(code) {
            if (code !== 0)
                console.warn("GameMode: hyprctl blur failed (" + code + ")")
        }
    }

    property Process hyprctlShadow: Process {
        id: shadowProc
        command: []
        onExited: function(code) {
            if (code !== 0)
                console.warn("GameMode: hyprctl shadow failed (" + code + ")")
        }
    }

    // Battery mode: zero gaps/rounding for power saving
    property Process hyprctlGapsIn: Process { id: gapsInProc; command: []; onExited: function(c){ if(c!==0) console.warn("GameMode: gaps_in failed") } }
    property Process hyprctlGapsOut: Process { id: gapsOutProc; command: []; onExited: function(c){ if(c!==0) console.warn("GameMode: gaps_out failed") } }
    property Process hyprctlRounding: Process { id: roundingProc; command: []; onExited: function(c){ if(c!==0) console.warn("GameMode: rounding failed") } }
    function _apply() {
        var enabled = gameMode.active ? "false" : "true"
        var gaps = gameMode.active ? "0" : "6"
        var rounding = gameMode.active ? "0" : "20"
        animProc.command = ["hyprctl", "eval", "hl.config({ animations = { enabled = " + enabled + " } })"]
        animProc.running = true
        blurProc.command = ["hyprctl", "eval", "hl.config({ decoration = { blur = { enabled = " + enabled + " } } })"]
        blurProc.running = true
        shadowProc.command = ["hyprctl", "eval", "hl.config({ decoration = { shadow = { enabled = " + enabled + " } } })"]
        shadowProc.running = true
        gapsInProc.command = ["hyprctl", "eval", "hl.config({ general = { gaps_in = " + gaps + " } })"]
        gapsInProc.running = true
        gapsOutProc.command = ["hyprctl", "eval", "hl.config({ general = { gaps_out = " + gaps + " } })"]
        gapsOutProc.running = true
        roundingProc.command = ["hyprctl", "eval", "hl.config({ decoration = { rounding = " + rounding + " } })"]
        roundingProc.running = true
        console.info("GameMode: " + (gameMode.active
            ? "ON — battery saver: no animations/blur/shadow, gaps 0, rounding 0 — quickshell decorative off"
            : "OFF — restored: animations/blur/shadow, gaps 6, rounding 20"))
    }

    // ── Startup sync ───────────────────────────────────────────────
    // Re-read the compositor's current state so a shell restart while
    // game mode was active keeps the flag in sync (no manual re-toggle).
    property Process hyprctlRead: Process {
        id: readProc
        command: ["hyprctl", "getoption", "animations:enabled"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: function() {
                // Output is "bool: true" (animations ON = game mode off)
                // or "bool: false" (animations OFF = game mode active).
                gameMode.active = text.indexOf("bool: false") !== -1
            }
        }
    }
}
