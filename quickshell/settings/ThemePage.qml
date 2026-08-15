import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: themePage

    // ═══════════════════════════════════════════════════════════════
    //  ThemePage
    //
    //  Theme selection grid. Composed from ThemeCard molecules.
    //  All controls bind to SettingsStore via AppearanceViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    AppearanceViewModel { id: vm }

    // ── Layout ─────────────────────────────────────────────────────
    anchors.fill: parent

    // ── Content ────────────────────────────────────────────────────
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
                title: "Themes"
                subtitle: "Choose and preview color themes"
            }

            // ── Current theme ──────────────────────────────────
            SettingRow {
                width: parent.width
                iconName: "palette"
                title: "Active theme"
                subtitle: vm.currentThemeLabel
            }

            // ── Theme grid ─────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Available Themes"
                bodyContent: Component {
                    Flow {
                        width: parent ? parent.width : 0
                        spacing: Spacing.sm

                        Repeater {
                            model: vm.themes

                            ThemeCard {
                                required property var modelData
                                name: modelData.label
                                primaryColor: modelData.primaryColor
                                surfaceColor: modelData.surfaceColor
                                onSurfaceColor: modelData.onSurfaceColor
                                selected: modelData.selected

                                onClicked: vm.selectTheme(modelData.key)
                            }
                        }
                    }
                }
            }
        }
    }
}
