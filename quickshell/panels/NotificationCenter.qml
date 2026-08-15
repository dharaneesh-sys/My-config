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

    // Max-height clamp: long notification lists scroll inside the
    // panel instead of stretching the surface past maxPanelHeight.
    readonly property real maxPanelHeight: ShellMetrics.panelSurfaceHeight
                                          - ShellMetrics.expandedPadding * 2
    implicitHeight: Math.min(scrollArea.contentHeight, maxPanelHeight)
    property string expandedNotificationId: ""

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
                        expanded: notificationCenter.expandedNotificationId === model.notifId
                        actions: vm.actionsFor(model.notifId)
                        hasActionIcons: vm.hasActionIconsFor(model.notifId)

                        onDismissed: vm.dismiss(model.notifId)
                        onClicked: {
                            vm.markRead(model.notifId)
                            notificationCenter.expandedNotificationId = expanded ? "" : model.notifId
                        }
                        onActionInvoked: vm.invokeAction(model.notifId, actionIndex)
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

    // Always-visible-when-needed scroll affordance. It reacts to both wheel
    // and touch flicking and uses the active palette instead of a fixed gray.
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
