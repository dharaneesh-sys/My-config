import QtQuick

import qs.tokens

Item {
    id: shellButton

    // ═══════════════════════════════════════════════════════════════
    //  ShellButton
    //
    //  Clickable button with text and/or icon.
    //  Supports: hover, press, active, toggled states.
    //  All dimensions from token system.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string text: ""
    property string iconName: ""
    signal clicked()
    property bool active: false       // persistent active state (e.g. selected tab)
    property bool toggled: false      // toggle state (e.g. on/off)
    // Opt in when a panel action should read as a full-width row instead of
    // a compact toolbar button.
    property bool fillWidth: false

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.button.height
    implicitWidth:  contentRow.width + Spacing.button.paddingH * 2

    // ── Disabled state ─────────────────────────────────────────────
    property bool disabled: false
    opacity: disabled ? Motion.opacity.disabled : Motion.opacity.visible

    Behavior on opacity {
        NumberAnimation { duration: Motion.button.focusDuration }
    }

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: buttonBg
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        height: parent.height
        width: shellButton.fillWidth ? parent.width
                                     : contentRow.width + Spacing.button.paddingH * 2
        radius: Radius.button.background
        color: mouseArea.pressed ? (active ? Colors.accentPressed : Colors.surfaceVariant)
             : active ? Colors.accent
             : mouseArea.containsMouse ? Colors.surfaceRaised : Colors.surfaceVariant
        border.width: Elevation.button.borderWidth
        border.color: active ? Colors.accentHover
                             : mouseArea.containsMouse ? Colors.borderStrong : Colors.border

        Behavior on color {
            ColorAnimation { duration: Motion.button.hoverDuration; easing.type: Motion.easing.standard }
        }
        Behavior on border.color {
            ColorAnimation { duration: Motion.button.hoverDuration; easing.type: Motion.easing.standard }
        }
    }

    // ── Content ────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors.centerIn: buttonBg
        spacing: shellButton.iconName !== "" && shellButton.text !== ""
                 ? Spacing.button.gap
                 : 0

        // Icon
        Text {
            visible: shellButton.iconName !== ""
            text: shellButton.iconName
            color: active ? Colors.fgOnAccent : Colors.fg
            font.family: Typography.families.icons
            font.pixelSize: Spacing.button.iconSize
            font.weight: Font.Normal
            verticalAlignment: Text.AlignVCenter
        }

        // Label
        Text {
            visible: shellButton.text !== ""
            text: shellButton.text
            color: active ? Colors.fgOnAccent : Colors.fg
            font.family: Typography.button.family
            font.pixelSize: Typography.button.size
            font.weight: Typography.button.weight
            verticalAlignment: Text.AlignVCenter
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: if (!disabled) shellButton.clicked()
    }

    // Position is deliberately fixed. A panel may animate its own width when
    // opening; centring or lifting a button inside that changing width makes
    // action controls visibly drift. Button feedback is colour-only.
}
