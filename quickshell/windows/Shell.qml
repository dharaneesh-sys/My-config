import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.state
import qs.metrics
import qs.tokens
import qs.components

PanelWindow {
    id: shell

    // ═══════════════════════════════════════════════════════════════
    //  Shell — the primary PanelWindow
    //
    //  Full-width transparent surface anchored to the top edge.
    //  Content (PillPanel: pill + in-place expansion) is centered.
    //  Transparent areas pass through clicks to windows below.
    //
    //  Wave 1 changes:
    //   • Single PillPanel replaces the TopPill + ExpandedSurface
    //     + OverlayDim trio. The panel expands IN-PLACE by morphing
    //     the pill's own surface (user requirement).
    //   • implicitHeight is bound to PillPanel's DISCRETE target
    //     height (no Behavior), so the window resizes exactly twice
    //     per expand/collapse cycle — no per-frame surface resize
    //     (root cause #1).
    //   • The mask tracks PillPanel.surface (the animated geometry),
    //     so the opaque region follows the morph while the window
    //     geometry stays discrete.
    //   • No OverlayDim sibling at z:30 — the input-catch MouseArea
    //     lives inside PillPanel BEHIND the content, so panel clicks
    //     are no longer swallowed (root cause #6).
    // ═══════════════════════════════════════════════════════════════

    // ── Screen anchoring ───────────────────────────────────────────
    anchors {
        top: true
        left: true
        right: true
    }

    // ── Exclusion: do NOT reserve screen space ────────────────────
    // The pill floats over content. No strut required.
    exclusionMode: ExclusionMode.Ignore

    // ── Layer: above tiled windows ────────────────────────────────
    aboveWindows: true

    // ── Focus: only when a panel is interactive ───────────────────
    focusable: ExpansionManager.isInteractive

    // ── Background: transparent (only content region is opaque) ───
    color: "transparent"

    // ── Window size: DISCRETE target, not animated content ────────
    // PillPanel.width/height have no Behavior — they jump to their
    // collapsed/expanded targets. Binding here means the layer
    // surface resizes exactly twice per expand/collapse cycle
    // (fixes the per-frame resize cascade).
    implicitWidth: pillPanel.width
    implicitHeight: (pillPanel.visible ? ShellMetrics.pillTopMargin : 0)
                    + pillPanel.height
                    + ShellMetrics.pillBottomMargin

    // ── Content: the single morphing pill/panel ───────────────────
    PillPanel {
        id: pillPanel
        anchors {
            top: parent.top
            topMargin: ShellMetrics.pillTopMargin
            horizontalCenter: parent.horizontalCenter
        }
    }

    // ── Mask: tell Hyprland which pixels are opaque ──────────────
    // Quickshell's Region supports `item` (singular). We track the
    // ANIMATED surface so the opaque region morphs with the panel,
    // while the window geometry itself stays discrete.
    mask: Region { item: pillPanel.surface }
}
