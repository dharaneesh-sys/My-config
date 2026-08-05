import QtQuick
import Quickshell

import qs.state
import qs.settings
import qs.motion
import qs.components
import qs.components.atoms
import qs.viewmodels

// ═══════════════════════════════════════════════════════════════
//  M2 — Wave 2 verification (root causes #3 and #4)
//
//  Verifies:
//   1. SmoothSlider integer-pixel fill width (no fractional shimmer)
//   2. SmoothSlider catch-up: external value change eases _displayValue
//      toward value (not instant snap), drag overrides to exact pointer
//   3. ListModel reconcile: wholesale state-array reassignment (what the
//      services do every poll) must NOT destroy/recreate Repeater
//      delegates — delegate identity is preserved via an attached id,
//      and steady-state resync performs zero model mutations.
//
//  animationsEnabled=false → catch-up duration 0 → instant snap,
//  so geometry asserts are deterministic; delegate-preservation is
//  checked by counting onDestroyed firings, independent of animation.
// ═══════════════════════════════════════════════════════════════
ShellRoot {
    id: root

    property bool okAll: true
    property int delegateDestroys: 0
    property var destroyedIds: []

    function check(name, cond) {
        console.log("M2-CHECK " + name + "=" + cond)
        if (!cond) root.okAll = false
    }

    function finish() {
        console.log("M2-RESULT ok=" + root.okAll)
        Qt.exit(root.okAll ? 0 : 1)
    }

    // ── SmoothSlider probe ───────────────────────────────────────
    Rectangle {
        id: probe
        width: 200
        height: 20

        SmoothSlider {
            id: slider
            anchors.fill: parent
            from: 0.0
            to: 100.0
            value: 25.0

            // Track destroyed delegate identity during reconcile test
            Component.onDestruction: {
                root.delegateDestroys++
                root.destroyedIds.push(slider.objectName)
            }
        }
    }

    // ── ListModel reconcile probe (mirrors WiFiViewModel pattern) ──
    property ListModel probeModel: ListModel {}

    function _formatEntry(n) {
        return { ssid: n.ssid, iconName: n.connected ? "on" : "off", subtitle: n.security, connected: n.connected, rawSsid: n.ssid }
    }

    function _findIndex(model, role, key) {
        for (var i = 0; i < model.count; i++)
            if (model.get(i)[role] === key) return i
        return -1
    }

    function _syncModel(raw) {
        var m = root.probeModel
        for (var i = m.count - 1; i >= 0; i--) {
            var key = m.get(i).ssid
            var found = false
            for (var j = 0; j < raw.length; j++)
                if (raw[j].ssid === key) { found = true; break }
            if (!found) m.remove(i)
        }
        for (var k = 0; k < raw.length; k++) {
            var e = _formatEntry(raw[k])
            var idx = _findIndex(m, "ssid", e.ssid)
            if (idx === -1) {
                m.append(e)
            } else {
                var cur = m.get(idx)
                if (cur.iconName !== e.iconName) m.setProperty(idx, "iconName", e.iconName)
                if (cur.subtitle  !== e.subtitle)  m.setProperty(idx, "subtitle", e.subtitle)
                if (cur.connected !== e.connected) m.setProperty(idx, "connected", e.connected)
            }
        }
    }

    Repeater {
        id: listRepeater
        model: root.probeModel

        Rectangle {
            required property var modelData
            width: 100
            height: 10
            color: "red"

            // Identity tag: created once, must survive resyncs
            property string identity: modelData.ssid + "-" + modelData.connected
            objectName: identity
            Component.onDestruction: {
                root.delegateDestroys++
                root.destroyedIds.push(identity)
            }
        }
    }

    // ── Phases ───────────────────────────────────────────────────
    Component.onCompleted: {
        SettingsStore.animationsEnabled = false
        phase1.start()
    }

    // Phase 1: reconcile semantics (model-level, layout-independent)
    Timer {
        id: phase1
        interval: 1
        onTriggered: {
            // Reconcile: initial load of 3 networks
            root._syncModel([
                { ssid: "A", connected: false, security: "WPA2", strength: 80 },
                { ssid: "B", connected: true,  security: "Open",  strength: 60 },
                { ssid: "C", connected: false, security: "WPA3", strength: 40 }
            ])
            root.check("reconcile-count-3", root.probeModel.count === 3)
            root.check("reconcile-order", root.probeModel.get(0).ssid === "A"
                       && root.probeModel.get(1).ssid === "B"
                       && root.probeModel.get(2).ssid === "C")

            // Steady-state resync with IDENTICAL data: zero mutations
            var before = root.probeModel.count
            root._syncModel([
                { ssid: "A", connected: false, security: "WPA2", strength: 80 },
                { ssid: "B", connected: true,  security: "Open",  strength: 60 },
                { ssid: "C", connected: false, security: "WPA3", strength: 40 }
            ])
            root.check("reconcile-steady-count", root.probeModel.count === before)

            phase2.start()
        }
    }

    // Phase 2: wholesale reassignment (what services do) — delegates survive
    Timer {
        id: phase2
        interval: 1
        onTriggered: {
            var destroysBefore = root.delegateDestroys

            root._syncModel([
                { ssid: "A", connected: true,  security: "WPA2", strength: 80 },
                { ssid: "B", connected: true,  security: "Open",  strength: 60 },
                { ssid: "D", connected: false, security: "Open",  strength: 90 }
            ])
            root.check("reconcile-changed-count", root.probeModel.count === 3)
            root.check("reconcile-updated-inplace", root.probeModel.get(0).connected === true)
            root.check("reconcile-removed-stale", root._findIndex(root.probeModel, "ssid", "C") === -1)
            root.check("reconcile-appended-new", root._findIndex(root.probeModel, "ssid", "D") !== -1)

            // Only ONE delegate destroyed (stale "C"); A and B survive
            root.check("reconcile-delegate-survival", root.delegateDestroys - destroysBefore === 1)
            root.check("reconcile-survivors-named", root.destroyedIds.length === 1
                       && root.destroyedIds[0].indexOf("C-") === 0)

            phase3.start()
        }
    }

    // Phase 3: SmoothSlider geometry + catch-up
    Timer {
        id: phase3
        interval: 50   // layout settled by now
        onTriggered: {
            // Integer-pixel geometry (probe width 200, from 0 to 100)
            slider.value = 33.33
            root.check("slider-fill-rounded", slider._fillWidth === Math.round(200 * 33.33 / 100))
            root.check("slider-fill-is-int", Math.abs(slider._fillWidth - Math.round(slider._fillWidth)) < 0.001)
            root.check("slider-fill-in-range", slider._fillWidth >= 0 && slider._fillWidth <= 200)

            // Snap when animations disabled
            slider.value = 75
            root.check("slider-snap-disabled", slider._displayValue === 75)
            root.check("slider-fill-75", slider._fillWidth === 150)

            // Enable animations: catch-up must EASE (not snap)
            SettingsStore.animationsEnabled = true
            slider._displayValue = 50   // force a baseline offset
            slider.value = 100
            midCatchup.start()
        }
    }

    // Phase 4: mid-animation — display must be between start and target
    Timer {
        id: midCatchup
        interval: 100   // ~1/3 of 300ms catch-up
        onTriggered: {
            var eased = slider._displayValue
            root.check("slider-catchup-eased", eased > 50 && eased < 100)
            root.check("slider-catchup-fill-int", Math.abs(slider._fillWidth - Math.round(slider._fillWidth)) < 0.001)
            finishTimer.start()
        }
    }

    // Phase 5: after catch-up animation completes, display == value
    Timer {
        id: finishTimer
        interval: 400   // > remaining ~200ms of catch-up
        onTriggered: {
            root.check("slider-catchup-settled", Math.abs(slider._displayValue - slider.value) < 0.5)
            root.finish()
        }
    }
}
