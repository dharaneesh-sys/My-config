import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.settings
import qs.viewmodels

Item {
    id: keybindsPage

    // ═══════════════════════════════════════════════════════════════
    //  KeybindsPage
    //
    //  Keybinds settings: view and (placeholder) edit keyboard
    //  shortcuts for shell panels and the settings window.
    //  Composed from molecules only. All controls bind to
    //  SettingsStore via KeybindsSettingsViewModel.
    //  Pure view — no logic, no State access.
    //
    //  Editing is placeholder-only: the Edit button toggles
    //  an editing indicator on the row but does not capture
    //  keys yet. When key capture is implemented, the
    //  ViewModel setter functions will be wired.
    // ═══════════════════════════════════════════════════════════════

    KeybindsSettingsViewModel { id: vm }

    // ── Layout ─────────────────────────────────────────────────────
    anchors.fill: parent

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width
        contentHeight: contentColumn.height + Spacing.settings.padding * 2
        clip: true

        Column {
            id: contentColumn
            x: Spacing.settings.padding
            y: Spacing.settings.padding
            width: flickable.width - Spacing.settings.padding * 2
            spacing: Spacing.settings.pageGap

            // ── Page header ────────────────────────────────────
            SettingsPageHeader {
                width: parent.width
                title: "Keybinds"
                subtitle: "Keyboard shortcuts for shell panels"
            }

            // ── Shell shortcuts ────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Shell Shortcuts"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        Repeater {
                            model: vm.keybindEntries
                            delegate: Item {
                                width: parent.width
                                height: keybindRow.height

                                SettingRow {
                                    id: keybindRow
                                    width: parent.width
                                    iconName: modelData.icon
                                    title: modelData.title
                                    subtitle: vm.editingKey === modelData.key
                                              ? "Press new shortcut…"
                                              : vm.shortcut(modelData.key)
                                    trailing: Component {
                                        ShellButton {
                                            text: vm.editingKey === modelData.key
                                                  ? "Cancel"
                                                  : "Edit"
                                            iconName: vm.editingKey === modelData.key
                                                      ? "close"
                                                      : "edit"
                                            onClicked: {
                                                if (vm.editingKey === modelData.key)
                                                    vm.stopEditing()
                                                else
                                                    vm.startEditing(modelData.key)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Info card ──────────────────────────────────────
            SettingsCard {
                width: parent.width
                headerText: "Note"
                bodyContent: Component {
                    Column {
                        spacing: Spacing.xs
                        width: parent ? parent.width : 0

                        ShellText {
                            width: parent.width
                            text: "Keybind changes are applied immediately via hyprctl."
                            role: ShellText.Role.Caption
                            textColor: Colors.fgMuted
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    // ── Modal overlay for key capture ────────────────────────────
    // Dims background and captures all key input when editing.
    // Blocks clicks to underlying rows and shows explicit prompt.
    Rectangle {
        id: keyCaptureOverlay
        anchors.fill: parent
        color: "#00000088"
        visible: vm.editingKey !== ""
        z: 10
        // Block clicks to underlying UI
        MouseArea {
            anchors.fill: parent
            onClicked: vm.stopEditing()
        }
        // Centered prompt
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width * 0.8, 420)
            height: 120
            radius: 16
            color: Colors.surface
            border.width: 1
            border.color: Colors.accent
            Column {
                anchors.centerIn: parent
                spacing: 8
                ShellText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Press new shortcut"
                    role: ShellText.Role.Title
                    textColor: Colors.fg
                }
                ShellText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: vm.editingKey !== "" ? vm.shortcut(vm.editingKey) + " → press keys" : ""
                    role: ShellText.Role.Caption
                    textColor: Colors.fgMuted
                }
                ShellText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Esc to cancel"
                    role: ShellText.Role.Overline
                    textColor: Colors.fgDisabled
                }
            }
        }
        // Ensure overlay can capture keys
        focus: visible
        Keys.onPressed: (event) => {
            // Forward to same handler as below
            if (event.key === Qt.Key_Escape) {
                vm.stopEditing()
                event.accepted = true
                return
            }
            var mods = []
            if (event.modifiers & Qt.ControlModifier) mods.push("CTRL")
            if (event.modifiers & Qt.ShiftModifier) mods.push("SHIFT")
            if (event.modifiers & Qt.AltModifier) mods.push("ALT")
            if (event.modifiers & Qt.MetaModifier) mods.push("SUPER")
            var keyStr = event.text.toUpperCase()
            if (keyStr === "") {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) keyStr = "ENTER"
                else if (event.key === Qt.Key_Space) keyStr = "SPACE"
                else if (event.key === Qt.Key_Tab) keyStr = "TAB"
                else keyStr = "KEY_" + event.key
            }
            if (mods.length > 0) vm.setShortcut(vm.editingKey, mods.join(" + ") + " + " + keyStr)
            else vm.setShortcut(vm.editingKey, keyStr)
            vm.stopEditing()
            event.accepted = true
        }
    }

    // Focus is handled by overlay when editing; page focus is passive
    focus: false
}
