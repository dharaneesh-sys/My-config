import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: launcher

    // ═══════════════════════════════════════════════════════════════
    //  Launcher — PURE VIEW
    //
    //  Application launcher panel. Triggered by Super+Space.
    //  Only binds properties and emits user actions through ViewModel.
    //
    //  Keyboard nav: Up/Down move a highlight through the result list
    //  (currentIndex), Enter launches the highlighted entry.
    // ═══════════════════════════════════════════════════════════════

    LauncherViewModel { id: vm }

    // ── Keyboard nav state ─────────────────────────────────────────
    // -1 = nothing selected (Enter then defaults to the first result).
    property int currentIndex: -1

    width: parent ? parent.width : ShellMetrics.launcherWidth

    // Max-height clamp: long result lists scroll inside the panel
    // instead of stretching the surface past maxPanelHeight.
    readonly property real maxPanelHeight: 520
    implicitHeight: Math.min(scrollArea.contentHeight, maxPanelHeight)

    // Highlight follows the result list when the query changes.
    Connections {
        target: vm
        function onQueryChanged() { launcher.currentIndex = -1 }
    }

    // Give the search input focus as soon as the launcher opens, so
    // typing and arrow navigation work without a click first.
    Component.onCompleted: searchBar.focusInput()

    function moveSelection(offset) {
        var count = vm.resultsModel.count
        if (count === 0) return
        // From -1 (nothing) the first Down selects row 0; Up stays put.
        launcher.currentIndex = Math.max(-1, Math.min(launcher.currentIndex + offset, count - 1))
        _ensureSelectedVisible(launcher.currentIndex)
    }

    // Scroll the Flickable so row `index` is fully visible. Row heights
    // are uniform (searchBar + gap + index × (row + rowSpacing)).
    function _ensureSelectedVisible(index) {
        if (index < 0) return
        var rowH = Spacing.listItem.height + Spacing.xs
        var rowTop = searchBar.implicitHeight + Spacing.panel.gap + index * rowH
        var rowBottom = rowTop + Spacing.listItem.height
        if (rowTop < scrollArea.contentY)
            scrollArea.contentY = rowTop
        else if (rowBottom > scrollArea.contentY + scrollArea.height)
            scrollArea.contentY = rowBottom - scrollArea.height
    }

    Flickable {
        id: scrollArea
        anchors.fill: parent
        contentHeight: contentColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width
            spacing: Spacing.panel.gap

            // ── Search bar ───────────────────────────────────────
            SearchBar {
                id: searchBar
                width: parent.width
                placeholder: "Search applications…"
                query: vm.query

                onQueryChanged: vm.setQuery(searchBar.query)
                onAccepted: {
                    var idx = launcher.currentIndex >= 0 ? launcher.currentIndex : 0
                    if (vm.resultsModel.count > 0) {
                        var item = vm.resultsModel.get(idx)
                        vm.launch(item.exec, item.terminal)
                    }
                }
                onNavigateUp: launcher.moveSelection(-1)
                onNavigateDown: launcher.moveSelection(1)
            }

            // ── Results ──────────────────────────────────────────
            Column {
                width: parent.width
                spacing: Spacing.xs
                visible: vm.resultsModel.count > 0

                Repeater {
                    model: vm.resultsModel

                    AppRow {
                        width: parent.width
                        appName: model.name || ""
                        description: model.description || ""
                        iconName: model.icon || ""
                        launching: vm.isLaunching(model.exec)
                        highlighted: index === launcher.currentIndex

                        onClicked: vm.launch(model.exec, model.terminal)
                    }
                }

                // "More results" indicator
                ShellText {
                    visible: vm.hasMore
                    text: vm.moreResultsText
                    role: ShellText.Role.Caption
                    textColor: Colors.fgMuted
                    width: parent.width
                }
            }

            // ── Empty state ──────────────────────────────────────
            ShellText {
                visible: vm.showEmptyState
                text: "No matching applications"
                role: ShellText.Role.Body
                textColor: Colors.fgMuted
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: parent.width; height: Spacing.xs }
        }
    }
}
