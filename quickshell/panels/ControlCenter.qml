import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels

Item {
    id: controlCenter

    // ═══════════════════════════════════════════════════════════════
    //  ControlCenter — PURE VIEW
    //
    //  Composed from molecules, driven by ControlCenterViewModel.
    //  Only binds properties and emits user actions.
    //  Never formats, filters, sorts, or accesses Services/State.
    // ═══════════════════════════════════════════════════════════════

    // ── ViewModel ──────────────────────────────────────────────────
    ControlCenterViewModel {
        id: vm
    }

    // ── Layout ─────────────────────────────────────────────────────
    width: parent ? parent.width : ShellMetrics.controlCenterWidth
    height: contentColumn.height

    // ── Content ────────────────────────────────────────────────────
    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        // ── Header ───────────────────────────────────────────────
        PanelHeader {
            width: parent.width
            title: "Control Center"
            iconName: "tune"
        }

        // ── Quick settings grid ──────────────────────────────────
        QuickSettingsGridModel {
            width: parent.width
            model: vm.quickTilesModel

            onTileClicked: function(index) {
                if (index >= 0 && index < vm.tileActions.length)
                    vm.tileActions[index]()
            }
        }

        // ── Volume ───────────────────────────────────────────────
        SmoothSliderRow {
            width: parent.width
            iconName: vm.volumeIcon
            title: "Volume"
            from: 0.0
            to: 1.0
            value: vm.volumeValue
            valueText: vm.volumeText

            onMoved: function(newValue) {
                vm.setVolume(newValue)
            }
        }

        // ── Brightness ───────────────────────────────────────────
        SmoothSliderRow {
            width: parent.width
            iconName: vm.brightnessIcon
            title: "Brightness"
            from: 0.0
            to: 1.0
            value: vm.brightnessValue
            valueText: vm.brightnessText

            onMoved: function(newValue) {
                vm.setBrightness(newValue)
            }
        }

        // ── Media mini card ──────────────────────────────────────
        MediaMiniCard {
            width: parent.width
            visible: vm.hasMedia
            artworkSource: vm.mediaArtwork
            title: vm.mediaTitle
            artist: vm.mediaArtist
            playing: vm.mediaPlaying

            onPlayPause: vm.playPause()
            onNext: vm.next()
            onPrevious: vm.previous()
        }

        // ── Notification summary ─────────────────────────────────
        SettingRow {
            width: parent.width
            iconName: "notifications"
            title: "Notifications"
            subtitle: vm.unreadText

            onClicked: vm.openNotificationCenter()
        }

        // ── Battery ──────────────────────────────────────────────
        SettingRow {
            width: parent.width
            visible: vm.hasBattery
            iconName: vm.batteryIcon
            title: "Battery"
            subtitle: vm.batteryText
        }

        // ── Bottom padding ───────────────────────────────────────
        Item {
            width: parent.width
            height: Spacing.xs
        }
    }
}
