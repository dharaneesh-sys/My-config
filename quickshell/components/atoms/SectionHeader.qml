import QtQuick

import qs.tokens

Item {
    id: sectionHeader

    // ═══════════════════════════════════════════════════════════════
    //  SectionHeader
    //
    //  Divider line + section label. Used to separate groups
    //  within panels (e.g. "Quick Settings" / "Volume").
    //  Zero logic — pure presentation.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string text: ""

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Math.max(dividerLine.height, label.implicitHeight)
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Divider line ───────────────────────────────────────────────
    Rectangle {
        id: dividerLine
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: 1
        color: Colors.divider
        visible: sectionHeader.text === ""
    }

    // ── Labelled section ───────────────────────────────────────────
    // When text is set, the divider splits around the label.

    Rectangle {
        id: leftDivider
        anchors {
            left: parent.left
            right: label.left
            rightMargin: Spacing.sm
            verticalCenter: parent.verticalCenter
        }
        height: 1
        color: Colors.divider
        visible: sectionHeader.text !== ""
    }

    Text {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        x: parent.width / 2 - implicitWidth / 2
        text: sectionHeader.text
        color: Colors.fgMuted
        font.family: Typography.overline.family
        font.pixelSize: Typography.overline.size
        font.weight: Typography.overline.weight
        font.letterSpacing: Typography.overline.tracking
        visible: sectionHeader.text !== ""
    }

    Rectangle {
        id: rightDivider
        anchors {
            left: label.right
            leftMargin: Spacing.sm
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        height: 1
        color: Colors.divider
        visible: sectionHeader.text !== ""
    }
}
