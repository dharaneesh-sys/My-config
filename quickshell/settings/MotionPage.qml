import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: motionPage

    // ═══════════════════════════════════════════════════════════════
    //  MotionPage
    //
    //  Motion settings: animations, spring physics, durations,
    //  and presets. Composed from molecules only.
    //  All controls bind to SettingsStore via MotionViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    MotionViewModel { id: vm }

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
                title: "Motion"
                subtitle: "Animation and transition settings"
            }

            // ── Animations ─────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Animations"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ToggleRow {
                            width: parent.width
                            iconName: "animation"
                            title: "Enable animations"
                            subtitle: "Animate transitions and motion"
                            checked: vm.animationsEnabled
                            onToggled: vm.setAnimationsEnabled(!vm.animationsEnabled)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "speed"
                            title: "Speed"
                            from: 0.5
                            to: 2.0
                            value: vm.animationSpeed
                            valueText: vm.animationSpeedText
                            onMoved: vm.setAnimationSpeed(newValue)
                        }
                    }
                }
            }

            // ── Spring physics ─────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Spring Physics"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "compress"
                            title: "Damping"
                            from: 0.1
                            to: 1.5
                            value: vm.springDamping
                            valueText: vm.springDampingText
                            onMoved: vm.setSpringDamping(newValue)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "expand"
                            title: "Stiffness"
                            from: 0.1
                            to: 5.0
                            value: vm.springStiffness
                            valueText: vm.springStiffnessText
                            onMoved: vm.setSpringStiffness(newValue)
                        }
                    }
                }
            }

            // ── Durations ──────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Durations"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SliderRow {
                            width: parent.width
                            iconName: "unfold_more"
                            title: "Expand"
                            from: Motion.duration.micro
                            to: Motion.duration.glacial * 2
                            value: vm.expandDuration
                            valueText: vm.expandDurationText
                            onMoved: vm.setExpandDuration(newValue)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "unfold_less"
                            title: "Collapse"
                            from: Motion.duration.micro
                            to: Motion.duration.glacial * 2
                            value: vm.collapseDuration
                            valueText: vm.collapseDurationText
                            onMoved: vm.setCollapseDuration(newValue)
                        }
                    }
                }
            }

            // ── Presets ────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Presets"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        Repeater {
                            model: vm.presets

                            delegate: SettingRow {
                                required property var modelData
                                width: parent.width
                                iconName: "tune"
                                title: modelData.label
                                subtitle: "Damping " + modelData.springDamping
                                         + " · Stiffness " + modelData.springStiffness
                                         + " · " + modelData.expandDuration + "ms"

                                onClicked: vm.applyPreset(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
