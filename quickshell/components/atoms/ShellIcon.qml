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
    property bool filled: false

    // ── Text config ────────────────────────────────────────────────
    text: name
    color: iconColor
    font.family: Typography.families.icons
    font.pixelSize: iconSize
    font.weight: filled ? Font.DemiBold : Font.Normal
    // Variable axes: FILL 1 = filled, 0 = outlined; GRAD 0 idle, wght 500 active
    font.variableAxes: filled ? {"FILL": 1, "GRAD": 0, "wght": 500} : {"FILL": 0, "GRAD": 0, "wght": 400}

    // Material Symbols: use the "variable" font to enable
    // weight/grade/optical-size axes. The default weight 400
    // renders the "outlined" variant. Use 700 for "filled".

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment:   Text.AlignVCenter
}
