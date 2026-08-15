import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: appRow

    // ═══════════════════════════════════════════════════════════════
    //  AppRow
    //
    //  Application entry row for launcher results.
    //  Layout: [icon tile] [name + description] [status slot]
    //
    //  • Icon tile — real app icon from the system icon themes
    //    (AppIcon resolves the desktop-entry name), or a Material
    //    fallback glyph when the theme has no matching file.
    //  • Name + description
    //  • Status slot — spinner while launching, chevron on hover
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string appName: ""
    property string description: ""
    property url iconSource: ""
    property string iconName: ""
    property bool launching: false
    // Keyboard-nav selection highlight (launcher Up/Down).
    property bool highlighted: false
    signal clicked()

    // ── Probe accessors (read-only, for M3 geometry harness) ───────
    readonly property real textColumnWidth: textColumn.width
    readonly property real textColumnNamePaintedWidth: textColumnName.paintedWidth

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.listItem.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    readonly property real _iconTileSize: Spacing.icon.large + Spacing.sm * 2   // 40

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: rowBg
        anchors.fill: parent
        radius: Radius.listItem.background
        color: highlighted ? Colors.accentSurface
             : mouseArea.pressed ? Colors.surfaceRaised
             : mouseArea.containsMouse ? Colors.surfaceVariant
             : "transparent"
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

        // ── Icon tile ─────────────────────────────────────────────
        Item {
            id: iconSlot
            width: appRow._iconTileSize
            height: appRow._iconTileSize
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Radius.listItem.background
                color: mouseArea.containsMouse ? Colors.surfaceRaised : Colors.surfaceVariant

                Behavior on color {
                    ColorAnimation { duration: Motion.listItem.hoverDuration }
                }
            }

            AppIcon {
                anchors.centerIn: parent
                iconName: appRow.iconName
                iconSize: Spacing.icon.large
                iconColor: Colors.fg
            }
        }

        // ── Name + description ────────────────────────────────────
        Column {
            id: textColumn
            spacing: Spacing.xxs
            anchors.verticalCenter: parent.verticalCenter
            // contentRow is anchored with left/right margins = paddingH,
            // so its width already excludes the horizontal padding.
            width: contentRow.width
                   - iconSlot.width - statusSlot.width
                   - Spacing.listItem.gap * 2

            ShellText {
                id: textColumnName
                text: appRow.appName
                role: ShellText.Role.BodyBold
                textColor: Colors.fg
                width: parent.width
                elide: Text.ElideRight
                clip: true
            }

            ShellText {
                text: appRow.description
                visible: appRow.description !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
                width: parent.width
                elide: Text.ElideRight
                clip: true
            }
        }

        // ── Status slot (spinner / hover chevron) ─────────────────
        Item {
            id: statusSlot
            width: Spacing.icon.medium
            height: Spacing.icon.medium
            anchors.verticalCenter: parent.verticalCenter

            // Launching spinner
            ShellIcon {
                anchors.centerIn: parent
                name: "progress_activity"
                iconSize: Spacing.icon.small
                iconColor: Colors.accent
                visible: appRow.launching
            }

            // Hover chevron (fades in)
            ShellIcon {
                anchors.centerIn: parent
                name: "chevron_right"
                iconSize: Spacing.icon.medium
                iconColor: Colors.accent
                visible: !appRow.launching
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
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: appRow.clicked()
    }
}
