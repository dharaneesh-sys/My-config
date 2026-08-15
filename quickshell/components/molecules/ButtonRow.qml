import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: buttonRow

    // ═══════════════════════════════════════════════════════════════
    //  ButtonRow
    //
    //  Horizontal layout of equal-sized buttons.
    //  Buttons are sized to fill the row evenly.
    //  Reusable for power menus, confirmation dialogs, etc.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property var buttons: []   // [{text, iconName, onClicked, active, disabled}]
    property int spacing: Spacing.button.gap

    signal buttonClicked(int index)

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.button.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Row of buttons ─────────────────────────────────────────────
    Row {
        id: buttonRowLayout
        anchors.fill: parent
        spacing: buttonRow.spacing

        Repeater {
            model: buttonRow.buttons

            ShellButton {
                id: btn
                required property var modelData
                required property int index

                text: modelData.text || ""
                iconName: modelData.iconName || ""
                active: modelData.active || false
                disabled: modelData.disabled || false
                height: buttonRow.height
                width: (buttonRowLayout.width - (buttonRow.buttons.length - 1) * buttonRow.spacing)
                       / Math.max(buttonRow.buttons.length, 1)

                onClicked: buttonRow.buttonClicked(index)
            }
        }
    }
}
