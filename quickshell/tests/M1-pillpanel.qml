import QtQuick
import Quickshell

import qs.state
import qs.metrics
import qs.settings
import qs.components

// ═══════════════════════════════════════════════════════════════
//  M1 — PillPanel verification (Wave 2: two-window split)
//
//  Verifies the pill bar contract after the split:
//   1. Pill geometry is FIXED: pillWidth x pillHeight @ pillCornerRadius
//   2. Surface tracks the pill exactly (mask target)
//   3. Visibility follows clockShowInPill (independent of expansion)
//   4. Expanding does NOT change the pill geometry — the panel now
//      lives in the separate PanelSurface window.
// ═══════════════════════════════════════════════════════════════
ShellRoot {
    id: root

    property bool okAll: true
    function check(name, cond) {
        console.log("M1-CHECK " + name + "=" + cond)
        if (!cond) root.okAll = false
    }

    Component.onCompleted: {
        SettingsStore.animationsEnabled = false
        phase1Timer.start()
    }

    // ── Phase 1: assert fixed pill geometry + visibility ──
    Timer {
        id: phase1Timer
        interval: 1
        onTriggered: {
            check("pill-width", Math.round(pillPanel.width) === Math.round(SettingsStore.pillWidth))
            check("pill-height", Math.round(pillPanel.height) === Math.round(SettingsStore.pillHeight))
            check("surface-w", Math.round(pillPanel.surface.width) === Math.round(SettingsStore.pillWidth))
            check("surface-h", Math.round(pillPanel.surface.height) === Math.round(SettingsStore.pillHeight))
            check("surface-radius", Math.round(pillPanel.surface.radius) === Math.round(SettingsStore.pillCornerRadius))
            check("pill-visible", pillPanel.visible === SettingsStore.clockShowInPill)

            // Expanding must NOT resize the pill (geometry is constant).
            ExpansionRegistry.register(
                "test-panel",
                Qt.resolvedUrl("panels/TestPanel.qml"),
                340,   // preferredWidth
                360    // preferredHeight
            )
            ExpansionManager.requestExpand("test-panel")
            phase2Timer.start()
        }
    }

    // ── Phase 2: assert geometry unchanged while expanded ──
    Timer {
        id: phase2Timer
        interval: 1
        onTriggered: {
            check("expanded-pill-width", Math.round(pillPanel.width) === Math.round(SettingsStore.pillWidth))
            check("expanded-pill-height", Math.round(pillPanel.height) === Math.round(SettingsStore.pillHeight))
            check("expanded-surface-w", Math.round(pillPanel.surface.width) === Math.round(SettingsStore.pillWidth))
            check("expanded-surface-h", Math.round(pillPanel.surface.height) === Math.round(SettingsStore.pillHeight))
            check("expanded-pill-visible", pillPanel.visible === SettingsStore.clockShowInPill)

            ExpansionManager.requestCollapse()
            console.log("M1-RESULT ok=" + root.okAll)
            Qt.exit(root.okAll ? 0 : 1)
        }
    }

    // ── Component under test ────────────────────────────────────
    PillPanel {
        id: pillPanel
        anchors.centerIn: parent
    }
}
