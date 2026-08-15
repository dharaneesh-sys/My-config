import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms
import qs.state

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
    implicitHeight: contentColumn.height

    // ── Keyboard navigation ──────────────────────────────────────────────────
    property int currentIndex: -1

    focus: true

    Keys.onEscapePressed: ExpansionManager.requestCollapse()

    Connections {
        target: vm.devicesModel
        function onCountChanged() { bluetoothPanel.currentIndex = -1 }
    }

    Keys.onDownPressed: {
        if (vm.devicesModel.count > 0)
            bluetoothPanel.currentIndex = Math.min(bluetoothPanel.currentIndex + 1,
                vm.devicesModel.count - 1)
        event.accepted = true
    }
    Keys.onUpPressed: {
        bluetoothPanel.currentIndex = Math.max(bluetoothPanel.currentIndex - 1, -1)
        event.accepted = true
    }
    Keys.onReturnPressed: {
        var idx = bluetoothPanel.currentIndex >= 0
            ? bluetoothPanel.currentIndex : 0
        if (vm.devicesModel.count > 0) {
            var item = vm.devicesModel.get(idx)
            if (item.connected)
                vm.disconnectDevice(item.address)
            else
                vm.connectDevice(item.address)
        }
    }

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
            width: parent.width
            height: Spacing.button.height
            fillWidth: true
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
                    trailing: Component {
                        ShellButton {
                            text: model.connected ? "Disconnect" : (model.paired ? "Connect" : "Pair")
                            iconName: model.connected ? "link_off" : "link"
                            onClicked: {
                                if (model.connected)
                                    vm.disconnectDevice(model.address)
                                else if (model.paired)
                                    vm.connectDevice(model.address)
                                else
                                    vm.pairDevice(model.address)
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: Radius.listItem.background
                        color: Colors.accentSurface
                        opacity: index === bluetoothPanel.currentIndex ? 0.3 : 0.0
                        z: -1
                        Behavior on opacity { NumberAnimation { duration: Motion.listItem.hoverDuration } }
                    }

                    onClicked: {
                        if (model.connected)
                            vm.disconnectDevice(model.address)
                        else if (model.paired)
                            vm.connectDevice(model.address)
                        else
                            vm.pairDevice(model.address)
                    }
                }
            }
        }

        ShellText {
            width: parent.width
            visible: vm.actionStatus !== "" || vm.lastError !== ""
            text: vm.lastError !== "" ? vm.lastError : vm.actionStatus
            role: ShellText.Role.Caption
            textColor: vm.lastError !== "" ? Colors.error : Colors.fgMuted
            wrapMode: Text.WordWrap
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
