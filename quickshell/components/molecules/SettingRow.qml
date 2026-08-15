import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: settingRow

    // ═══════════════════════════════════════════════════════════════
    //  SettingRow
    //
    //  Generic settings row: [icon chip] [title + subtitle] [spacer]
    //                        [trailing] [hover chevron]
    //  The trailing slot accepts any component (toggle, slider,
    //  text, arrow indicator, etc.).
    //
    //  Unlike ToggleRow/SliderRow which bundle a specific control,
    //  SettingRow is a blank canvas for arbitrary trailing content.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property alias trailing: trailingSlot.sourceComponent
    signal clicked()

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.listItem.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: rowBg
        anchors.fill: parent
        radius: Radius.listItem.background
        color: mouseArea.containsMouse ? Colors.surfaceRaised : "transparent"
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: Motion.listItem.hoverDuration }
        }
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

        // ── Icon chip ─────────────────────────────────────────────
        Item {
            id: iconChip
            width: Spacing.listItem.iconSize + Spacing.sm * 2    // 32
            height: width
            visible: settingRow.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Radius.listItem.background
                color: Colors.surfaceVariant
            }

            ShellIcon {
                anchors.centerIn: parent
                name: settingRow.iconName
                iconSize: Spacing.listItem.iconSize
                iconColor: Colors.fgMuted
            }
        }

        // ── Title + subtitle ──────────────────────────────────────
        Column {
            id: textColumn
            spacing: Spacing.xxs
            anchors.verticalCenter: parent.verticalCenter

            ShellText {
                text: settingRow.title
                role: ShellText.Role.Body
                textColor: Colors.fg
            }

            ShellText {
                text: settingRow.subtitle
                visible: settingRow.subtitle !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
            }
        }

        // ── Spacer ────────────────────────────────────────────────
        Item {
            height: 1
            // contentRow width already excludes paddingH (anchor margins)
            width: contentRow.width
                   - iconChip.width - textColumn.width
                   - trailingSlot.width - chevronSlot.width
                   - (iconChip.visible ? Spacing.listItem.gap : 0)
                   - (trailingSlot.item ? Spacing.listItem.gap : 0)
                   - (chevronSlot.visible ? Spacing.listItem.gap : 0)
            visible: width > 0
        }

        // ── Trailing slot ─────────────────────────────────────────
        Loader {
            id: trailingSlot
            anchors.verticalCenter: parent.verticalCenter
        }

        // ── Hover chevron ─────────────────────────────────────────
        Item {
            id: chevronSlot
            width: Spacing.icon.small
            height: Spacing.icon.small
            anchors.verticalCenter: parent.verticalCenter

            ShellIcon {
                anchors.centerIn: parent
                name: "chevron_right"
                iconSize: Spacing.icon.small
                iconColor: Colors.accent
                opacity: mouseArea.containsMouse ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation { duration: Motion.duration.fast }
                }
            }
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        // Keep trailing controls (toggle, slider, disconnect button) above
        // the row hit area. The visual background itself is non-interactive.
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: settingRow.clicked()
    }

    scale: mouseArea.pressed ? 0.99 : (mouseArea.containsMouse ? 1.005 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: Motion.listItem.hoverDuration; easing.type: Motion.easing.standard }
    }
}
