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
    // Fixed 2-column layout: tiles stretch to fill the row width so
    // they don't leave dead space in the panel (the old auto-column
    // count used a fixed tile size that never filled the width).
    readonly property real _tileGap: Spacing.quickTile.gap
    readonly property int _columns: 2
    readonly property real _tileSize: Spacing.quickTile.size
    readonly property real _tileWidth: Math.max(1, (width - _tileGap * (_columns - 1)) / _columns)
    readonly property int _rows: Math.ceil(model.count / _columns)

    implicitHeight: _rows > 0
                    ? _rows * _tileSize + (_rows - 1) * _tileGap
                    : 0

    // ── Grid ───────────────────────────────────────────────────────
    Repeater {
        model: grid.model

        Item {
            id: tileDelegate
            required property int index
            required property string iconName
            required property string title
            required property string subtitle
            required property bool active

            x: (index % grid._columns) * (grid._tileWidth + grid._tileGap)
            readonly property real layoutY: Math.floor(index / grid._columns) * (grid._tileSize + grid._tileGap)
            property real entranceOffset: 8
            property real entranceOpacity: 0
            y: layoutY + entranceOffset
            width: grid._tileWidth
            height: grid._tileSize
            opacity: grid.visible ? entranceOpacity : 0.0

            // A small stagger makes the panel arrive as one composed piece,
            // while retaining a stable layout and no compositor geometry work.
            Component.onCompleted: entrance.restart()
            SequentialAnimation {
                id: entrance
                running: false
                PauseAnimation { duration: tileDelegate.index * Motion.panel.staggerDelay }
                ParallelAnimation {
                    NumberAnimation { target: tileDelegate; property: "entranceOpacity"; to: 1; duration: Motion.duration.medium; easing.type: Motion.easing.decelerate }
                    NumberAnimation { target: tileDelegate; property: "entranceOffset"; to: 0; duration: Motion.duration.medium; easing.type: Motion.easing.decelerate }
                }
            }

            QuickToggle {
                anchors.fill: parent
                iconName: parent.iconName
                title: parent.title
                subtitle: parent.subtitle
                active: parent.active

                onClicked: grid.tileClicked(parent.index)
            }
        }
    }
}
