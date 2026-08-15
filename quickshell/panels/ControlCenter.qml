import QtQuick

import qs.tokens
import qs.metrics
import qs.settings
import qs.components.atoms
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
    //
    //  Layout (compact):
    //    Header → Quick toggles → Volume → Brightness
    //    → Media card → Power actions.
    //  No section labels. Section visibility honors SettingsStore
    //  ccShow* toggles.
    // ═══════════════════════════════════════════════════════════════

    // ── ViewModel ──────────────────────────────────────────────────
    ControlCenterViewModel {
        id: vm
    }

    // ── Layout ─────────────────────────────────────────────────────
    width: parent ? parent.width : ShellMetrics.controlCenterWidth
    implicitHeight: contentColumn.height

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
            visible: SettingsStore.ccShowQuickToggles

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
            visible: SettingsStore.ccShowVolume

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
            visible: SettingsStore.ccShowBrightness

            onMoved: function(newValue) {
                vm.setBrightness(newValue)
            }
        }

        // ── Battery ──────────────────────────────────────────────
        DynamicBatteryWidget {
            width: parent.width
            hasBattery: vm.hasBattery
            iconName: vm.batteryIcon
            percentage: vm.batteryPercentage
            charging: vm.batteryCharging
            visible: vm.hasBattery && SettingsStore.ccShowBattery
        }

        // ── Media mini card ──────────────────────────────────────
        MediaMiniCard {
            width: parent.width
            visible: vm.hasMedia && SettingsStore.ccShowMedia
            artworkSource: vm.mediaArtwork
            title: vm.mediaTitle
            artist: vm.mediaArtist
            playing: vm.mediaPlaying

            onPlayPause: vm.playPause()
            onNext: vm.next()
            onPrevious: vm.previous()
        }

        // ── Power Actions ────────────────────────────────────────
        PowerActionsRow {
            width: parent.width
        }

        // ── Bottom padding ───────────────────────────────────────
        Item {
            width: parent.width
            height: Spacing.xs
        }
    }
}
