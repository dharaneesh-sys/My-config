import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.state
import qs.settings
import qs.viewmodels

Item {
    id: appearancePage

    // ═══════════════════════════════════════════════════════════════
    //  AppearancePage
    //
    //  Appearance settings: blur, opacity, animations.
    //  Composed from molecules only. All controls bind to
    //  SettingsStore via AppearanceViewModel.
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
                title: "Appearance"
                subtitle: "Theme, colors, and visual style"
            }

            // ── Current selection summary ──────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Current"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "palette"
                            title: "Theme"
                            subtitle: vm.currentThemeLabel
                            onClicked: SettingsState.navigate("themes")
                            
                            trailing: Component {
                                Row {
                                    spacing: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    Repeater {
                                        model: [Colors.bg, Colors.surface, Colors.accent, Colors.error]
                                        Rectangle {
                                            width: 16; height: 16; radius: 8
                                            color: modelData
                                            border.width: 1; border.color: Colors.border
                                        }
                                    }
                                }
                            }
                        }

                        SettingRow {
                            width: parent.width
                            iconName: "wallpaper"
                            title: "Wallpaper"
                            subtitle: vm.currentWallpaper !== ""
                                     ? vm.currentWallpaper.split("/").pop()
                                     : "None"
                            onClicked: SettingsState.navigate("wallpaper")
                        }
                    }
                }
            }

            // ── Blur card ──────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Blur"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ToggleRow {
                            width: parent.width
                            iconName: "blur_on"
                            title: "Enable blur"
                            subtitle: "Apply blur behind panels and windows"
                            checked: vm.blurEnabled
                            onToggled: vm.setBlurEnabled(!vm.blurEnabled)
                        }

                        SliderRow {
                            width: parent.width
                            iconName: "opacity"
                            title: "Strength"
                            from: 0.0
                            to: 1.0
                            value: vm.blurStrength
                            valueText: vm.blurStrengthText
                            onMoved: vm.setBlurStrength(newValue)
                        }
                    }
                }
            }

            // ── Opacity card ───────────────────────────────────
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

            // ── Animations card ────────────────────────────────
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
        }
    }
}
