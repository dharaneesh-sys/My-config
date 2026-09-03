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
    property bool hasInlineReply: false
    property string inlineReplyPlaceholder: ""
    property bool expanded: false
    signal dismissed()
    signal clicked()
    signal actionInvoked(int actionIndex)
    signal replySent(string text)

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

            // Dismiss button — ghost icon button. Transparent at rest with a
            // hairline border; fills on hover; flashes accent on press. The
            // icon rotates 90° on hover. Sits above the card-wide MouseArea
            // (z: -1) so clicks here dismiss instead of expanding the card.
            Item {
                id: dismissBtn
                width: Spacing.icon.large
                height: Spacing.icon.large

                state: dismissMouse.pressed ? "pressed"
                     : dismissMouse.containsMouse ? "hovered" : ""

                states: [
                    State {
                        name: "hovered"
                        PropertyChanges { target: dismissBg; color: Colors.surfaceRaised; border.color: Colors.borderStrong }
                        PropertyChanges { target: dismissIcon; color: Colors.fg; rotation: 90 }
                    },
                    State {
                        name: "pressed"
                        // NOTE: solid token only — Colors.pressedOverlay
                        // (8-digit #RRGGBBAA) renders as yellow in this
                        // Quickshell build, matching the pill/button fix.
                        PropertyChanges { target: dismissBg; color: Colors.surfaceVariant; border.color: Colors.borderStrong }
                        PropertyChanges { target: dismissIcon; color: Colors.accent; rotation: 90 }
                    }
                ]

                transitions: [
                    Transition {
                        from: ""; to: "hovered"; reversible: true
                        ColorAnimation { properties: "color,border.color"; duration: Motion.button.hoverDuration; easing.type: Motion.easing.standard }
                        NumberAnimation { properties: "rotation"; duration: Motion.button.hoverDuration; easing.type: Motion.easing.standard }
                    },
                    Transition {
                        from: "*"; to: "pressed"; reversible: true
                        ColorAnimation { properties: "color,border.color"; duration: Motion.button.pressDuration; easing.type: Motion.easing.standard }
                    }
                ]

                Rectangle {
                    id: dismissBg
                    anchors.fill: parent
                    radius: Radius.iconButton.background
                    color: "transparent"
                    border.width: Elevation.button.borderWidth
                    border.color: Colors.border
                }

                Text {
                    id: dismissIcon
                    anchors.centerIn: parent
                    text: "close"
                    color: Colors.fgMuted
                    font.family: Typography.families.icons
                    font.pixelSize: Spacing.icon.small
                    font.weight: Font.Normal
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: dismissMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notificationCard.dismissed()
                }
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
                    required property int index
                    // Apps that advertise inline reply also list a "reply"
                    // action. The inline field below replaces it — hide the
                    // redundant button. `index` stays the RAW actions index,
                    // so actionInvoked() maps to the correct native action.
                    visible: !(notificationCard.hasInlineReply
                              && String(modelData.identifier).toLowerCase() === "reply")
                    text: modelData.text || "Action"
                    iconName: notificationCard.hasActionIcons ? modelData.identifier : ""
                    onClicked: notificationCard.actionInvoked(index)
                }
            }
        }

        // ── Inline reply (expanded) ────────────────────────────────
        // Appears when the app advertised an "inline-reply" action
        // (WhatsApp/Telegram/Signal). Sends via sendInlineReply → DBus
        // NotificationReplied; the notification then closes itself.
        Row {
            visible: notificationCard.expanded && notificationCard.hasInlineReply
            width: parent.width
            spacing: Spacing.xs

            Rectangle {
                id: replyFieldBg
                width: parent.width - replyBtn.width - parent.spacing
                height: Spacing.input.height
                radius: Radius.input.background
                color: Colors.inputBg
                border.width: Elevation.button.borderWidth
                border.color: replyInput.activeFocus ? Colors.inputBorderFocus
                                                     : Colors.inputBorder

                Behavior on border.color {
                    ColorAnimation { duration: Motion.button.focusDuration }
                }

                TextInput {
                    id: replyInput
                    anchors {
                        fill: parent
                        leftMargin: Spacing.input.paddingH
                        rightMargin: Spacing.input.paddingH
                    }
                    verticalAlignment: Text.AlignVCenter
                    color: Colors.fg
                    font.family: Typography.body.family
                    font.pixelSize: Typography.body.size
                    clip: true

                    // Enter sends the reply.
                    onAccepted: notificationCard._sendReply()
                }

                // Placeholder — the app-provided hint ("Reply to Alice…"),
                // falling back to a generic label.
                Text {
                    anchors {
                        left: parent.left
                        leftMargin: Spacing.input.paddingH
                        verticalCenter: parent.verticalCenter
                    }
                    text: notificationCard.inlineReplyPlaceholder !== ""
                          ? notificationCard.inlineReplyPlaceholder
                          : "Reply"
                    color: Colors.fgDisabled
                    font.family: Typography.body.family
                    font.pixelSize: Typography.body.size
                    visible: !replyInput.text && !replyInput.activeFocus
                }
            }

            ShellButton {
                id: replyBtn
                iconName: "send"
                disabled: replyInput.text.trim() === ""
                implicitHeight: Spacing.input.height
                implicitWidth: Spacing.input.height
                onClicked: notificationCard._sendReply()
            }
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    function _sendReply() {
        if (replyInput.text.trim() === "") return
        notificationCard.replySent(replyInput.text)
        replyInput.text = ""
    }

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
