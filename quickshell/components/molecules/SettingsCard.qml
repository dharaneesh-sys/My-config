import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: settingsCard

    // ═══════════════════════════════════════════════════════════════
    //  SettingsCard
    //
    //  Rounded card container with header, body, and footer slot.
    //  Used to group related settings within a page.
    //
    //  Layout:
    //  ┌─────────────────────────────┐
    //  │  header (SectionHeader)     │
    //  │  body (Loader slot)         │
    //  │  footer (Loader slot)       │
    //  └─────────────────────────────┘
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string headerText: ""
    property alias bodyContent: bodySlot.sourceComponent
    property alias footerContent: footerSlot.sourceComponent

    // ── Layout ─────────────────────────────────────────────────────
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth
    implicitHeight: cardBg.height

    // ── Card background ────────────────────────────────────────────
    Rectangle {
        id: cardBg
        anchors {
            left: parent.left
            right: parent.right
        }
        height: headerItem.height
                + bodySlot.height
                + footerSlot.height
                + Spacing.card.padding * 2
                + (headerItem.visible && bodySlot.item ? Spacing.card.gap : 0)
                + (bodySlot.item && footerSlot.item ? Spacing.card.gap : 0)
        radius: Radius.card.background
        color: Colors.surfaceVariant
        border.width: Elevation.card.borderWidth
        border.color: Colors.borderStrong
        clip: true

        // Inset edge makes grouped settings feel machined and layered while
        // preserving an entirely opaque material stack.
        Rectangle {
            anchors { fill: parent; margins: 1 }
            radius: Math.max(0, parent.radius - 1)
            color: "transparent"
            border.width: 1
            border.color: Colors.fg
            opacity: 0.045
        }
    }

    // ── Content column ─────────────────────────────────────────────
    Column {
        id: contentCol
        anchors {
            left: cardBg.left
            right: cardBg.right
            top: cardBg.top
            margins: Spacing.card.padding
        }
        spacing: Spacing.card.gap

        // Header
        SectionHeader {
            id: headerItem
            visible: settingsCard.headerText !== ""
            text: settingsCard.headerText
            width: parent.width
        }

        // Body slot
        Loader {
            id: bodySlot
            width: parent.width
        }

        // Footer slot
        Loader {
            id: footerSlot
            width: parent.width
        }
    }
}
