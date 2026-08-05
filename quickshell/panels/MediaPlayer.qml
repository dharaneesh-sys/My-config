import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: mediaPlayer

    // ═══════════════════════════════════════════════════════════════
    //  MediaPlayer — PURE VIEW
    //
    //  Media player panel. Triggered by Super+M.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    MediaPlayerViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.mediaPlayerWidth
    height: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: vm.headerTitle
            iconName: "music_note"
            subtitle: vm.headerSubtitle
        }

        // Now playing
        MediaMiniCard {
            width: parent.width
            visible: vm.hasMedia
            artworkSource: vm.artwork
            title: vm.title
            artist: vm.artist
            playing: vm.playing

            onPlayPause: vm.playPause()
            onNext: vm.next()
            onPrevious: vm.previous()
        }

        // Progress bar — SmoothSliderRow absorbs the 2s position-poll
        // steps (catch-up animation + integer-pixel rounding).
        SmoothSliderRow {
            width: parent.width
            visible: vm.hasProgress
            iconName: "schedule"
            title: ""
            from: 0.0
            to: vm.length
            value: vm.position
            valueText: vm.progressText

            onMoved: vm.seek(newValue)
        }

        // Shuffle & repeat
        Row {
            width: parent.width
            spacing: Spacing.md

            ShellButton {
                iconName: "shuffle"
                text: "Shuffle"
                active: vm.shuffleOn
                onClicked: vm.toggleShuffle()
            }

            ShellButton {
                iconName: "repeat"
                text: "Repeat"
                active: vm.repeatActive
                onClicked: vm.toggleRepeat()
            }
        }

        // Player selection
        Column {
            width: parent.width
            spacing: Spacing.xs
            visible: vm.hasMultiplePlayers

            SectionHeader {
                width: parent.width
                text: "Players"
            }

            Repeater {
                model: vm.playersModel

                SettingRow {
                    width: parent.width
                    iconName: "music_note"
                    title: model.name
                    subtitle: model.subtitle

                    onClicked: vm.selectPlayer(model.name)
                }
            }
        }

        // No media
        ShellText {
            visible: !vm.hasMedia
            text: "No media playing"
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
