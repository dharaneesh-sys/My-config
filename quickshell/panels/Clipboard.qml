import QtQuick

import qs.tokens
import qs.metrics
import qs.state
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: clipboardPanel

    // ═══════════════════════════════════════════════════════════════
    //  Clipboard — PURE VIEW
    //
    //  Clipboard history panel, triggered by Super+V (default).
    //  Reads ClipboardState through ClipboardViewModel; actions
    //  (copy / delete / refresh) flow through the ViewModel.
    //
    //  Keyboard nav: Up/Down move the highlight (currentIndex),
    //  Enter copies the highlighted entry and dismisses the panel,
    //  Delete removes it. Clicking a row copies + dismisses.
    // ═══════════════════════════════════════════════════════════════

    ClipboardViewModel { id: vm }

    // ── Keyboard nav state ─────────────────────────────────────────
    // -1 = nothing selected (Enter then defaults to the first result).
    property int currentIndex: -1

    width: parent ? parent.width : ShellMetrics.clipboardWidth

    // Max-height clamp: long lists scroll inside the panel instead of
    // stretching the surface past maxPanelHeight.
    readonly property real maxPanelHeight: 520
    implicitHeight: Math.min(contentColumn.height, maxPanelHeight)

    // Highlight follows the result list when the query changes.
    Connections {
        target: vm
        function onQueryChanged() { clipboardPanel.currentIndex = -1 }
    }

    // The panel is re-created on every open (PanelSurface swaps the
    // loader source to "" on collapse), so onCompleted runs per open.
    // Defer refresh( ) so the panel renders immediately with any
    // cached ClipboardState entries, then refreshes in background.
    Component.onCompleted: {
        vm.setQuery("")
        searchBar.focusInput()
        _deferRefresh.start()
    }
    Timer {
        id: _deferRefresh
        interval: 0
        onTriggered: vm.refresh()
    }

    function moveSelection(offset) {
        var count = vm.resultsModel.count
        if (count === 0) return
        // From -1 (nothing) the first Down selects row 0; Up stays put.
        clipboardPanel.currentIndex = Math.max(-1, Math.min(clipboardPanel.currentIndex + offset, count - 1))
        _ensureSelectedVisible(clipboardPanel.currentIndex)
    }

    // Scroll the results list so row `index` is fully visible.
    // ListView recycles delegates, so only visible rows are instantiated.
    function _ensureSelectedVisible(index) {
        if (index < 0 || index >= vm.resultsModel.count) return
        resultsList.positionViewAtIndex(index, ListView.Contain)
    }

    // ── Copy + dismiss ─────────────────────────────────────────────
    function copyCurrent() {
        var idx = clipboardPanel.currentIndex >= 0 ? clipboardPanel.currentIndex : 0
        if (vm.resultsModel.count > 0) {
            vm.copy(vm.resultsModel.get(idx).id)
            ExpansionManager.requestCollapse()
        }
    }

    // ── Delete current (or last) ───────────────────────────────────
    function deleteCurrent() {
        if (vm.resultsModel.count === 0) return
        var idx = clipboardPanel.currentIndex >= 0 ? clipboardPanel.currentIndex : vm.resultsModel.count - 1
        vm.remove(vm.resultsModel.get(idx).id)
        // Keep the highlight sane after the optimistic row removal.
        clipboardPanel.currentIndex = Math.min(clipboardPanel.currentIndex, vm.resultsModel.count - 2)
    }

    // ── Sizing ─────────────────────────────────────────────────────
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
            placeholder: "Search clipboard…"
            query: vm.query

            onQueryChanged: vm.setQuery(searchBar.query)
            onAccepted: clipboardPanel.copyCurrent()
            onNavigateUp: clipboardPanel.moveSelection(-1)
            onNavigateDown: clipboardPanel.moveSelection(1)
            onNavigateDelete: clipboardPanel.deleteCurrent()
        }

        // ── Loading hint ─────────────────────────────────────────
        ShellText {
            visible: vm.loading && vm.resultsModel.count === 0
            text: "Loading clipboard…"
            role: ShellText.Role.Caption
            textColor: Colors.fgMuted
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Results ──────────────────────────────────────────────
        ListView {
            id: resultsList
            visible: vm.resultsModel.count > 0
            width: parent.width
            height: clipboardPanel.resultsHeight
            spacing: Spacing.xs
            clip: true
            interactive: clipboardPanel.rowHeight * vm.resultsModel.count > clipboardPanel.resultsHeight
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: 160
            model: vm.resultsModel

            delegate: ClipboardRow {
                width: resultsList.width
                entryId: model.id
                preview: model.preview
                isImage: model.isImage
                imageFormat: model.imageFormat
                imageWidth: model.imageWidth
                imageHeight: model.imageHeight
                imageUrl: vm.imagePaths[model.id] || ""
                highlighted: index === clipboardPanel.currentIndex

                onClicked: {
                    // Click acts on THIS row (like the launcher), not the
                    // keyboard highlight — then copies + dismisses.
                    vm.copy(model.id)
                    ExpansionManager.requestCollapse()
                }
                onDeleteClicked: vm.remove(model.id)
                onImageVisible: if (model.isImage) vm.requestImagePreview(model.id)
            }
        }

        // ── Empty state ──────────────────────────────────────────
        ShellText {
            visible: vm.showEmptyState
            text: "No matching clipboard entries"
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Item { width: parent.width; height: Spacing.xs }
    }

    // ── Thumbnail recovery ────────────────────────────────────────
    // After a refresh/delete, ClipboardState clears imagePaths. Visible
    // rows whose thumbnails vanished re-request via the row's
    // imageVisible signal only when they re-render — this guarantees
    // instantiated (visible) rows recover their previews immediately.
    Connections {
        target: vm
        function onImagePathsChanged() {
            for (var i = 0; i < resultsList.count; i++) {
                var item = resultsList.itemAtIndex(i)
                if (item && item.isImage && String(item.imageUrl) === "" && item.entryId !== "")
                    vm.requestImagePreview(item.entryId)
            }
        }
    }
}