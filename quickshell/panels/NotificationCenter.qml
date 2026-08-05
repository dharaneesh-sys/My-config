import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: notificationCenter

    // ═══════════════════════════════════════════════════════════════
    //  NotificationCenter — PURE VIEW
    //
    //  Notification list panel. Triggered by Super+N.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    NotificationCenterViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.notificationCenterWidth
    height: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: "Notifications"
            iconName: "notifications"
            subtitle: vm.headerSubtitle
        }

        // DND toggle
        ToggleRow {
            width: parent.width
            iconName: "do_not_disturb_on"
            title: "Do Not Disturb"
            checked: vm.dnd
            onToggled: vm.toggleDnd()
        }

        // Notification list
        Column {
            width: parent.width
            spacing: Spacing.xs
            visible: vm.hasNotifications

            Repeater {
                model: vm.notificationsModel

                NotificationCard {
                    width: parent.width
                    appName: model.appName
                    iconName: model.iconName
                    title: model.title
                    body: model.body
                    timestamp: model.timestamp

                    onDismissed: vm.dismiss(model.notifId)
                    onClicked: vm.markRead(model.notifId)
                }
            }
        }

        // Dismiss all
        ShellButton {
            visible: vm.hasNotifications
            text: "Clear All"
            iconName: "clear_all"
            onClicked: vm.dismissAll()
        }

        // Empty state
        ShellText {
            visible: !vm.hasNotifications
            text: "No notifications"
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
