import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: systemPage

    // ═══════════════════════════════════════════════════════════════
    //  SystemPage
    //
    //  System settings: import/export/reset, diagnostics, power.
    //  Composed from molecules only. Emits intent signals
    //  via SystemSettingsViewModel — does not execute
    //  Process directly.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    SystemSettingsViewModel { id: vm }

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
                title: "System"
                subtitle: "Power, battery, and system options"
            }

            // ── Configuration ──────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Configuration"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "info"
                            title: "Config version"
                            subtitle: vm.configVersion
                        }

                        ShellButton {
                            width: parent.width
                            text: "Import Settings"
                            iconName: "upload"
                            onClicked: vm.importRequested()
                        }

                        ShellButton {
                            width: parent.width
                            text: "Export Settings"
                            iconName: "download"
                            onClicked: vm.exportRequested()
                        }

                        ShellButton {
                            width: parent.width
                            text: "Reset to Defaults"
                            iconName: "restart_alt"
                            onClicked: vm.resetRequested()
                        }
                    }
                }
            }

            // ── Diagnostics ────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Diagnostics"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ShellButton {
                            width: parent.width
                            text: "Reload Shell"
                            iconName: "refresh"
                            onClicked: vm.reloadShellRequested()
                        }

                        ShellButton {
                            width: parent.width
                            text: "Open Config Directory"
                            iconName: "folder_open"
                            onClicked: vm.openConfigDirRequested()
                        }

                        ShellButton {
                            width: parent.width
                            text: "Show Logs"
                            iconName: "description"
                            onClicked: vm.showLogsRequested()
                        }
                    }
                }
            }

            // ── Power ──────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Power"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ShellButton {
                            width: parent.width
                            text: "Restart Shell"
                            iconName: "restart_alt"
                            onClicked: vm.restartShellRequested()
                        }

                        ShellButton {
                            width: parent.width
                            text: "Quit Shell"
                            iconName: "power_settings_new"
                            onClicked: vm.quitShellRequested()
                        }
                    }
                }
            }
        }
    }
}
