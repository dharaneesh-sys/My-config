import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: mediaPage

    // ═══════════════════════════════════════════════════════════════
    //  MediaPage
    //
    //  Media settings: album art, progress bar, preferred player.
    //  Composed from molecules only. All controls bind to
    //  SettingsStore via MediaSettingsViewModel.
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    MediaSettingsViewModel { id: vm }

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
                title: "Media"
                subtitle: "Media player integration"
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
                            iconName: "album"
                            title: "Show album art"
                            subtitle: "Display cover art in media controls"
                            checked: vm.showAlbumArt
                            onToggled: vm.setShowAlbumArt(!vm.showAlbumArt)
                        }

                        ToggleRow {
                            width: parent.width
                            iconName: "linear_scale"
                            title: "Show progress bar"
                            subtitle: "Display playback position and length"
                            checked: vm.showProgress
                            onToggled: vm.setShowProgress(!vm.showProgress)
                        }
                    }
                }
            }

            // ── Player ─────────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Player"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        SettingRow {
                            width: parent.width
                            iconName: "music_note"
                            title: "Preferred player"
                            subtitle: vm.preferredPlayerLabel
                        }

                        ShellButton {
                            text: vm.preferredPlayer !== "" ? "Clear" : "Auto-detect"
                            iconName: vm.preferredPlayer !== "" ? "clear" : "autorenew"
                            onClicked: vm.clearPreferredPlayer()
                        }
                    }
                }
            }
        }
    }
}
