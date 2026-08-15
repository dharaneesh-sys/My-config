import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: launcherPage

    // ═══════════════════════════════════════════════════════════════
    //  LauncherPage
    //
    //  Launcher settings: max results, description toggle,
    //  default action. Composed from molecules only.
    //  All controls bind to SettingsStore via
    //  LauncherSettingsViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    LauncherSettingsViewModel { id: vm }

    // ── Layout ─────────────────────────────────────────────────────
    anchors.fill: parent

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height + Spacing.settings.padding * 2
        clip: true

        Column {
            id: contentColumn
            x: Spacing.settings.padding
            y: Spacing.settings.padding
            width: flickable.width - Spacing.settings.padding * 2
            spacing: Spacing.settings.pageGap

            // ── Page header ────────────────────────────────────
            SettingsPageHeader {
                width: parent.width
                title: "Launcher"
                subtitle: "Application launcher preferences"
            }

            // ── Results ────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Results"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "format_list_numbered"
                            title: "Max results"
                            from: 1
                            to: 20
                            value: vm.maxResults
                            valueText: vm.maxResultsText
                            onMoved: vm.setMaxResults(newValue)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "description"
                            title: "Show descriptions"
                            subtitle: "Display app description below name"
                            checked: vm.showDescriptions
                            onToggled: vm.setShowDescriptions(!vm.showDescriptions)
                        }
                    }
                }
            }

            // ── Default action ─────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Default Action"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "rocket_launch"
                            title: "When an app is selected"
                            subtitle: vm.defaultActionLabel
                        }

                        ButtonRow {
                            width: parent.width
                            buttons: vm.actionOptions.map(function(opt) {
                                return {
                                    text: opt.label,
                                    active: opt.active
                                }
                            })
                            onButtonClicked: function(index) {
                                var opt = vm.actionOptions[index]
                                if (opt) vm.setDefaultAction(opt.key)
                            }
                        }
                    }
                }
            }
        }
    }
}
