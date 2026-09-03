import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms
import qs.state

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
    readonly property real maxPanelHeight: ShellMetrics.panelSurfaceHeight
                                          - ShellMetrics.expandedPadding * 2
    implicitHeight: Math.min(contentColumn.height, maxPanelHeight)

    // ── Keyboard navigation ──────────────────────────────────────────────────
    property int currentIndex: -1
    property string pendingSsid: ""
    property bool passwordPromptOpen: false

    focus: true

    function connectNetwork(item) {
        if (!item || item.connected) return
        if (item.saved || !item.secured) {
            vm.connectToNetwork(item.rawSsid, "")
            return
        }
        wifiPanel.pendingSsid = item.rawSsid
        wifiPanel.passwordPromptOpen = true
        passwordInput.forceActiveFocus()
    }

    function ensureNetworkVisible(index) {
        var row = networkRepeater.itemAt(index)
        if (!row) return
        var rowTop = networksSection.y + row.y
        var rowBottom = rowTop + row.height
        if (rowTop < scrollArea.contentY)
            scrollArea.contentY = rowTop
        else if (rowBottom > scrollArea.contentY + scrollArea.height)
            scrollArea.contentY = rowBottom - scrollArea.height
    }

    Keys.onEscapePressed: ExpansionManager.requestCollapse()

    Connections {
        target: vm.availableNetworksModel
        function onCountChanged() { wifiPanel.currentIndex = -1 }
    }

    // When a connect attempt fails (e.g. the saved secret is stale — the
    // phone hotspot password changed since last connect), fall back to the
    // password prompt instead of leaving the user with a dead timeout.
    // Only auto-prompts when the network is still visible AND secured;
    // a genuinely out-of-range network just shows the error text.
    Connections {
        target: NetworkState
        function onConnectFailed(ssid, message) {
            if (!ssid) return
            for (var i = 0; i < vm.availableNetworksModel.count; i++) {
                var item = vm.availableNetworksModel.get(i)
                if (item.rawSsid !== ssid) continue
                if (!item.secured) return
                wifiPanel.pendingSsid = ssid
                wifiPanel.passwordPromptOpen = true
                passwordInput.forceActiveFocus()
                return
            }
        }
    }

    Keys.onDownPressed: {
        if (vm.availableNetworksModel.count > 0)
            wifiPanel.currentIndex = Math.min(wifiPanel.currentIndex + 1,
                vm.availableNetworksModel.count - 1)
        Qt.callLater(function() { wifiPanel.ensureNetworkVisible(wifiPanel.currentIndex) })
        event.accepted = true
    }
    Keys.onUpPressed: {
        wifiPanel.currentIndex = Math.max(wifiPanel.currentIndex - 1, -1)
        Qt.callLater(function() { wifiPanel.ensureNetworkVisible(wifiPanel.currentIndex) })
        event.accepted = true
    }
    Keys.onReturnPressed: {
        var idx = wifiPanel.currentIndex >= 0
            ? wifiPanel.currentIndex : 0
        if (vm.availableNetworksModel.count > 0) {
            var item = vm.availableNetworksModel.get(idx)
            wifiPanel.connectNetwork(item)
        }
    }

    Flickable {
        id: scrollArea
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height
        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

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

        ShellButton {
            width: parent.width
            height: Spacing.button.height
            fillWidth: true
            text: vm.scanning ? "Scanning…" : "Scan for networks"
            iconName: "refresh"
            disabled: vm.scanning || !vm.wifiEnabled
            onClicked: vm.scan()
        }

        // Current connection info
        SettingRow {
            width: parent.width
            visible: vm.connected
            iconName: "signal_wifi_4_bar"
            title: vm.currentSsid
            subtitle: vm.strengthLabel
            trailing: Component {
                ShellButton {
                    text: "Disconnect"
                    iconName: "link_off"
                    onClicked: vm.disconnect()
                }
            }
        }

        Rectangle {
            width: parent.width
            height: passwordColumn.height + Spacing.card.padding * 2
            visible: wifiPanel.passwordPromptOpen
            radius: Radius.card.background
            color: Colors.surface
            border.width: 1
            border.color: Colors.borderStrong

            Column {
                id: passwordColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Spacing.card.padding
                }
                spacing: Spacing.sm

                ShellText {
                    text: "Join " + wifiPanel.pendingSsid
                    role: ShellText.Role.CaptionMedium
                    textColor: Colors.fg
                }

                Rectangle {
                    width: parent.width
                    height: Spacing.input.height
                    radius: Radius.input.background
                    color: Colors.inputBg
                    border.width: passwordInput.activeFocus ? 1 : 0
                    border.color: Colors.inputBorderFocus

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.margins: Spacing.input.paddingH
                        color: Colors.fg
                        echoMode: TextInput.Password
                        font.family: Typography.body.family
                        font.pixelSize: Typography.body.size
                        verticalAlignment: Text.AlignVCenter
                        onAccepted: {
                            vm.connectToNetwork(wifiPanel.pendingSsid, text)
                            wifiPanel.passwordPromptOpen = false
                            text = ""
                        }
                    }
                }

                Row {
                    spacing: Spacing.sm
                    ShellButton {
                        text: "Cancel"
                        onClicked: {
                            wifiPanel.passwordPromptOpen = false
                            passwordInput.text = ""
                        }
                    }
                    ShellButton {
                        text: "Connect"
                        iconName: "wifi"
                        active: true
                        disabled: passwordInput.text.length === 0
                        onClicked: {
                            vm.connectToNetwork(wifiPanel.pendingSsid, passwordInput.text)
                            wifiPanel.passwordPromptOpen = false
                            passwordInput.text = ""
                        }
                    }
                }
            }
        }

        ShellText {
            width: parent.width
            visible: vm.connectionStatus !== "" || vm.lastError !== ""
            text: vm.lastError !== "" ? vm.lastError : vm.connectionStatus
            role: ShellText.Role.Caption
            textColor: vm.lastError !== "" ? Colors.error : Colors.fgMuted
            wrapMode: Text.WordWrap
        }

        // Available networks
        Column {
            id: networksSection
            width: parent.width
            spacing: Spacing.xs
            visible: vm.hasNetworks

            SectionHeader {
                width: parent.width
                text: "Available Networks"
            }

            Repeater {
                id: networkRepeater
                model: vm.availableNetworksModel

                SettingRow {
                    width: parent.width
                    iconName: model.iconName
                    title: model.ssid
                    subtitle: model.subtitle

                    Rectangle {
                        anchors.fill: parent
                        radius: Radius.listItem.background
                        color: Colors.accentSurface
                        opacity: index === wifiPanel.currentIndex ? 0.3 : 0.0
                        z: -1
                        Behavior on opacity { NumberAnimation { duration: Motion.listItem.hoverDuration } }
                    }

                    onClicked: {
                        if (model.connected) {
                            vm.disconnect()
                        } else {
                            wifiPanel.connectNetwork(model)
                        }
                    }
                }
            }
        }

        Item { width: parent.width; height: Spacing.xs }
    }
    }

    Rectangle {
        readonly property real ratio: scrollArea.height / Math.max(scrollArea.contentHeight, 1)
        visible: scrollArea.contentHeight > scrollArea.height + 1
        width: 3
        height: Math.max(30, parent.height * ratio)
        radius: width / 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        y: (parent.height - height) * (scrollArea.contentY
           / Math.max(1, scrollArea.contentHeight - scrollArea.height))
        color: Colors.scrollbarHandle
        opacity: scrollArea.moving || scrollArea.flicking ? 0.95 : 0.58

        Behavior on opacity { NumberAnimation { duration: Motion.duration.fast } }
    }
}
