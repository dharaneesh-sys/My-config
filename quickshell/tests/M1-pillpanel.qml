import QtQuick
import Quickshell

import qs.state
import qs.metrics
import qs.settings
import qs.components

// ═══════════════════════════════════════════════════════════════
//  M1 — PillPanel merge verification (Wave 1)
//
//  Verifies the in-place expansion contract:
//   1. Collapsed:  pill geometry (pillWidth x pillHeight @ pillCornerRadius)
//   2. Expanded:   panel geometry (max(pillW, prefW) x pillH+margin+prefH+pad*2
//                  @ panelCornerRadius), inputCatch visible
//   3. Collapsed again after requestCollapse
//
//  animationsEnabled=false → Behaviors disabled → instant morphs,
//  so geometry asserts are deterministic.
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

    // ── Phase 1: register test panel + assert collapsed state ──
    Timer {
        id: phase1Timer
        interval: 1
        onTriggered: {
            ExpansionRegistry.register(
                "test-panel",
                Qt.resolvedUrl("panels/TestPanel.qml"),
                340,   // preferredWidth
                360    // preferredHeight
            )

            check("collapsed-width", Math.round(pillPanel.width) === SettingsStore.pillWidth)
            check("collapsed-height", Math.round(pillPanel.height) === SettingsStore.pillHeight)
            check("collapsed-surface-w", Math.round(pillPanel.surface.width) === SettingsStore.pillWidth)
            check("collapsed-surface-h", Math.round(pillPanel.surface.height) === SettingsStore.pillHeight)
            check("collapsed-radius", Math.round(pillPanel.surface._cornerRadius) === SettingsStore.pillCornerRadius)
            check("collapsed-inputcatch-hidden", pillPanel.inputCatch.visible === false)

            ExpansionManager.requestExpand("test-panel")
            phase2Timer.start()
        }
    }

    // ── Phase 2: assert expanded geometry ──
    Timer {
        id: phase2Timer
        interval: 1
        onTriggered: {
            var expectedW = Math.max(SettingsStore.pillWidth, 340)
            var expectedH = SettingsStore.pillHeight
                            + SettingsStore.pillBottomMargin
                            + 360
                            + SettingsStore.panelPadding * 2

            check("expanded-width", Math.round(pillPanel.width) === expectedW)
            check("expanded-height", Math.round(pillPanel.height) === expectedH)
            check("expanded-surface-w", Math.round(pillPanel.surface.width) === expectedW)
            check("expanded-surface-h", Math.round(pillPanel.surface.height) === expectedH)
            check("expanded-radius", Math.round(pillPanel.surface._cornerRadius) === SettingsStore.panelCornerRadius)
            check("expanded-inputcatch-visible", pillPanel.inputCatch.visible === true)
            check("expanded-loader-source", pillPanel.panelLoader.source.toString().indexOf("TestPanel.qml") !== -1)

            ExpansionManager.requestCollapse()
            phase3Timer.start()
        }
    }

    // ── Phase 3: assert collapsed again ──
    Timer {
        id: phase3Timer
        interval: 1
        onTriggered: {
            check("recollapsed-width", Math.round(pillPanel.width) === SettingsStore.pillWidth)
            check("recollapsed-height", Math.round(pillPanel.height) === SettingsStore.pillHeight)
            check("recollapsed-radius", Math.round(pillPanel.surface._cornerRadius) === SettingsStore.pillCornerRadius)
            check("recollapsed-inputcatch-hidden", pillPanel.inputCatch.visible === false)
            check("recollapsed-loader-empty", pillPanel.panelLoader.source.toString() === "")

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
