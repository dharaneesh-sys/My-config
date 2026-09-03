import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: quickToggle

    // ═══════════════════════════════════════════════════════════════
    //  QuickToggle
    //
    //  Square quick-settings tile (e.g. WiFi, Bluetooth, DND).
    //
    //  • icon chip + title + optional subtitle
    //  • active state — accent-tinted chip, accent border, filled icon
    //  • hover lift + press scale
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string iconName: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    signal clicked()

    // ── Layout ─────────────────────────────────────────────────────
    width:  Spacing.quickTile.size
    height: Spacing.quickTile.size

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: tileBg
        anchors.fill: parent
        radius: Radius.quickTile.background
        // Filled selection makes the state legible at a glance. Keeping the
        // resting tiles quiet avoids the outlined-dashboard look.
        color: active ? Colors.accent
                      : mouseArea.containsMouse ? Colors.surfaceRaised : Colors.surfaceVariant
        border.width: Elevation.quickTile.borderWidth
        border.color: active ? Colors.accentHover
                    : mouseArea.containsMouse ? Colors.borderStrong
                    : Colors.border

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        Behavior on border.color {
            ColorAnimation { duration: Motion.toggle.trackDuration }
        }
    }

    // ── Content ────────────────────────────────────────────────────
    Column {
        id: content
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        // 28 + 2 + ~15 (title) + 2 + ~14 (subtitle) ≈ 61px — fits the
        // 64px tile. A larger chip would overflow into the grid gap.
        spacing: Spacing.xxs

        // ── Icon chip ─────────────────────────────────────────────
        Item {
            id: iconChip
            anchors.horizontalCenter: parent.horizontalCenter
            width: Spacing.quickTile.iconSize + Spacing.sm       // 28
            height: width
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: Radius.quickTile.background
                color: active ? Colors.fgOnAccent
                              : mouseArea.containsMouse ? Colors.surface : Colors.surfaceRaised

                Behavior on color {
                    ColorAnimation { duration: Motion.toggle.trackDuration }
                }
            }

            ShellIcon {
                anchors.centerIn: parent
                name: quickToggle.iconName
                iconSize: Spacing.quickTile.iconSize
                iconColor: active ? Colors.accent : Colors.fg
                filled: active
                font.weight: active ? Font.Bold : Font.Normal

                Behavior on iconColor {
                    ColorAnimation { duration: Motion.toggle.trackDuration }
                }
            }
        }

        // Title
        ShellText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: quickToggle.title
            role: ShellText.Role.CaptionMedium
            textColor: active ? Colors.fgOnAccent : Colors.fg
        }

        // Subtitle (optional)
        ShellText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: quickToggle.subtitle
            visible: quickToggle.subtitle !== ""
            role: ShellText.Role.Overline
            // Use an opaque accent. Transparent accent tokens depend on
            // compositor blending and can resolve to a different hue.
            textColor: active ? Colors.fgOnAccent : Colors.fgMuted
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: quickToggle.clicked()
    }

    // ── Motion ─────────────────────────────────────────────────────
    y: mouseArea.containsMouse && !mouseArea.pressed ? -2 : 0
    scale: mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? 1.0 : 1.0)

    Behavior on y {
        NumberAnimation { duration: Motion.duration.fast; easing.type: Motion.easing.decelerate }
    }

    Behavior on scale {
        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
    }
}
