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
    implicitHeight: Math.min(contentColumn.height, maxPanelHeight)

    // Highlight follows the result list when the query changes.
    Connections {
        target: vm
        function onQueryChanged() { launcher.currentIndex = -1 }
    }

    // Give the search input focus as soon as the launcher opens, so
    // typing and arrow navigation work without a click first. The panel
    // is re-created on every open (PanelSurface swaps the loader source
    // to "" on collapse), so onCompleted runs per open — reset the query
    // here so each launch starts with a clean field. The panel fades in
    // from opacity 0, so the brief pre-clear text is never visible.
    Component.onCompleted: {
        vm.setQuery("")
        searchBar.focusInput()
    }

    function moveSelection(offset) {
        var count = vm.resultsModel.count
        if (count === 0) return
        // From -1 (nothing) the first Down selects row 0; Up stays put.
        launcher.currentIndex = Math.max(-1, Math.min(launcher.currentIndex + offset, count - 1))
        _ensureSelectedVisible(launcher.currentIndex)
    }

    // Scroll the results list so row `index` is fully visible.
    // ListView recycles delegates, so only visible rows are instantiated
    // — this is what keeps the launcher from stuttering on open (the old
    // Column+Repeater built all 120 rows synchronously per open).
    function _ensureSelectedVisible(index) {
        if (index < 0 || index >= vm.resultsModel.count) return
        resultsList.positionViewAtIndex(index, ListView.Contain)
    }

    // ── Sizing ─────────────────────────────────────────────────────
    // Row list height is capped so the panel never exceeds
    // maxPanelHeight; the ListView scrolls internally when full.
    readonly property real rowHeight: Spacing.listItem.height + Spacing.xs
    readonly property real resultsHeight: vm.resultsModel.count > 0
        ? Math.min(vm.resultsModel.count * rowHeight, maxPanelHeight - chromeHeight)
        : 0
    readonly property real chromeHeight: searchBar.implicitHeight + Spacing.panel.gap * 2 + Spacing.xs

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        // ── Search bar ───────────────────────────────────────────
        // Pinned above the results — never scrolls away.
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

        // ── Results ──────────────────────────────────────────────
        // Recycled-delegate ListView: only ~9 visible rows exist at
        // any time (vs 120 with the old Repeater), so the panel opens
        // instantly and stays smooth while scrolling.
        ListView {
            id: resultsList
            visible: vm.resultsModel.count > 0
            width: parent.width
            height: launcher.resultsHeight
            spacing: Spacing.xs
            clip: true
            interactive: launcher.rowHeight * vm.resultsModel.count > launcher.resultsHeight
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: 160
            model: vm.resultsModel

            delegate: AppRow {
                width: resultsList.width
                appName: model.name || ""
                description: model.description || ""
                iconName: model.icon || ""
                launching: vm.isLaunching(model.exec)
                highlighted: index === launcher.currentIndex

                onClicked: vm.launch(model.exec, model.terminal)
            }
        }

        // ── Empty state ──────────────────────────────────────────
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
