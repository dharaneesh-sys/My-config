import QtQuick

import qs.tokens
import qs.components.atoms
import qs.state

Item {
    id: panelHeader

    // ═══════════════════════════════════════════════════════════════
    //  PanelHeader
    //
    //  Header bar for expanded panels.
    //  Layout: [icon chip] [title + subtitle] [spacer] [trailing]
    //
    //  • title (required)
    //  • subtitle (optional)
    //  • leading icon in an accent chip (optional)
    //  • trailing actions slot (optional)
    //  • Panels close with Escape or by toggling their pill; avoiding a
    //    repeated close button keeps headers calmer and more spacious.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property alias trailingActions: trailingSlot.sourceComponent

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Math.max(iconChip.height, textColumn.height, trailingGroup.height)
                   + Spacing.panel.padding
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth

    // ── Content ────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Spacing.panel.padding
            right: parent.right
            rightMargin: Spacing.panel.padding
        }
        spacing: Spacing.panel.gap

        // ── Leading icon chip ─────────────────────────────────────
        Rectangle {
            id: iconChip
            width: Spacing.icon.medium + Spacing.sm
            height: Spacing.icon.medium + Spacing.sm
            radius: Radius.iconButton.background
            color: Colors.accentSurface
            visible: panelHeader.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter

            ShellIcon {
                anchors.centerIn: parent
                name: panelHeader.iconName
                iconSize: Spacing.icon.small
                iconColor: Colors.accent
            }
        }

        // ── Title + subtitle ──────────────────────────────────────
        Column {
            id: textColumn
            spacing: Spacing.xxs
            anchors.verticalCenter: parent.verticalCenter

            ShellText {
                text: panelHeader.title
                role: ShellText.Role.Subheading
                textColor: Colors.fg
            }

            ShellText {
                text: panelHeader.subtitle
                visible: panelHeader.subtitle !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
            }
        }

        // ── Spacer to push trailing right ─────────────────────────
        Item {
            height: 1
            width: contentRow.width
                   - iconChip.width - textColumn.width - trailingGroup.width
                   - (iconChip.visible ? Spacing.panel.gap : 0)
                   - (trailingGroup.width > 0 ? Spacing.panel.gap : 0)
                   - Spacing.panel.padding * 2
            visible: width > 0
        }

        // ── Trailing actions ──────────────────────────────────────
        Row {
            id: trailingGroup
            anchors.verticalCenter: parent.verticalCenter
            spacing: Spacing.xs

            Loader {
                id: trailingSlot
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // A restrained separator makes the header read as its own compact bar
    // without introducing a hard-coded shade or a second opaque surface.
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: Colors.divider
        opacity: 0.72
    }
}
