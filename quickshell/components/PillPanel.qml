import QtQuick

import qs.tokens
import qs.metrics
import qs.state
import qs.settings
import qs.motion

Item {
    id: pillPanel

    // ═══════════════════════════════════════════════════════════════
    //  PillPanel — merged pill + expansion surface (Wave 1)
    //
    //  ONE surface morphs IN-PLACE from the pill into the expanded
    //  panel (the user-facing fix: "expand the pill, not a dropdown").
    //
    //  • Collapsed: a fully-rounded pill, clock only.
    //  • Expanded:  the same surface grows down/wide, radius morphs
    //               9999 → panelCornerRadius, panel content loads
    //               below the pill area (which keeps the clock).
    //  • Width/height/radius animate with the runtime spring config
    //    (qs.motion → MotionConfig) so SettingsStore animation
    //    settings actually drive the motion.
    //  • NO scale / transformOrigin anywhere — pure geometry morph.
    //
    //  Window sizing contract: `width`/`height` are DISCRETE targets
    //  (no Behavior), so the PanelWindow resizes exactly twice per
    //  expand/collapse cycle instead of every animation frame.
    //  The animated geometry lives on `surface` and drives the
    //  window's opaque mask (Region { item: pillPanel.surface }).
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    /** Opaque/clickable region — Shell binds its mask to this. */
    readonly property alias surface: surface

    /** Panel loader (used by tests). */
    readonly property alias panelLoader: panelLoader

    /** Input-catch MouseArea (used by tests). */
    readonly property alias inputCatch: inputCatch

    // ── Visibility ─────────────────────────────────────────────────
    // Hidden only when the clock is disabled AND nothing is expanded.
    visible: SettingsStore.clockShowInPill || ExpansionManager.isExpanded

    // ── Discrete target size (window sizing — changes twice/cycle) ─
    readonly property real _panelPreferredWidth: ExpansionRegistry.widthFor(ExpansionManager.activePanelId) || ShellMetrics.expandedWidth
    readonly property real _panelPreferredHeight: ExpansionRegistry.heightFor(ExpansionManager.activePanelId) || 0

    width: ExpansionManager.isExpanded
           ? Math.max(ShellMetrics.pillWidth, _panelPreferredWidth)
           : ShellMetrics.pillWidth

    height: ExpansionManager.isExpanded
            ? ShellMetrics.pillHeight + ShellMetrics.pillBottomMargin + _panelPreferredHeight + ShellMetrics.expandedPadding * 2
            : ShellMetrics.pillHeight

    // ── Input catch ────────────────────────────────────────────────
    // Declared FIRST so it sits BEHIND the surface and content.
    // Clicking empty panel background (not an interactive element)
    // collapses the panel. Content's own MouseAreas win on top.
    MouseArea {
        id: inputCatch
        anchors.fill: parent
        visible: ExpansionManager.isExpanded
        onClicked: ExpansionManager.requestCollapse()
    }

    // ── The morphing surface (pill ↔ panel) ────────────────────────
    Rectangle {
        id: surface
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        // Animated geometry — Behaviors below smooth the morph.
        width: ExpansionManager.isExpanded
               ? Math.max(ShellMetrics.pillWidth, pillPanel._panelPreferredWidth)
               : ShellMetrics.pillWidth

        height: ExpansionManager.isExpanded
                ? ShellMetrics.pillHeight + ShellMetrics.pillBottomMargin + pillPanel._panelPreferredHeight + ShellMetrics.expandedPadding * 2
                : ShellMetrics.pillHeight

        // Corner radius morphs from fully-rounded pill → panel radius.
        property real _cornerRadius: ExpansionManager.isExpanded
                                     ? SettingsStore.panelCornerRadius
                                     : ShellMetrics.pillCornerRadius

        // Background morphs pill surface → panel surface.
        color: ExpansionManager.isExpanded ? Colors.surface : Colors.pillBg
        border.width: ExpansionManager.isExpanded ? Elevation.panel.borderWidth : Elevation.pill.borderWidth
        border.color: ExpansionManager.isExpanded ? Colors.border : Colors.pillBorder
        opacity: ShellMetrics.shellOpacity
        clip: true

        visible: ExpansionManager.isExpanded || height > 0

        // ── Motion (runtime spring from qs.motion) ───────────────
        Behavior on width {
            enabled: MotionConfig.animationsEnabled
            SpringAnimation {
                spring:  MotionConfig.spring.stiffness
                damping: MotionConfig.spring.damping
                mass:    MotionConfig.spring.mass
                epsilon: MotionConfig.spring.epsilon
            }
        }

        Behavior on height {
            enabled: MotionConfig.animationsEnabled
            SpringAnimation {
                spring:  MotionConfig.spring.stiffness
                damping: MotionConfig.spring.damping
                mass:    MotionConfig.spring.mass
                epsilon: MotionConfig.spring.epsilon
            }
        }

        Behavior on _cornerRadius {
            enabled: MotionConfig.animationsEnabled
            SpringAnimation {
                spring:  MotionConfig.spring.stiffness
                damping: MotionConfig.spring.damping
                mass:    MotionConfig.spring.mass
                epsilon: MotionConfig.spring.epsilon
            }
        }

        Behavior on color {
            enabled: MotionConfig.animationsEnabled
            ColorAnimation {
                duration: MotionConfig.duration(Motion.duration.fast)
                easing.type: Motion.easing.standard
            }
        }

        // ── Pill area (top region, clock) ─────────────────────────
        // Stays pillHeight tall at the top of the surface even when
        // expanded — the clock rides the top of the grown panel.
        Item {
            id: pillArea
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: ShellMetrics.pillHeight

            // Hover / press highlights (pill state only)
            Rectangle {
                anchors.fill: parent
                radius: surface._cornerRadius
                color: Colors.hoverOverlay
                visible: pillToggle.containsMouse && !pillToggle.pressed && !ExpansionManager.isExpanded
            }

            Rectangle {
                anchors.fill: parent
                radius: surface._cornerRadius
                color: Colors.pressedOverlay
                visible: pillToggle.pressed && !ExpansionManager.isExpanded
            }

            // Clock — the ONLY pill content (reads ClockState)
            Text {
                id: clockLabel
                anchors.centerIn: parent
                text: ClockState.showSeconds ? ClockState.timeSeconds : ClockState.time
                color: Colors.pillFg
                font.family:    Typography.clock.family
                font.pixelSize: Typography.clock.size
                font.weight:    Typography.clock.weight
            }

            // Toggle: expand when collapsed, collapse when expanded.
            MouseArea {
                id: pillToggle
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (ExpansionManager.isExpanded)
                        ExpansionManager.requestCollapse()
                    else
                        ExpansionManager.requestExpand("control-center")
                }
            }
        }

        // ── Panel content loader ──────────────────────────────────
        // Resolves the active panel via ExpansionRegistry. Sits below
        // the pill area with the panel's padding applied.
        Loader {
            id: panelLoader

            anchors {
                top: pillArea.bottom
                topMargin: ShellMetrics.pillBottomMargin
                left: parent.left
                leftMargin: ShellMetrics.expandedPadding
                right: parent.right
                rightMargin: ShellMetrics.expandedPadding
                bottom: parent.bottom
                bottomMargin: ShellMetrics.expandedPadding
            }

            source: ExpansionManager.isExpanded
                    ? (ExpansionRegistry.componentFor(ExpansionManager.activePanelId) || "")
                    : ""

            opacity: ExpansionManager.isExpanded ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: MotionConfig.duration(Motion.panel.contentFadeIn)
                    easing.type: Motion.easing.standard
                }
            }
        }

        // ── Placeholder (no panel loaded) ─────────────────────────
        Text {
            anchors.centerIn: parent
            visible: !panelLoader.item && ExpansionManager.activePanelId !== ""
            text: "▸ " + ExpansionManager.activePanelId
            color: Colors.fgMuted
            font.family:    Typography.body.family
            font.pixelSize: Typography.body.size
            font.weight:    Typography.body.weight
            opacity: panelLoader.opacity
        }
    }
}
