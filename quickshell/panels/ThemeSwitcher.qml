import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.viewmodels

Item {
    id: themeSwitcher

    // ═══════════════════════════════════════════════════════════════
    //  ThemeSwitcher — PURE VIEW
    //
    //  Theme selection grid. Triggered by Super+T.
    //  Only binds properties and emits user actions through ViewModel.
    //
    //  Layout: fixed 3-column grid — each card shows 3 color dots
    //  (background / accent / surface).
    // ═══════════════════════════════════════════════════════════════

    ThemeSwitcherViewModel { id: vm }

    property int currentIndex: _selectedIndex()
    focus: true

    function _selectedIndex() {
        for (var i = 0; i < vm.themes.length; i++)
            if (vm.themes[i].selected) return i
        return vm.themes.length > 0 ? 0 : -1
    }

    function moveSelection(offset) {
        var count = vm.themes.length
        if (count === 0) return
        currentIndex = Math.max(0, Math.min(count - 1, currentIndex + offset))
        themeGrid.positionViewAtIndex(currentIndex, GridView.Contain)
    }

    function activateSelection() {
        if (currentIndex >= 0 && currentIndex < vm.themes.length)
            vm.selectTheme(vm.themes[currentIndex].key)
    }

    Keys.onLeftPressed: moveSelection(-1)
    Keys.onRightPressed: moveSelection(1)
    Keys.onUpPressed: moveSelection(-3)
    Keys.onDownPressed: moveSelection(3)
    Keys.onReturnPressed: activateSelection()
    Keys.onEnterPressed: activateSelection()
    Keys.onEscapePressed: ExpansionManager.requestCollapse()
    Component.onCompleted: forceActiveFocus()

    width: parent ? parent.width : ShellMetrics.themeSwitcherWidth

    // Max-height clamp: with 13 themes the grid would stretch the surface
    // past the panel limit. Height is clamped and the grid scrolls inside
    // the panel instead (GridView is self-scrolling; no extra Flickable).
    readonly property real maxPanelHeight: 270
    implicitHeight: Math.min(contentColumn.height, maxPanelHeight)

    // ── Grid metrics ──────────────────────────────────────────────
    // Compact three-column previews mirror the dashboard style: each card
    // is a palette sample first, with its label kept deliberately quiet.
    readonly property real _gridWidth: width - Spacing.panel.padding * 2

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.xs

        ShellText {
            id: panelTitle
            x: Spacing.panel.padding
            text: "Theme"
            role: ShellText.Role.CaptionMedium
            textColor: Colors.fg
        }

        // ── Theme grid ───────────────────────────────────────────
        GridView {
            id: themeGrid
            width: parent.width
            x: 0
            // Fit the clamp: full content when it fits, bounded to the
            // remaining panel height when it doesn't (then scrolls).
            height: Math.min(contentHeight, themeSwitcher.maxPanelHeight
                             - panelTitle.implicitHeight
                             - Spacing.panel.gap * 2)
            cellWidth: Math.floor(width / 3)
            cellHeight: 64
            model: vm.themes
            clip: true
            // Scrolls only when content exceeds the clamped height.
            interactive: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: ThemeCard {
                required property var modelData
                required property int index
                width: themeGrid.cellWidth - Spacing.xs
                height: themeGrid.cellHeight - Spacing.xs
                name: modelData.label
                primaryColor: modelData.primaryColor
                bgColor: modelData.bgColor
                surfaceColor: modelData.surfaceColor
                onSurfaceColor: modelData.onSurfaceColor
                selected: modelData.selected
                highlighted: index === themeSwitcher.currentIndex

                onClicked: {
                    themeSwitcher.currentIndex = index
                    vm.selectTheme(modelData.key)
                }
            }
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
