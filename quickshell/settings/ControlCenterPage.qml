import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: controlCenterPage

    // ═══════════════════════════════════════════════════════════════
    //  ControlCenterPage
    //
    //  Control Center settings: section visibility toggles and
    //  panel dimension sliders. Composed from molecules only.
    //  All controls bind to SettingsStore via
    //  ControlCenterSettingsViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    ControlCenterSettingsViewModel { id: vm }

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
                title: "Control Center"
                subtitle: "Quick settings and control center layout"
            }

            // ── Section visibility ─────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Visible Sections"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "info"
                            title: "Active"
                            subtitle: vm.visibleCountText
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "widgets"
                            title: "Quick toggles"
                            subtitle: "Wi-Fi, Bluetooth, DND, Theme"
                            checked: vm.showQuickToggles
                            onToggled: vm.setShowQuickToggles(!vm.showQuickToggles)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "volume_up"
                            title: "Volume"
                            checked: vm.showVolume
                            onToggled: vm.setShowVolume(!vm.showVolume)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "brightness_6"
                            title: "Brightness"
                            checked: vm.showBrightness
                            onToggled: vm.setShowBrightness(!vm.showBrightness)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "music_note"
                            title: "Media"
                            checked: vm.showMedia
                            onToggled: vm.setShowMedia(!vm.showMedia)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "notifications"
                            title: "Notifications"
                            checked: vm.showNotifications
                            onToggled: vm.setShowNotifications(!vm.showNotifications)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "battery_full"
                            title: "Battery"
                            checked: vm.showBattery
                            onToggled: vm.setShowBattery(!vm.showBattery)
                        }
                    }
                }
            }

            // ── Panel dimensions ───────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Panel Dimensions"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "unfold_more"
                            title: "Max width"
                            from: Spacing.xl * 10
                            to: Spacing.xl * 25
                            value: vm.panelMaxWidth
                            valueText: vm.panelMaxWidthText
                            onMoved: vm.setPanelMaxWidth(newValue)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "padding"
                            title: "Padding"
                            from: Spacing.xs
                            to: Spacing.xl
                            value: vm.panelPadding
                            valueText: vm.panelPaddingText
                            onMoved: vm.setPanelPadding(newValue)
                        }
                    }
                }
            }
        }
    }
}
