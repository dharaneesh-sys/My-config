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
    // ═══════════════════════════════════════════════════════════════

    LauncherViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.launcherWidth
    height: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        // ── Search bar ───────────────────────────────────────────
        SearchBar {
            id: searchBar
            width: parent.width
            placeholder: "Search applications…"
            query: vm.query

            onQueryChanged: vm.setQuery(searchBar.query)
            onAccepted: {
                if (vm.resultsModel.count > 0)
                    vm.launch(vm.resultsModel.get(0).exec, vm.resultsModel.get(0).terminal)
            }
        }

        // ── Results ──────────────────────────────────────────────
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
