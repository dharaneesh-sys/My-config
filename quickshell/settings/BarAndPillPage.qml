import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: barAndPillPage

    // ═══════════════════════════════════════════════════════════════
    //  BarAndPillPage
    //
    //  Bar & Pill settings: pill dimensions, panel dimensions,
    //  blur, and opacity. Composed from molecules only.
    //  All controls bind to SettingsStore via BarAndPillViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    BarAndPillViewModel { id: vm }

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
                title: "Bar & Pill"
                subtitle: "Configure the shell bar and pill appearance"
            }

            // ── Pill dimensions ────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Pill"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "straighten"
                            title: "Width"
                            from: Spacing.xxl * 2
                            to: Spacing.xxl * 8
                            value: vm.pillWidth
                            valueText: vm.pillWidthText
                            onMoved: vm.setPillWidth(newValue)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "height"
                            title: "Height"
                            from: Spacing.lg
                            to: Spacing.xl * 3
                            value: vm.pillHeight
                            valueText: vm.pillHeightText
                            onMoved: vm.setPillHeight(newValue)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "arrow_upward"
                            title: "Top margin"
                            from: 0
                            to: Spacing.xxl
                            value: vm.pillTopMargin
                            valueText: vm.pillTopMarginText
                            onMoved: vm.setPillTopMargin(newValue)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "rounded_corner"
                            title: "Corner radius"
                            from: 0
                            to: Spacing.xl * 2
                            value: Math.min(vm.pillCornerRadius, Spacing.xl * 2)
                            valueText: vm.pillCornerRadiusText
                            onMoved: vm.setPillCornerRadius(newValue)
                        }
                    }
                }
            }

            // ── Panel dimensions ───────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Panels"
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

                        SliderRow {
                            width: parent.width
                            iconName: "rounded_corner"
                            title: "Corner radius"
                            from: 0
                            to: Spacing.xl
                            value: vm.panelCornerRadius
                            valueText: vm.panelCornerRadiusText
                            onMoved: vm.setPanelCornerRadius(newValue)
                        }
                    }
                }
            }

                        // ── Notch (Apple-style) ─────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Notch"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ToggleRow {
                            width: parent.width
                            iconName: "phone_iphone"
                            title: "Notch mode"
                            subtitle: "Apple-style flat-top notch (150×28) instead of floating pill"
                            checked: vm.notchEnabled
                            onToggled: vm.setNotchEnabled(!vm.notchEnabled)
                        }
                    }
                }
            }

            SettingsCard {
                width: parent.width
                headerText: "Opacity"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "opacity"
                            title: "Shell opacity"
                            from: 0.1
                            to: 1.0
                            value: vm.shellOpacity
                            valueText: vm.shellOpacityText
                            onMoved: vm.setShellOpacity(newValue)
                        }
                    }
                }
            }
        }
    }
}
