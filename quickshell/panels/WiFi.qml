import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: wifiPanel

    // ═══════════════════════════════════════════════════════════════
    //  WiFi — PURE VIEW
    //
    //  WiFi management panel.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    WiFiViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.wifiWidth
    height: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: "Wi-Fi"
            iconName: "wifi"
            subtitle: vm.headerSubtitle
        }

        // WiFi toggle
        ToggleRow {
            width: parent.width
            iconName: "wifi"
            title: "Wi-Fi"
            checked: vm.wifiEnabled
            onToggled: vm.toggleWifi()
        }

        // Current connection info
        SettingRow {
            width: parent.width
            visible: vm.connected
            iconName: "signal_wifi_4_bar"
            title: vm.currentSsid
            subtitle: vm.strengthLabel
        }

        // Available networks
        Column {
            width: parent.width
            spacing: Spacing.xs
            visible: vm.hasNetworks

            SectionHeader {
                width: parent.width
                text: "Available Networks"
            }

            Repeater {
                model: vm.availableNetworksModel

                SettingRow {
                    width: parent.width
                    iconName: model.iconName
                    title: model.ssid
                    subtitle: model.subtitle

                    onClicked: {
                        if (!model.connected)
                            vm.connectToNetwork(model.rawSsid)
                    }
                }
            }
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
