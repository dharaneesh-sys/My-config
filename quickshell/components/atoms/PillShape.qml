import QtQuick

import qs.tokens

Rectangle {
    id: pillShape

    // ═══════════════════════════════════════════════════════════════
    //  PillShape
    //
    //  Rounded rectangle background shape.
    //  Zero logic — pure presentation.
    //  Every property has a token-derived default.
    // ═══════════════════════════════════════════════════════════════

    // ── Overridable properties ─────────────────────────────────────
    radius:      Radius.pill.background
    color:       Colors.surface
    border.width: Elevation.card.borderWidth
    border.color: Colors.border

    // ── Clipping ──────────────────────────────────────────────────
    // Content inside is clipped to the rounded bounds.
    clip: true
}
