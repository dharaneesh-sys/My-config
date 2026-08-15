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

    // Key capture logic
    focus: true
    Keys.onPressed: (event) => {
        if (vm.editingKey !== "") {
            event.accepted = true;
            if (event.key === Qt.Key_Escape) {
                vm.stopEditing();
                return;
            }
            
            // Build modifier string
            var mods = [];
            if (event.modifiers & Qt.ControlModifier) mods.push("CTRL");
            if (event.modifiers & Qt.ShiftModifier) mods.push("SHIFT");
            if (event.modifiers & Qt.AltModifier) mods.push("ALT");
            if (event.modifiers & Qt.MetaModifier) mods.push("SUPER");
            
            // Get key text if printable, or fallback to key code name
            var keyStr = event.text.toUpperCase();
            if (keyStr === "") {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) keyStr = "ENTER";
                else if (event.key === Qt.Key_Space) keyStr = "SPACE";
                else if (event.key === Qt.Key_Tab) keyStr = "TAB";
                else keyStr = "KEY_" + event.key; // Fallback
            }
            
            if (mods.length > 0) {
                vm.setShortcut(vm.editingKey, mods.join(" + ") + " + " + keyStr);
            } else {
                vm.setShortcut(vm.editingKey, keyStr);
            }
            vm.stopEditing();
        }
    }
}
