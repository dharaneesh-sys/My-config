import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: clockDatePage

    // ═══════════════════════════════════════════════════════════════
    //  ClockDatePage
    //
    //  Clock & Date settings: time format, seconds, pill visibility,
    //  date format, timezone. Composed from molecules only.
    //  All controls bind to SettingsStore via
    //  ClockDateSettingsViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    ClockDateSettingsViewModel { id: vm }

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
                title: "Clock & Date"
                subtitle: "Clock format and date display"
            }

            // ── Time ───────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Time"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ToggleRow {
                            width: parent.width
                            iconName: "schedule"
                            title: "24-hour format"
                            subtitle: "Use 24h instead of AM/PM"
                            checked: vm.use24h
                            onToggled: vm.setUse24h(!vm.use24h)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "timer"
                            title: "Show seconds"
                            subtitle: "Display seconds in the clock"
                            checked: vm.showSeconds
                            onToggled: vm.setShowSeconds(!vm.showSeconds)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "dashboard"
                            title: "Show clock in pill"
                            subtitle: "Display time in the top pill bar"
                            checked: vm.showInPill
                            onToggled: vm.setShowInPill(!vm.showInPill)
                        }
                    }
                }
            }

            // ── Date format ────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Date"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "calendar_today"
                            title: "Date format"
                            subtitle: vm.dateFormatLabel
                        }

                        ButtonRow {
                            width: parent.width
                            buttons: vm.dateFormatOptions.map(function(opt) {
                                return {
                                    text: opt.label,
                                    active: opt.active
                                }
                            })
                            onButtonClicked: function(index) {
                                var opt = vm.dateFormatOptions[index]
                                if (opt) vm.setDateFormat(opt.key)
                            }
                        }
                    }
                }
            }

            // ── Timezone ───────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Timezone"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "public"
                            title: "Current timezone"
                            subtitle: vm.timezoneLabel
                        }

                        // Timezone quick-select grid
                        Flow {
                            width: parent.width
                            spacing: Spacing.xs

                            Repeater {
                                model: vm.timezoneButtons

                                delegate: ShellButton {
                                    required property var modelData
                                    text: modelData.label
                                    active: modelData.active
                                    onClicked: vm.setTimezone(modelData.key)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
