import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: wallpaperSelector

    // ═══════════════════════════════════════════════════════════════
    //  WallpaperSelector — PURE VIEW
    //
    //  Wallpaper selection grid. Triggered by Super+W.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    WallpaperSelectorViewModel { id: vm }

    property int currentIndex: _selectedIndex()
    focus: true

    function _selectedIndex() {
        for (var i = 0; i < vm.wallpapers.length; i++)
            if (vm.wallpapers[i].selected) return i
        return vm.wallpapers.length > 0 ? 0 : -1
    }

    function moveSelection(offset) {
        var count = vm.wallpapers.length
        if (count === 0) return
        currentIndex = Math.max(0, Math.min(count - 1, currentIndex + offset))
        var row = Math.floor(currentIndex / wallpaperGrid.columns)
        var rowTop = wallpaperGrid.y + row * (wallpaperGrid.children[0].height + wallpaperGrid.rowSpacing)
        var rowBottom = rowTop + wallpaperGrid.children[0].height
        if (rowTop < scrollArea.contentY)
            scrollArea.contentY = rowTop
        else if (rowBottom > scrollArea.contentY + scrollArea.height)
            scrollArea.contentY = rowBottom - scrollArea.height
    }

    function activateSelection() {
        if (currentIndex >= 0 && currentIndex < vm.wallpapers.length)
            vm.selectWallpaper(vm.wallpapers[currentIndex].path)
    }

    Keys.onLeftPressed: moveSelection(-1)
    Keys.onRightPressed: moveSelection(1)
    Keys.onUpPressed: moveSelection(-3)
    Keys.onDownPressed: moveSelection(3)
    Keys.onReturnPressed: activateSelection()
    Keys.onEnterPressed: activateSelection()
    Keys.onEscapePressed: ExpansionManager.requestCollapse()
    Component.onCompleted: forceActiveFocus()

    width: parent ? parent.width : ShellMetrics.wallpaperSelectorWidth

    // Max-height clamp: themes can hold many wallpapers, so the grid
    // scrolls inside the panel instead of stretching the surface past
    // maxPanelHeight (same pattern as the Launcher).
    readonly property real maxPanelHeight: 250
    implicitHeight: Math.min(scrollArea.contentHeight, maxPanelHeight)

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

            Item {
                width: parent.width
                height: 16

                ShellText {
                    anchors.left: parent.left
                    anchors.leftMargin: Spacing.panel.padding
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wallpaper"
                    role: ShellText.Role.CaptionMedium
                    textColor: Colors.fg
                }
            }

            // Wide two-row-style browser: quick visual scanning without
            // filename noise. Additional rows scroll inside the same tray.
            Grid {
                id: wallpaperGrid
                width: parent.width - Spacing.panel.padding * 2
                x: Spacing.panel.padding
                columns: 5
                columnSpacing: Spacing.xs
                rowSpacing: Spacing.xs

                Repeater {
                    model: vm.wallpapers

                    WallpaperCard {
                        required property var modelData
                        required property int index
                        width: (wallpaperGrid.width - wallpaperGrid.columnSpacing * (wallpaperGrid.columns - 1))
                               / wallpaperGrid.columns
                        height: 86
                        name: modelData.name
                        thumbnailSource: modelData.thumbnail
                        selected: modelData.selected
                        highlighted: index === wallpaperSelector.currentIndex
                        compact: true

                        onClicked: {
                            wallpaperSelector.currentIndex = index
                            vm.selectWallpaper(modelData.path)
                        }
                    }
                }
            }

            // Empty state
            ShellText {
                visible: vm.isEmpty
                text: "No wallpapers found"
                role: ShellText.Role.Body
                textColor: Colors.fgMuted
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Item { width: parent.width; height: Spacing.xs }
        }
    }
}
