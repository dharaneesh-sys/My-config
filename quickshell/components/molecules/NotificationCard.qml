import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: notificationCard

    // ═══════════════════════════════════════════════════════════════
    //  NotificationCard
    //
    //  Individual notification display.
    //  Layout: [app icon] [title + body + timestamp] [dismiss]
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string appName: ""
    property string iconName: ""
    property string title: ""
    property string body: ""
    property string timestamp: ""
    property var actions: []
    property bool hasActionIcons: false
    property bool expanded: false
    signal dismissed()
    signal clicked()
    signal actionInvoked(int actionIndex)

    // ── Layout ─────────────────────────────────────────────────────
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth
    implicitHeight: cardBg.height

    // ── Card background ────────────────────────────────────────────
    Rectangle {
        id: cardBg
        anchors {
            left: parent.left
            right: parent.right
        }
        height: Math.max(Spacing.notification.maxHeight, cardContent.height + Spacing.notification.padding * 2)
        radius: Radius.notification.background
        color: Colors.surface
        border.width: Elevation.notification.borderWidth
        border.color: Colors.borderStrong
        clip: true
    }

    // ── Content ────────────────────────────────────────────────────
    Column {
        id: cardContent
        anchors {
            verticalCenter: cardBg.verticalCenter
            left: cardBg.left
            leftMargin: Spacing.notification.padding
            right: cardBg.right
            rightMargin: Spacing.notification.padding
        }
        spacing: Spacing.sm

        Row {
            id: contentRow
            width: parent.width
            spacing: Spacing.notification.gap

            // App icon — real theme icon via AppIcon (IconRegistry), so
            // names like "firefox" actually render instead of vanishing in
            // the Material glyph font.
            AppIcon {
                id: appIcon
                visible: notificationCard.iconName !== ""
                iconName: notificationCard.iconName
                iconSize: Spacing.notification.iconSize
                iconColor: Colors.fgMuted
                anchors.verticalCenter: parent.verticalCenter
            }

            Column {
                id: textColumn
                spacing: Spacing.xxs
                anchors.verticalCenter: parent.verticalCenter
                width: contentRow.width
                       - appIcon.width - dismissBtn.width
                       - (appIcon.visible ? Spacing.notification.gap : 0)
                       - Spacing.notification.gap

            // App name + timestamp row
            Row {
                spacing: Spacing.sm
                width: parent.width

                ShellText {
                    text: notificationCard.appName
                    visible: notificationCard.appName !== ""
                    role: ShellText.Role.Overline
                    textColor: Colors.accent
                }

                ShellText {
                    text: notificationCard.timestamp
                    visible: notificationCard.timestamp !== ""
                    role: ShellText.Role.Caption
                    textColor: Colors.fgDisabled
                }
            }

            // Title
            ShellText {
                text: notificationCard.title
                role: ShellText.Role.BodyBold
                textColor: Colors.fg
                width: parent.width
            }

            // Body
            ShellText {
                text: notificationCard.body
                visible: notificationCard.body !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
                width: parent.width
            }
            }

            // Dismiss button
            ShellButton {
                id: dismissBtn
                iconName: "close"
                implicitHeight: Spacing.icon.small
                implicitWidth: Spacing.icon.small
                onClicked: notificationCard.dismissed()
            }
        }

        Row {
            visible: notificationCard.expanded && notificationCard.actions.length > 0
            width: parent.width
            spacing: Spacing.xs

            Repeater {
                model: notificationCard.actions
                delegate: ShellButton {
                    required property var modelData
                    text: modelData.text || "Action"
                    iconName: notificationCard.hasActionIcons ? modelData.identifier : ""
                    onClicked: notificationCard.actionInvoked(index)
                }
            }
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: cardBg
        // The dismiss button must remain above this card-wide click target.
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: notificationCard.clicked()
    }
}
