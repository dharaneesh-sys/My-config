import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: wallpaperPage

    // ═══════════════════════════════════════════════════════════════
    //  WallpaperPage
    //
    //  Wallpaper selection grid with backend picker.
    //  Composed from WallpaperCard, ButtonRow, SettingRow molecules.
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
                title: "Wallpaper"
                subtitle: "Set your desktop wallpaper"
            }

            // ── Backend selection ──────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Backend"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "image"
                            title: "Current backend"
                            subtitle: vm.wallpaperBackend
                        }

                        ButtonRow {
                            width: parent.width
                            buttons: vm.backendOptions.map(function(opt) {
                                return {
                                    text: opt.label,
                                    active: opt.active,
                                    onClicked: function() { vm.setBackend(opt.key) }
                                }
                            })
                            onButtonClicked: function(index) {
                                var opt = vm.backendOptions[index]
                                if (opt) vm.setBackend(opt.key)
                            }
                        }
                    }
                }
            }

            // ── Wallpaper directory ────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Directory"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "folder"
                            title: "Wallpaper directory"
                            subtitle: vm.wallpaperDirectory !== ""
                                     ? vm.wallpaperDirectory
                                     : "Not set"
                        }

                        ShellButton {
                            text: "Refresh"
                            iconName: "refresh"
                            onClicked: vm.refreshWallpapers()
                        }
                    }
                }
            }

            // ── Wallpaper grid ─────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Wallpapers"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.sm
                        width: parent ? parent.width : 0

                        Flow {
                            width: parent.width
                            spacing: Spacing.sm

                            Repeater {
                                model: vm.wallpapers

                                WallpaperCard {
                                    required property var modelData
                                    name: modelData.name
                                    thumbnailSource: modelData.thumbnail
                                    selected: modelData.selected

                                    onClicked: vm.selectWallpaper(modelData.path)
                                }
                            }
                        }

                        ShellText {
                            visible: vm.wallpapersEmpty
                            text: "No wallpapers found"
                            role: ShellText.Role.Body
                            textColor: Colors.fgMuted
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width
                        }
                    }
                }
            }
        }
    }
}
