pragma Singleton
import QtQuick

QtObject {
    id: em

    // ═══════════════════════════════════════════════════════════════
    //  ExpansionManager
    //
    //  Lifecycle state machine for panel expansion.
    //  Works exclusively with string IDs — never enum values.
    //  Panel resolution is delegated to ExpansionRegistry.
    //
    //  Lifecycle states:
    //    Collapsed  → No panel visible. Pill only.
    //    Opening    → Panel content loading, height animating open.
    //    Expanded   → Panel fully visible, interactive.
    //    Switching  → Old panel fading, new panel loading, height may change.
    //    Closing    → Height animating shut, content fading out.
    //
    //  Valid transitions:
    //    Collapsed  → Opening      (requestExpand on empty)
    //    Expanded   → Closing      (requestCollapse)
    //    Expanded   → Switching    (requestExpand different panel)
    //    Expanded   → Opening      (requestExpand same panel = toggle off then on)
    //    Opening    → Expanded     (onOpenCompleted from ExpandedSurface)
    //    Switching  → Expanded     (onSwitchCompleted from ExpandedSurface)
    //    Closing    → Collapsed    (onCloseCompleted from ExpandedSurface)
    //
    //  All other transitions are no-ops.
    // ═══════════════════════════════════════════════════════════════

    // ─── Lifecycle enum ───────────────────────────────────────────
    enum Lifecycle {
        Collapsed,
        Opening,
        Expanded,
        Switching,
        Closing
    }

    // ─── Core state ───────────────────────────────────────────────
    property string activePanelId: ""
    property int lifecycle: ExpansionManager.Lifecycle.Collapsed

    // ─── Derived state ────────────────────────────────────────────
    readonly property bool isExpanded: lifecycle !== ExpansionManager.Lifecycle.Collapsed
    readonly property bool isTransitioning: lifecycle === ExpansionManager.Lifecycle.Opening
                                        || lifecycle === ExpansionManager.Lifecycle.Switching
                                        || lifecycle === ExpansionManager.Lifecycle.Closing
    readonly property bool isInteractive: lifecycle === ExpansionManager.Lifecycle.Expanded

    // ─── Previous panel (for Switching transitions) ──────────────
    readonly property string previousPanelId: _previousPanelId
    property string _previousPanelId: ""

    // ─── Transition mode ──────────────────────────────────────────
    // Instant: lifecycle advances automatically (for skeleton/testing).
    // Animated: lifecycle waits for completion callbacks from ExpandedSurface.
    enum TransitionMode {
        Instant,
        Animated
    }

    property int transitionMode: ExpansionManager.TransitionMode.Instant

    // ─── Public API ───────────────────────────────────────────────

    /**
     * Request a panel to expand.
     *
     * - If collapsed: opens the panel.
     * - If expanded with same panel: collapses (toggle off).
     * - If expanded with different panel: swaps (direct switch).
     * - If transitioning: rejected (no-op).
     */
    function requestExpand(panelId) {
        if (!ExpansionRegistry.isRegistered(panelId)) {
            console.warn("ExpansionManager: unknown panel \"" + panelId + "\"")
            return
        }

        switch (lifecycle) {
        case ExpansionManager.Lifecycle.Collapsed:
            activePanelId = panelId
            lifecycle = ExpansionManager.Lifecycle.Opening
            _advanceIfInstant()
            break

        case ExpansionManager.Lifecycle.Expanded:
            if (activePanelId === panelId) {
                // Toggle off
                requestCollapse()
            } else {
                // Direct swap
                _previousPanelId = activePanelId
                activePanelId = panelId
                lifecycle = ExpansionManager.Lifecycle.Switching
                _advanceIfInstant()
            }
            break

        case ExpansionManager.Lifecycle.Opening:
        case ExpansionManager.Lifecycle.Switching:
        case ExpansionManager.Lifecycle.Closing:
            // Rejected during transition
            console.warn("ExpansionManager: requestExpand(\"" + panelId + "\") rejected — lifecycle is " + _lifecycleName())
            break
        }
    }

    /**
     * Request the active panel to collapse.
     *
     * Only effective when Expanded. No-op otherwise.
     */
    function requestCollapse() {
        switch (lifecycle) {
        case ExpansionManager.Lifecycle.Expanded:
            lifecycle = ExpansionManager.Lifecycle.Closing
            _advanceIfInstant()
            break

        case ExpansionManager.Lifecycle.Opening:
            // Allow canceling an open animation
            lifecycle = ExpansionManager.Lifecycle.Closing
            _advanceIfInstant()
            break

        default:
            // No-op in Collapsed, Switching, Closing
            break
        }
    }

    // ─── Completion callbacks (called by ExpandedSurface) ─────────

    /** Call when the open animation completes. */
    function onOpenCompleted() {
        if (lifecycle === ExpansionManager.Lifecycle.Opening) {
            lifecycle = ExpansionManager.Lifecycle.Expanded
            _previousPanelId = ""
        }
    }

    /** Call when the close animation completes. */
    function onCloseCompleted() {
        if (lifecycle === ExpansionManager.Lifecycle.Closing) {
            lifecycle = ExpansionManager.Lifecycle.Collapsed
            activePanelId = ""
            _previousPanelId = ""
        }
    }

    /** Call when the switch animation completes. */
    function onSwitchCompleted() {
        if (lifecycle === ExpansionManager.Lifecycle.Switching) {
            lifecycle = ExpansionManager.Lifecycle.Expanded
            _previousPanelId = ""
        }
    }

    // ─── Internal helpers ─────────────────────────────────────────

    /** In Instant mode, auto-advance lifecycle to terminal state. */
    function _advanceIfInstant() {
        if (transitionMode !== ExpansionManager.TransitionMode.Instant)
            return

        switch (lifecycle) {
        case ExpansionManager.Lifecycle.Opening:
            lifecycle = ExpansionManager.Lifecycle.Expanded
            _previousPanelId = ""
            break
        case ExpansionManager.Lifecycle.Switching:
            lifecycle = ExpansionManager.Lifecycle.Expanded
            _previousPanelId = ""
            break
        case ExpansionManager.Lifecycle.Closing:
            lifecycle = ExpansionManager.Lifecycle.Collapsed
            activePanelId = ""
            _previousPanelId = ""
            break
        default:
            break
        }
    }

    /** Human-readable lifecycle name for debug logging. */
    function _lifecycleName() {
        switch (lifecycle) {
        case ExpansionManager.Lifecycle.Collapsed:  return "Collapsed"
        case ExpansionManager.Lifecycle.Opening:    return "Opening"
        case ExpansionManager.Lifecycle.Expanded:   return "Expanded"
        case ExpansionManager.Lifecycle.Switching:  return "Switching"
        case ExpansionManager.Lifecycle.Closing:    return "Closing"
        default: return "Unknown"
        }
    }
}
