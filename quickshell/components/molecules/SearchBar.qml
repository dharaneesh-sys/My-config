import QtQuick

import qs.state
import qs.tokens
import qs.components.atoms

Item {
    id: searchBar

    // ═══════════════════════════════════════════════════════════════
    //  SearchBar
    //
    //  Reusable search field with:
    //    • Leading search icon
    //    • Text input with placeholder
    //    • Clear button (visible when text is non-empty)
    //    • Focus state (border highlight)
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string placeholder: "Search…"
    // The alias auto-generates queryChanged() — declaring it explicitly
    // is a duplicate signal and makes the whole type fail to load.
    property alias query: inputField.text
    signal accepted()
    // Result-list navigation: emitted when Up/Down is pressed inside the
    // TextInput. Handled here (not on SearchBar) because the focused
    // TextInput consumes arrow keys before they can reach the parent.
    signal navigateUp()
    signal navigateDown()

    // Give the input keyboard focus (called when a panel opens so the
    // user can type / navigate immediately without clicking first).
    function focusInput() {
        inputField.forceActiveFocus()
    }

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.input.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: fieldBg
        anchors.fill: parent
        radius: Radius.input.background
        color: Colors.inputBg
        border.width: Elevation.button.borderWidth
        border.color: inputField.activeFocus ? Colors.inputBorderFocus
                                             : Colors.inputBorder

        Behavior on border.color {
            ColorAnimation { duration: Motion.button.focusDuration }
        }
    }

    // ── Content ────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Spacing.input.paddingH
            right: parent.right
            rightMargin: Spacing.input.paddingH
        }
        spacing: Spacing.input.iconGap

        // Search icon
        ShellIcon {
            id: searchIcon
            name: "search"
            iconSize: Spacing.icon.small
            iconColor: inputField.activeFocus ? Colors.accent : Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
        }

        // Text input
        TextInput {
            id: inputField
            width: contentRow.width
                   - searchIcon.width
                   - clearBtn.width
                   - Spacing.input.iconGap * 2
            height: fieldBg.height
            color: Colors.fg
            font.family: Typography.body.family
            font.pixelSize: Typography.body.size
            font.weight: Typography.body.weight
            verticalAlignment: Text.AlignVCenter
            clip: true

            onAccepted: searchBar.accepted()

            // Escape clears the query and collapses the panel. The TextInput
            // has active focus while typing, so this handler takes precedence
            // over the panel-surface-level Escape handler.
            Keys.onEscapePressed: {
                text = ""
                ExpansionManager.requestCollapse()
            }

            // Up/Down steer the launcher's result list. accepted=true stops
            // the TextInput from moving its own cursor with these keys.
            Keys.onUpPressed: (event) => {
                searchBar.navigateUp()
                event.accepted = true
            }
            Keys.onDownPressed: (event) => {
                searchBar.navigateDown()
                event.accepted = true
            }
        }

        // Clear button
        ShellButton {
            id: clearBtn
            iconName: "close"
            visible: inputField.text !== ""
            implicitHeight: Spacing.icon.small
            implicitWidth: Spacing.icon.small

            onClicked: {
                inputField.text = ""
                inputField.forceActiveFocus()
            }
        }
    }

    // ── Placeholder text ───────────────────────────────────────────
    Text {
        anchors {
            left: contentRow.left
            leftMargin: searchIcon.width + Spacing.input.iconGap
            verticalCenter: parent.verticalCenter
        }
        text: searchBar.placeholder
        color: Colors.fgDisabled
        font.family: Typography.body.family
        font.pixelSize: Typography.body.size
        font.weight: Typography.body.weight
        visible: !inputField.text && !inputField.activeFocus
    }

    // ── Focus on click ─────────────────────────────────────────────
    // accepted=true stops the press from propagating to the input-catch
    // MouseArea underneath the panel, which previously collapsed the
    // panel the instant the user clicked the search bar. forceActiveFocus
    // still hands keyboard focus to the input so typing works.
    MouseArea {
        anchors.fill: parent
        // Input and clear button stay above the background focus catcher.
        z: -1
        onPressed: (mouse) => {
            inputField.forceActiveFocus()
            mouse.accepted = true
        }
    }
}
