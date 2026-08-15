import QtQuick

import qs.tokens

Text {
    id: shellIcon

    // ═══════════════════════════════════════════════════════════════
    //  ShellIcon
    //
    //  Icon rendered via Material Symbols Rounded font.
    //  Zero logic — pure presentation.
    // ═══════════════════════════════════════════════════════════════

    // ── Required: icon glyph name ──────────────────────────────────
    // e.g. "search", "wifi", "bluetooth", "play_arrow"
    property string name: ""

    // ── Overridable properties ─────────────────────────────────────
    property real iconSize: Spacing.icon.small
    property color iconColor: Colors.fg

    // ── Text config ────────────────────────────────────────────────
    text: name
    color: iconColor
    font.family: Typography.families.icons
    font.pixelSize: iconSize
    font.weight: Font.Normal

    // Material Symbols: use the "variable" font to enable
    // weight/grade/optical-size axes. The default weight 400
    // renders the "outlined" variant. Use 700 for "filled".

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment:   Text.AlignVCenter
}
