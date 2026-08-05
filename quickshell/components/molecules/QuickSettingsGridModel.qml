import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: grid

    // ═══════════════════════════════════════════════════════════════
    //  QuickSettingsGridModel
    //
    //  Adaptive grid of QuickToggle tiles that consumes a ListModel
    //  (NOT a JS array). Roles are accessed via model.roleName, so
    //  delegates are NOT destroyed/recreated when a single tile's
    //  properties change — the viewmodel updates rows in-place with
    //  ListModel.setProperty(), and only the changed delegate re-renders.
    //
    //  Created per docs/ARCHITECTURE.md "add-new-file" rule:
    //  QuickSettingsGrid (JS-array variant) stays frozen and unused.
    //
    //  Model rows must provide roles:
    //    iconName, title, subtitle, active
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property ListModel model: ListModel {}
    signal tileClicked(int index)

    // ── Layout ─────────────────────────────────────────────────────
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth

    // ── Grid metrics ───────────────────────────────────────────────
    readonly property real _tileSize: Spacing.quickTile.size
    readonly property real _tileGap: Spacing.quickTile.gap
    readonly property int _columns: Math.max(1, Math.floor(
        (width + _tileGap) / (_tileSize + _tileGap)
    ))
    readonly property int _rows: Math.ceil(model.count / _columns)

    implicitHeight: _rows > 0
                    ? _rows * _tileSize + (_rows - 1) * _tileGap
                    : 0

    // ── Grid ───────────────────────────────────────────────────────
    Repeater {
        model: grid.model

        QuickToggle {
            id: tile
            required property int index

            x: (index % grid._columns) * (grid._tileSize + grid._tileGap)
            y: Math.floor(index / grid._columns) * (grid._tileSize + grid._tileGap)

            iconName: model.iconName || ""
            title: model.title || ""
            subtitle: model.subtitle || ""
            active: model.active || false

            onClicked: grid.tileClicked(index)
        }
    }
}
