import QtQuick

import qs.tokens

Item {
    id: listItem

    // ═══════════════════════════════════════════════════════════════
    //  ListItem
    //
    //  Horizontal row: [icon] [title + subtitle] [trailing].
    //  Used for menu entries, settings rows, notification items.
    //  All dimensions from Spacing.listItem tokens.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property alias trailingContent: trailingSlot.sourceComponent

    signal clicked()

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.listItem.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: itemBg
        anchors.fill: parent
        radius: Radius.listItem.background
        color: mouseArea.pressed ? Colors.surfaceRaised
             : mouseArea.containsMouse ? Colors.surfaceVariant
             : "transparent"
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: Motion.listItem.hoverDuration }
        }
    }

    // ── Content row ────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Spacing.listItem.paddingH
            right: parent.right
            rightMargin: Spacing.listItem.paddingH
        }
        spacing: Spacing.listItem.gap

        // Icon
        Text {
            id: iconItem
            visible: listItem.iconName !== ""
            text: listItem.iconName
            color: Colors.fgMuted
            font.family: Typography.families.icons
            font.pixelSize: Spacing.listItem.iconSize
            font.weight: Font.Normal
            verticalAlignment: Text.AlignVCenter
            width: Spacing.listItem.iconSize
            height: Spacing.listItem.iconSize
        }

        // Title + subtitle column
        Column {
            id: textColumn
            spacing: 0
            width: parent.width - iconItem.width - trailingSlot.width
                   - (iconItem.visible ? Spacing.listItem.gap : 0)
                   - (trailingSlot.item ? Spacing.listItem.gap : 0)

            Text {
                id: titleText
                width: parent.width
                text: listItem.title
                color: Colors.fg
                font.family: Typography.body.family
                font.pixelSize: Typography.body.size
                font.weight: Typography.body.weight
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                id: subtitleText
                width: parent.width
                text: listItem.subtitle
                visible: listItem.subtitle !== ""
                color: Colors.fgMuted
                font.family: Typography.caption.family
                font.pixelSize: Typography.caption.size
                font.weight: Typography.caption.weight
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Trailing slot
        Loader {
            id: trailingSlot
            verticalAlignment: Loader.AlignVCenter
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: listItem.clicked()
    }

    scale: mouseArea.pressed ? 0.992 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Motion.listItem.pressDuration; easing.type: Motion.easing.standard }
    }
}
