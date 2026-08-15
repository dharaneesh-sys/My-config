import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: powerMenu

    // ═══════════════════════════════════════════════════════════════
    //  PowerMenu — PURE VIEW
    //
    //  System power actions. Triggered from ControlCenter.
    //  Only binds properties and emits user intent through ViewModel.
    //  Never executes Process directly.
    // ═══════════════════════════════════════════════════════════════

    PowerMenuViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.powerMenuWidth
    implicitHeight: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: "Power"
            iconName: "power_settings_new"
        }

        // Power buttons
        Column {
            width: parent.width
            spacing: Spacing.sm

            ShellButton {
                width: parent.width
                text: "Lock"
                iconName: "lock"
                onClicked: vm.lock()
            }

            ShellButton {
                width: parent.width
                text: "Suspend"
                iconName: "dark_mode"
                onClicked: vm.suspend()
            }

            ShellButton {
                width: parent.width
                text: "Reboot"
                iconName: "restart_alt"
                onClicked: vm.reboot()
            }

            ShellButton {
                width: parent.width
                text: "Shutdown"
                iconName: "power_settings_new"
                onClicked: vm.shutdown()
            }
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
