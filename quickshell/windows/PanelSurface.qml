import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.state
import qs.metrics
import qs.tokens
import qs.settings
import qs.motion

PanelWindow {
    id: panelSurface

    // ═══════════════════════════════════════════════════════════════
    //  PanelSurface — the floating expanded-panel window
    //
    //  Second half of the two-window split (Wave 2):
    //  • The pill bar (Shell) keeps a CONSTANT height + strut.
    //  • This window carries the expanded panel content and FLOATS
    //    above tiling windows, positioned just below the pill bar.
    //  • It reserves no screen space (ExclusionMode.Ignore) and is
    //    above tiling windows, so an open panel overlaps them while
    //    the pill bar's strut stays unchanged (issues A/B).
    //
    //  Why PanelWindow (not FloatingWindow): Quickshell 0.3.0's
    //  FloatingWindow exposes no x/y/anchors — position is managed by
    //  the compositor. A full-width top-anchored PanelWindow with a
    //  Region mask achieves the same floating, click-through surface
    //  (the exact pattern Shell.qml already uses for the pill).
    // ═══════════════════════════════════════════════════════════════

    // ── Visibility: ALWAYS mapped ─────────────────────────────────
    // Never toggles visible (that would unmap/remap the layer surface
    // and fire Hyprland's layersIn "slide right" animation). Instead
    // collapse is expressed in QML: panelRect.height springs to 0 and
    // the mask empties, so the surface renders nothing and passes all
    // input through.
    visible: true

    // ── Screen anchoring ───────────────────────────────────────────
    // Full-width strip at the top edge. The panel rect inside is
    // offset below the pill bar and horizontally centered.
    anchors {
        top: true
        left: true
        right: true
    }

    // ── Floating: overlap tiling windows, reserve no space ────────
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    aboveWindows: true

    // ── Focus: interactive only while expanded (needed for Keys) ──
    focusable: ExpansionManager.isExpanded

    // WindowShortcut receives Escape even when focus is inside a loaded
    // panel, a GridView, or the launcher's TextInput. Item-level Keys alone
    // cannot reliably cross those focus scopes.
    Shortcut {
        sequence: "Escape"
        context: Qt.WindowShortcut
        enabled: ExpansionManager.isExpanded
        onActivated: ExpansionManager.requestCollapse()
    }

    // ── Background: transparent (only the panel rect is opaque) ───
    color: "transparent"

    // ── Size ───────────────────────────────────────────────────────
    // Keep the layer-shell surface geometry stable. Resizing a mapped layer
    // window on every animation frame makes some compositors stutter. Only
    // panelRect inside this fixed transparent surface is animated.
    implicitWidth: ExpansionRegistry.widthFor(ExpansionManager.activePanelId)
                   || ShellMetrics.controlCenterWidth
    implicitHeight: (ShellMetrics.notchEnabled ? ShellMetrics.notchHeight : ShellMetrics.pillTopMargin) + ShellMetrics.panelSurfaceHeight

    // ── Shadow spec ────────────────────────────────────────────────
    // Depth parameters for the layered shadow behind panelRect:
    // notch panels hang flush from the screen edge (deep 24px /
    // 0.18 shadow), pills float free (tight 10px / 0.10 shadow).
    readonly property bool shadowNotch: ShellMetrics.notchEnabled
    readonly property real shadowRange: shadowNotch ? 24 : 10
    readonly property real shadowStrength: shadowNotch ? 0.18 : 0.10

    // ── Layered drop shadow ────────────────────────────────────────
    // Qt/Quickshell has no native box-shadow and the shell's depth
    // language forbids blur passes, so two stacked black rectangles
    // behind panelRect fake a soft falloff: a wide faint outer tier
    // plus a tight strong inner tier. Cumulative edge opacity meets
    // the spec (notch 0.18 / pill 0.10). Declared BEFORE panelRect
    // so it paints underneath, and kept out of the input mask, so
    // clicks pass through the shadow zone.
    Rectangle {
        id: shadowOuter

        readonly property real spread: panelSurface.shadowRange
        readonly property real baseRadius: panelSurface.shadowNotch
                ? ShellMetrics.notchCornerRadius
                : Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)

        x: panelRect.x - spread
        y: panelRect.y - spread
        width: panelRect.width + spread * 2
        height: panelRect.height + spread * 2
        radius: baseRadius + spread
        topLeftRadius: panelSurface.shadowNotch ? 0 : baseRadius + spread
        topRightRadius: panelSurface.shadowNotch ? 0 : baseRadius + spread
        bottomLeftRadius: baseRadius + spread
        bottomRightRadius: baseRadius + spread
        color: "#000000"
        opacity: GameModeState.active ? 0 : panelSurface.shadowStrength * 0.4 * panelRect.opacity
        visible: panelRect.visible
    }

    Rectangle {
        id: shadowInner

        readonly property real spread: panelSurface.shadowRange / 2
        readonly property real baseRadius: panelSurface.shadowNotch
                ? ShellMetrics.notchCornerRadius
                : Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)

        x: panelRect.x - spread
        y: panelRect.y - spread
        width: panelRect.width + spread * 2
        height: panelRect.height + spread * 2
        radius: baseRadius + spread
        topLeftRadius: panelSurface.shadowNotch ? 0 : baseRadius + spread
        topRightRadius: panelSurface.shadowNotch ? 0 : baseRadius + spread
        bottomLeftRadius: baseRadius + spread
        bottomRightRadius: baseRadius + spread
        color: "#000000"
        opacity: GameModeState.active ? 0 : panelSurface.shadowStrength * 0.6 * panelRect.opacity
        visible: panelRect.visible
    }

    // ── The centered, floating panel ───────────────────────────────
    Rectangle {
        id: panelRect

        // The panel begins at the pill's exact footprint, then spreads down
        // and outward like a drop landing on water.  `waterExpanded` changes
        // once per transition, so all motion is finite and event-driven.
        readonly property bool opening: ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Opening
        readonly property bool closing: ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Closing
        readonly property bool morphing: opening || closing
        readonly property real targetWidth: ExpansionRegistry.widthFor(ExpansionManager.activePanelId)
                                         || ShellMetrics.controlCenterWidth
        readonly property real targetHeight: panelLoader.item
                                          ? panelLoader.item.implicitHeight + ShellMetrics.expandedPadding * 2
                                          : ExpansionRegistry.heightFor(ExpansionManager.activePanelId)
        property bool waterExpanded: false

        // Positioned just below the pill bar, horizontally centered.
        x: (parent.width - width) / 2
        // During expansion the panel replaces the fading pill, then grows
        // downward over windows. The shell's exclusive zone never changes.
        y: ShellMetrics.notchEnabled ? 0 : ShellMetrics.pillTopMargin

        // Deterministic easing avoids spring retarget jitter while panel
        // loaders and asynchronous content settle their implicit sizes.
        width: waterExpanded ? targetWidth : (ShellMetrics.notchEnabled ? ShellMetrics.notchWidth : ShellMetrics.pillWidth)
        Behavior on width {
            enabled: MotionConfig.animationsEnabled
            NumberAnimation {
                duration: MotionConfig.duration(panelRect.opening
                                                ? SettingsStore.expandDuration
                                                : SettingsStore.collapseDuration)
                easing.type: panelRect.opening ? Easing.OutBack : Easing.InBack
            }
        }

        // Height eases from 0 (collapsed) → content height (expanded).
        // Pure QML animation — the window stays mapped the whole time.
        // CRITICAL: the collapsed height MUST be 0 (not pillHeight) — the
        // Region mask is geometry-driven (visibility is ignored), so a
        // non-zero collapsed panelRect would leave a click-stealing input
        // region over the pill and break pill clicks.
        height: waterExpanded
                ? targetHeight
                : (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Collapsed
                   ? 0
                   : (ShellMetrics.notchEnabled ? ShellMetrics.notchHeight : ShellMetrics.pillHeight))
        Behavior on height {
            enabled: MotionConfig.animationsEnabled
            NumberAnimation {
                duration: MotionConfig.duration(panelRect.opening
                                                ? SettingsStore.expandDuration
                                                : SettingsStore.collapseDuration)
                easing.type: panelRect.opening ? Easing.OutBack : Easing.InBack
            }
        }

        // Fade panel content in/out in sync with the height spring.
        opacity: ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Collapsed ? 0.0 : 1.0
        Behavior on opacity {
            enabled: MotionConfig.animationsEnabled
            NumberAnimation {
                duration: MotionConfig.duration(Motion.duration.fast)
                easing.type: Motion.easing.standard
            }
        }

        // Skip rendering while fully collapsed (height springs to 0).
        visible: ExpansionManager.lifecycle !== ExpansionManager.Lifecycle.Collapsed

        // Notch mode: flat top (attached to screen edge via notch), rounded bottom.
        // Every panel toggles to notch when enabled — SettingsWindow excluded (separate FloatingWindow).
        radius: ShellMetrics.notchEnabled ? ShellMetrics.notchCornerRadius : Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)
        topLeftRadius: ShellMetrics.notchEnabled ? 0 : Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)
        topRightRadius: ShellMetrics.notchEnabled ? 0 : Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)
        bottomLeftRadius: Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)
        bottomRightRadius: Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)
        color: Colors.surface
        border.width: Elevation.panel.borderWidth
        border.color: Colors.borderStrong
        clip: true

        // Crisp layered edges: depth comes from opaque material tiers, never
        // blur or wallpaper show-through.
        Rectangle {
            anchors { fill: parent; margins: 1 }
            radius: ShellMetrics.notchEnabled ? ShellMetrics.notchCornerRadius - 1 : Math.max(0, parent.radius - 1)
            topLeftRadius: ShellMetrics.notchEnabled ? 0 : Math.max(0, parent.radius - 1)
            topRightRadius: ShellMetrics.notchEnabled ? 0 : Math.max(0, parent.radius - 1)
            bottomLeftRadius: Math.max(0, parent.radius - 1)
            bottomRightRadius: Math.max(0, parent.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: Colors.fg
            opacity: GameModeState.active ? 0 : (ShellMetrics.notchEnabled ? 0.08 : 0.055)
        }

        // Capture Escape before a child TextInput/Grid consumes it. This
        // keeps the close shortcut reliable for every expanded panel.
        focus: true
        Keys.priority: Keys.BeforeItem
        Keys.onEscapePressed: (event) => {
            ExpansionManager.requestCollapse()
            event.accepted = true
        }

        // ── Panel content loader ──────────────────────────────────
        // Resolves the active panel via ExpansionRegistry.
        Loader {
            id: panelLoader
            anchors {
                fill: parent
                margins: ShellMetrics.expandedPadding
            }
            source: ExpansionManager.lifecycle !== ExpansionManager.Lifecycle.Collapsed
                    ? (ExpansionRegistry.componentFor(ExpansionManager.activePanelId) || "")
                    : ""
            opacity: panelRect.waterExpanded ? 1.0 : 0.0
            scale: panelRect.waterExpanded ? 1.0 : 0.985
            transformOrigin: Item.Top

            Behavior on opacity {
                enabled: MotionConfig.animationsEnabled
                NumberAnimation {
                    duration: MotionConfig.duration(Motion.panel.contentFadeIn)
                    easing.type: Motion.easing.standard
                }
            }
            Behavior on scale {
                enabled: MotionConfig.animationsEnabled
                NumberAnimation {
                    duration: MotionConfig.duration(Motion.panel.contentFadeIn)
                    easing.type: Motion.easing.decelerate
                }
            }
        }
    }

    // Let the initial pill geometry render for one event-loop turn before
    // expanding.  This avoids a compositor remap and creates a continuous
    // morph within the permanently mapped layer surface.
    Timer {
        id: waterStageTimer
        interval: 1
        repeat: false
        onTriggered: {
            panelRect.waterExpanded = ExpansionManager.lifecycle !== ExpansionManager.Lifecycle.Closing
            transitionCompletionTimer.interval = Math.max(1, MotionConfig.duration(
                ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Opening
                    ? SettingsStore.expandDuration
                    : SettingsStore.collapseDuration))
            transitionCompletionTimer.restart()
        }
    }

    Timer {
        id: transitionCompletionTimer
        repeat: false
        onTriggered: {
            if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Opening)
                ExpansionManager.onOpenCompleted()
            else if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Closing)
                ExpansionManager.onCloseCompleted()
            else if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Switching)
                ExpansionManager.onSwitchCompleted()
        }
    }

    Connections {
        target: ExpansionManager
        function onLifecycleChanged() {
            if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Opening) {
                panelRect.waterExpanded = false
                waterStageTimer.restart()
            } else if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Closing) {
                panelRect.waterExpanded = true
                waterStageTimer.restart()
            } else if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Switching) {
                panelRect.waterExpanded = true
                transitionCompletionTimer.interval = Math.max(1, MotionConfig.duration(Motion.panel.swapDuration))
                transitionCompletionTimer.restart()
            }
        }
    }

    // ── Mask ───────────────────────────────────────────────────────
    // Collapsed: item is null → empty region → the whole surface is
    // transparent and passes all input through (pill stays interactive).
    // Expanded: only the panel rect is opaque/clickable. Tracks the
    // animated rectangle, so the opaque region morphs with the spring
    // while the window geometry stays full-width.
    mask: Region {
        // Always track panelRect: height 0 while collapsed yields an
        // empty region (fully transparent/pass-through). Binding
        // directly avoids a null-then-item switch that Quickshell
        // cannot pick up live (empty mask stays forever).
        item: panelRect
    }
}
