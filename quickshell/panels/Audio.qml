import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: audioPanel

    // ═══════════════════════════════════════════════════════════════
    //  Audio — PURE VIEW
    //
    //  Audio management panel with volume + source controls.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    AudioViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.audioWidth
    height: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: "Audio"
            iconName: "volume_up"
        }

        // Output volume
        SmoothSliderRow {
            width: parent.width
            iconName: vm.outputIcon
            title: "Output"
            from: 0.0
            to: 1.0
            value: vm.outputVolume
            valueText: vm.outputVolumeText
            onMoved: vm.setVolume(newValue)
        }

        // Mute toggle
        ToggleRow {
            width: parent.width
            iconName: "volume_off"
            title: "Mute"
            checked: vm.outputMuted
            onToggled: vm.toggleMute()
        }

        // Device name
        SettingRow {
            width: parent.width
            visible: vm.hasDevice
            iconName: "speaker"
            title: vm.deviceName
        }

        // Input volume
        SectionHeader {
            width: parent.width
            text: "Input"
        }

        SmoothSliderRow {
            width: parent.width
            iconName: vm.inputIcon
            title: "Microphone"
            from: 0.0
            to: 1.0
            value: vm.inputVolume
            valueText: vm.inputVolumeText
            onMoved: vm.setSourceVolume(newValue)
        }

        ToggleRow {
            width: parent.width
            iconName: "mic_off"
            title: "Mute Mic"
            checked: vm.inputMuted
            onToggled: vm.toggleSourceMute()
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
