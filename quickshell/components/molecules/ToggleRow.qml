import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: toggleRow

    // ═══════════════════════════════════════════════════════════════
    //  ToggleRow
    //
    //  Horizontal row: [icon] [title + subtitle] [ShellToggle].
    //  Used for settings toggles, permission rows, etc.
    //
    //  checked is aliased directly to ShellToggle.checked,
    //  making it the single source of truth — no binding breakage.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property alias checked: toggleItem.checked
    signal toggled()

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.listItem.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: Radius.listItem.background
        color: "transparent"
    }

    // ── Content ────────────────────────────────────────────────────
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
        ShellIcon {
            id: rowIcon
            visible: toggleRow.iconName !== ""
            name: toggleRow.iconName
            iconSize: Spacing.listItem.iconSize
            iconColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
        }

        // Title + subtitle
        Column {
            id: textColumn
            spacing: Spacing.xxs
            anchors.verticalCenter: parent.verticalCenter
            width: contentRow.width
                   - rowIcon.width - toggleItem.width
                   - (rowIcon.visible ? Spacing.listItem.gap : 0)
                   - Spacing.listItem.gap

            ShellText {
                text: toggleRow.title
                role: ShellText.Role.Body
                textColor: Colors.fg
                width: parent.width
            }

            ShellText {
                text: toggleRow.subtitle
                visible: toggleRow.subtitle !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
                width: parent.width
            }
        }

        // Toggle
        ShellToggle {
            id: toggleItem
            anchors.verticalCenter: parent.verticalCenter

            onToggled: toggleRow.toggled()
        }
    }

    // ── Click entire row to toggle ─────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            toggleItem.checked = !toggleItem.checked
            toggleRow.toggled()
        }
    }
}
