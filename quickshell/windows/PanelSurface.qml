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
    implicitHeight: ShellMetrics.pillTopMargin + ShellMetrics.panelSurfaceHeight

    // ── The centered, floating panel ───────────────────────────────
    Rectangle {
        id: panelRect

        // Positioned just below the pill bar, horizontally centered.
        x: (parent.width - width) / 2
        // During expansion the panel replaces the fading pill, then grows
        // downward over windows. The shell's exclusive zone never changes.
        y: ShellMetrics.pillTopMargin

        // Deterministic easing avoids spring retarget jitter while panel
        // loaders and asynchronous content settle their implicit sizes.
        width: panelSurface.implicitWidth
        Behavior on width {
            enabled: MotionConfig.animationsEnabled
            NumberAnimation {
                duration: MotionConfig.duration(Motion.duration.medium)
                easing.type: Motion.easing.standard
            }
        }

        // Height eases from 0 (collapsed) → content height (expanded).
        // Pure QML animation — the window stays mapped the whole time.
        height: ExpansionManager.isExpanded
                ? (panelLoader.item
                   ? panelLoader.item.implicitHeight + ShellMetrics.expandedPadding * 2
                   : 0)
                : 0
        Behavior on height {
            enabled: MotionConfig.animationsEnabled
            NumberAnimation {
                duration: MotionConfig.duration(Motion.duration.slow)
                easing.type: Motion.easing.standard
            }
        }

        // Fade panel content in/out in sync with the height spring.
        opacity: ExpansionManager.isExpanded ? 1.0 : 0.0
        Behavior on opacity {
            enabled: MotionConfig.animationsEnabled
            NumberAnimation {
                duration: MotionConfig.duration(Motion.duration.fast)
                easing.type: Motion.easing.standard
            }
        }

        // Skip rendering while fully collapsed (height springs to 0).
        visible: height > 0

        radius: Math.max(Radius.panel.background + 4, SettingsStore.panelCornerRadius)
        color: Colors.surface
        border.width: Elevation.panel.borderWidth
        border.color: Colors.borderStrong
        clip: true

        // Crisp layered edges: depth comes from opaque material tiers, never
        // blur or wallpaper show-through.
        Rectangle {
            anchors { fill: parent; margins: 1 }
            radius: Math.max(0, parent.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: Colors.fg
            opacity: 0.055
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
            source: ExpansionManager.isExpanded
                    ? (ExpansionRegistry.componentFor(ExpansionManager.activePanelId) || "")
                    : ""
            opacity: ExpansionManager.isExpanded ? 1.0 : 0.0
            scale: ExpansionManager.isExpanded ? 1.0 : 0.985
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
