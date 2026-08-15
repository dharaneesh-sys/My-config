import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: grid

    // ═══════════════════════════════════════════════════════════════
    //  QuickSettingsGrid
    //
    //  Adaptive grid of QuickToggle tiles.
    //  Calculates column count from available width.
    //  Accepts a model and renders QuickToggle for each entry.
    //
    //  Model items must provide:
    //    modelData.iconName, modelData.title, modelData.subtitle,
    //    modelData.active
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property var tiles: []   // [{iconName, title, subtitle, active, onClicked}]
    signal tileClicked(int index)

    // ── Layout ─────────────────────────────────────────────────────
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth

    // ── Grid metrics ───────────────────────────────────────────────
    readonly property real _tileSize: Spacing.quickTile.size
    readonly property real _tileGap: Spacing.quickTile.gap
    readonly property int _columns: Math.max(1, Math.floor(
        (width + _tileGap) / (_tileSize + _tileGap)
    ))
    readonly property int _rows: Math.ceil(tiles.length / _columns)

    implicitHeight: _rows > 0
                    ? _rows * _tileSize + (_rows - 1) * _tileGap
                    : 0

    // ── Grid ───────────────────────────────────────────────────────
    Repeater {
        model: grid.tiles

        QuickToggle {
            id: tile
            required property var modelData
            required property int index

            x: (index % grid._columns) * (grid._tileSize + grid._tileGap)
            y: Math.floor(index / grid._columns) * (grid._tileSize + grid._tileGap)

            iconName: modelData.iconName || ""
            title: modelData.title || ""
            subtitle: modelData.subtitle || ""
            active: modelData.active || false

            onClicked: grid.tileClicked(index)
        }
    }
}
