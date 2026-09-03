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
    //  Shell — the permanent pill bar
    //
    //  Full-width transparent surface anchored to the top edge.
    //  Content (PillPanel: pill visuals only) is centered.
    //  Transparent areas pass through clicks to windows below.
    //
    //  Wave 2 (two-window split):
    //   • This window is the PILL BAR ONLY — always the same height,
    //     never expanded. Expanded panels live in the separate
    //     PanelSurface window (windows/PanelSurface.qml).
    //   • exclusionMode: Normal reserves a constant strut, so tiling
    //     windows are pushed below the pill and NEVER overlap it — no
    //     more pill floating over tiled windows (issue A).
    //   • implicitHeight is CONSTANT (pill only) — expanding a panel
    //     does not resize this window at all, so the strut is stable
    //     and tiling windows are never pushed by the panel height
    //     (issue B).
    //   • The mask tracks PillPanel.surface so only the pill pixels
    //     are opaque/clickable; the rest of the strip passes through.
    // ═══════════════════════════════════════════════════════════════

    // ── Screen anchoring ───────────────────────────────────────────
    anchors {
        top: true
        left: true
        right: true
    }

    // ── Exclusion: RESERVE screen space ────────────────────────────
    // The pill bar owns a permanent strut. Tiling windows are laid out
    // below it, so they can never overlap the pill.
    exclusionMode: ExclusionMode.Normal
    // Do not rely on layer-shell's automatic zone calculation: it can
    // resolve to zero for a masked, transparent PanelWindow. Reserve the
    // full pill band explicitly so tiled windows start below the pill.
    exclusiveZone: ShellMetrics.pillReservedHeight

    // ── Focus: the pill is not interactive (no text input) ────────
    // Focus lives on PanelSurface while a panel is expanded.
    focusable: false

    // ── Background: transparent (only the pill region is opaque) ───
    color: "transparent"

    // ── Window size: CONSTANT, pill-only ───────────────────────────
    // Never depends on expansion state. The strut therefore never
    // changes height, even while a panel is open.
    implicitWidth: pillPanel.width
    // Leave a stable, small canvas for the pill notification morph. The
    // exclusive zone remains the pill band, so this never moves windows.
    implicitHeight: Math.max(ShellMetrics.pillReservedHeight,
                             ShellMetrics.pillTopMargin + 80)

    // ── Content: the pill ──────────────────────────────────────────
    PillPanel {
        id: pillPanel
        anchors {
            top: parent.top
            topMargin: ShellMetrics.notchEnabled ? 0 : ShellMetrics.pillTopMargin
            horizontalCenter: parent.horizontalCenter
        }
    }

    // ── Mask: tell Hyprland which pixels are opaque ──────────────
    // The exclusive zone remains constant while expanded, but invisible pill
    // pixels must not intercept clicks behind the floating panel.
    mask: Region {
        item: ExpansionManager.isExpanded ? null : pillPanel.maskItem
    }
}
