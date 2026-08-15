import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: aboutPage

    // ═══════════════════════════════════════════════════════════════
    //  AboutPage
    //
    //  About settings: shell identity, version info, runtime
    //  details, links, and credits. Read-only page.
    //  Composed from molecules only. All display data from
    //  AboutViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    AboutViewModel { id: vm }

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
                title: "About"
                subtitle: vm.shellName + " " + vm.shellVersion
            }

            // ── Shell ──────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Shell"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "terminal"
                            title: "Name"
                            subtitle: vm.shellName
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "tag"
                            title: "Version"
                            subtitle: vm.shellVersion
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "label"
                            title: "Codename"
                            subtitle: vm.shellCodename
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "palette"
                            title: "Active theme"
                            subtitle: vm.currentTheme
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "tune"
                            title: "Config version"
                            subtitle: vm.configVersion
                        }
                    }
                }
            }

            // ── Runtime ────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Runtime"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "code"
                            title: "Qt"
                            subtitle: vm.qtVersion
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "layers"
                            title: "QtQuick"
                            subtitle: vm.qtQuickVersion
                        }
                    }
                }
            }

            // ── Links ──────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Links"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "source"
                            title: "Repository"
                            subtitle: vm.repositoryUrl
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "menu_book"
                            title: "Documentation"
                            subtitle: vm.docsUrl
                        }
                    }
                }
            }

            // ── Credits ────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Credits"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        Repeater {
                            model: vm.credits
                            delegate: SettingRow {
                                required property var modelData
                                width: parent.width
                                iconName: "hub"
                                title: modelData.name
                                subtitle: modelData.role
                            }
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "gavel"
                            title: "License"
                            subtitle: vm.licenseName
                        }
                    }
                }
            }
        }
    }
}
