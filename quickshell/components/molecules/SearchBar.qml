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
    // Delete-key shortcut for list panels that support row removal
    // (clipboard). Emitted when Delete is pressed inside the TextInput.
    signal navigateDelete()

    // Give the input keyboard focus (called when a panel opens so the
    // user can type / navigate immediately without clicking first).
    function focusInput() {
        inputField.forceActiveFocus()
    }

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.input.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Background ─────────────────────────────────────────────────
    // Focus ring — 2px accent at 0.4 when focused, guides typing
    Rectangle {
        id: focusRing
        anchors.fill: fieldBg
        anchors.margins: -2
        radius: fieldBg.radius + 2
        color: "transparent"
        border.width: 2
        border.color: Colors.accent
        opacity: inputField.activeFocus ? 0.4 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Motion.duration.fast; easing.type: Motion.easing.standard } }
    }

    Rectangle {
        id: fieldBg
        anchors.fill: parent
        radius: Radius.input.background
        color: Colors.inputBg
        border.width: Elevation.button.borderWidth
        border.color: inputField.activeFocus ? Colors.accent
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

            // Delete removes the selected row in list panels (clipboard).
            // Intercepts the TextInput's forward-delete so the panel can
            // act on it instead.
            Keys.onDeletePressed: (event) => {
                searchBar.navigateDelete()
                event.accepted = true
            }
        }

        // Clear button — lightweight circular cross with fade/scale
        // entrance, circular hover background, and a generous 28px
        // hit target (vs the old 16px ShellButton) that keeps the
        // input's reserved width stable so the field never reflows.
        Item {
            id: clearBtn
            readonly property bool _show: inputField.text !== ""
            width: Spacing.icon.medium + Spacing.xs * 2      // 28
            height: width
            anchors.verticalCenter: parent.verticalCenter

            opacity: _show ? 1.0 : 0.0
            scale: _show ? 1.0 : 0.6
            enabled: _show
            visible: opacity > 0.01

            Behavior on opacity {
                NumberAnimation { duration: Motion.duration.fast }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Motion.duration.fast
                    easing.type: Motion.easing.standard
                }
            }

            // Circular hover / press background
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: clearMouse.pressed ? Colors.surfaceRaised
                     : clearMouse.containsMouse ? Colors.surfaceVariant
                     : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Motion.button.hoverDuration }
                }
            }

            ShellIcon {
                anchors.centerIn: parent
                name: "close"
                iconSize: Spacing.icon.small
                iconColor: clearMouse.containsMouse ? Colors.fg : Colors.fgMuted

                Behavior on iconColor {
                    ColorAnimation { duration: Motion.button.hoverDuration }
                }
            }

            MouseArea {
                id: clearMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    inputField.text = ""
                    inputField.forceActiveFocus()
                }
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
