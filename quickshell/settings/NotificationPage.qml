import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: notificationPage

    // ═══════════════════════════════════════════════════════════════
    //  NotificationPage
    //
    //  Notification settings: display toggles, max visible,
    //  timeout, position. Composed from molecules only.
    //  All controls bind to SettingsStore via
    //  NotificationSettingsViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    NotificationSettingsViewModel { id: vm }

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
                title: "Notifications"
                subtitle: "Notification display and behavior"
            }

            // ── Display ────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Display"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ToggleRow {
                            width: parent.width
                            iconName: "description"
                            title: "Show notification body"
                            subtitle: "Display the message text"
                            checked: vm.showBody
                            onToggled: vm.setShowBody(!vm.showBody)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "action"
                            title: "Show action buttons"
                            subtitle: "Display inline reply and actions"
                            checked: vm.showActions
                            onToggled: vm.setShowActions(!vm.showActions)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "visibility"
                            title: "Maximum visible"
                            from: 1
                            to: 10
                            value: vm.maxVisible
                            valueText: vm.maxVisibleText
                            onMoved: vm.setMaxVisible(newValue)
                        }
                    }
                }
            }

            // ── Behavior ───────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Behavior"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "timer"
                            title: "Timeout"
                            from: Motion.duration.fast
                            to: Motion.duration.toast
                            value: vm.timeout
                            valueText: vm.timeoutText
                            onMoved: vm.setTimeout(newValue)
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "place"
                            title: "Position"
                            subtitle: vm.positionLabel
                        }

                        ButtonRow {
                            width: parent.width
                            buttons: vm.positionOptions.map(function(opt) {
                                return {
                                    text: opt.label,
                                    active: opt.active
                                }
                            })
                            onButtonClicked: function(index) {
                                var opt = vm.positionOptions[index]
                                if (opt) vm.setPosition(opt.key)
                            }
                        }
                    }
                }
            }
        }
    }
}
