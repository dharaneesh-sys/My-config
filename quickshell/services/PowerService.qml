import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

import qs.state

Item {
    id: powerService

    // ═══════════════════════════════════════════════════════════════
    //  PowerService
    //
    //  Executes system power commands via loginctl.
    //  Handles shell management actions (reload, restart, quit).
    //  Writes to PowerState.
    //  State → Service dependency: PowerState signals → Service.
    // ═══════════════════════════════════════════════════════════════

    // ── Session processes ──────────────────────────────────────────
    Process {
        id: lockProcess
        command: ["sh", "-c", "pidof hyprlock >/dev/null || exec hyprlock"]
    }

    Process {
        id: suspendProcess
        command: ["loginctl", "suspend"]
    }

    Process {
        id: rebootProcess
        command: ["loginctl", "reboot"]
    }

    Process {
        id: shutdownProcess
        command: ["loginctl", "poweroff"]
    }

    // ── System management processes ────────────────────────────────
    Process {
        id: openConfigDirProcess
        command: ["xdg-open", StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell"]
    }

    Process {
        id: showLogsProcess
        // Open a terminal showing the most recent quickshell logs
        command: ["sh", "-c", "foot -e journalctl --user -u quickshell -f &"]
    }

    // ── State → Service wiring ─────────────────────────────────────
    Connections {
        target: PowerState

        function onLockRequested() {
            PowerState.locked = true
            lockProcess.running = true
        }

        function onSuspendRequested() {
            PowerState.suspending = true
            suspendProcess.running = true
        }

        function onRebootRequested() {
            rebootProcess.running = true
        }

        function onShutdownRequested() {
            shutdownProcess.running = true
        }

        // ── Shell management ──────────────────────────────────
        function onReloadShellRequested() {
            // Quickshell IPC: reload the shell configuration
            Qt.callLater(function() { Quickshell.reload() })
        }

        function onRestartShellRequested() {
            // Full restart: quit and let the service manager respawn
            shutdownProcess.command = ["sh", "-c", "systemctl --user restart quickshell"]
            shutdownProcess.running = true
        }

        function onQuitShellRequested() {
            Qt.quit()
        }

        function onOpenConfigDirRequested() {
            openConfigDirProcess.running = true
        }

        function onShowLogsRequested() {
            showLogsProcess.running = true
        }
    }
}
