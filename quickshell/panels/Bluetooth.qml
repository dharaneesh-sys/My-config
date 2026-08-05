import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: bluetoothPanel

    // ═══════════════════════════════════════════════════════════════
    //  Bluetooth — PURE VIEW
    //
    //  Bluetooth management panel.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    BluetoothViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.bluetoothWidth
    height: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: "Bluetooth"
            iconName: "bluetooth"
            subtitle: vm.headerSubtitle
        }

        // Enable toggle
        ToggleRow {
            width: parent.width
            iconName: "bluetooth"
            title: "Bluetooth"
            subtitle: vm.scanning ? "Scanning…" : ""
            checked: vm.enabled
            onToggled: vm.toggleEnabled()
        }

        // Scan button
        ShellButton {
            visible: vm.enabled
            text: vm.scanLabel
            iconName: "search"
            disabled: vm.scanning
            onClicked: vm.scan()
        }

        // Device list
        Column {
            width: parent.width
            spacing: Spacing.xs
            visible: vm.hasDevices

            SectionHeader {
                width: parent.width
                text: "Devices"
            }

            Repeater {
                model: vm.devicesModel

                SettingRow {
                    width: parent.width
                    iconName: "bluetooth"
                    title: model.name
                    subtitle: model.subtitle

                    onClicked: {
                        if (model.connected)
                            vm.disconnectDevice(model.address)
                        else
                            vm.connectDevice(model.address)
                    }
                }
            }
        }

        // Empty state
        ShellText {
            visible: vm.showEmptyState
            text: "No devices found"
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
