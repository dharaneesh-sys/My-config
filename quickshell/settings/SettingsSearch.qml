import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: searchField

    // ═══════════════════════════════════════════════════════════════
    //  SettingsSearch
    //
    //  Search field for the settings window.
    //  Phase 8A: exists but does not filter.
    //  The query is exposed for future filtering.
    // ═══════════════════════════════════════════════════════════════

    // ── Query (exposed for future filtering) ───────────────────────
    property alias query: searchInput.text

    // ── Layout ─────────────────────────────────────────────────────
    height: Spacing.input.height

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        radius: Radius.input.background
        color: Colors.inputBg
        border {
            width: searchInput.activeFocus ? 1 : 0
            color: Colors.inputBorderFocus
        }

        Behavior on border.width {
            NumberAnimation { duration: Motion.duration.fast }
        }
    }

    // ── Search icon ────────────────────────────────────────────────
    ShellIcon {
        id: searchIcon
        anchors {
            left: parent.left
            leftMargin: Spacing.input.paddingH
            verticalCenter: parent.verticalCenter
        }
        name: "search"
        iconSize: Spacing.icon.small
        iconColor: Colors.fgMuted
    }

    // ── Text input ─────────────────────────────────────────────────
    TextInput {
        id: searchInput
        anchors {
            left: searchIcon.right
            leftMargin: Spacing.input.iconGap
            right: parent.right
            rightMargin: Spacing.input.paddingH
            verticalCenter: parent.verticalCenter
        }
        color: Colors.fg
        font {
            family: Typography.body.family
            pixelSize: Typography.body.size
            weight: Typography.body.weight
        }
        verticalAlignment: Text.AlignVCenter

        // Placeholder
        Text {
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            text: "Search settings…"
            color: Colors.fgMuted
            font {
                family: Typography.body.family
                pixelSize: Typography.body.size
            }
            visible: !searchInput.text && !searchInput.activeFocus
        }
    }
}
