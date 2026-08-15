import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: sliderRow

    // ═══════════════════════════════════════════════════════════════
    //  SliderRow
    //
    //  Horizontal row: [icon] [title] [ShellSlider] [value text].
    //  Used for volume, brightness, etc.
    // ═══════════════════════════════════════════════════════════════

// ── Public API ─────────────────────────────────────────────────
    property string iconName: ""
    property string title: ""
    property real from: 0
    property real to: 100
    property real value: 0
    property string valueText: ""
    signal moved(real newValue)

    // ── Probe accessors (read-only, for M3 geometry harness) ───────
    readonly property real sliderWidth: slider.width
    readonly property real iconWidth: rowIcon.implicitWidth
    readonly property real titleWidth: rowTitle.width
    readonly property real valueWidth: valueLabel.implicitWidth

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.listItem.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Content ────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Spacing.listItem.paddingH
            right: parent.right
            rightMargin: Spacing.listItem.paddingH
        }
        spacing: Spacing.listItem.gap

        // Icon
        ShellIcon {
            id: rowIcon
            visible: sliderRow.iconName !== ""
            name: sliderRow.iconName
            iconSize: Spacing.listItem.iconSize
            iconColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
        }

        // Title
        ShellText {
            id: rowTitle
            visible: sliderRow.title !== ""
            text: sliderRow.title
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
            width: visible ? implicitWidth + Spacing.sm : 0
        }

        // Slider
        ShellSlider {
            id: slider
            anchors.verticalCenter: parent.verticalCenter
            // contentRow width already excludes paddingH (anchor margins)
            width: contentRow.width
                   - rowIcon.implicitWidth - rowTitle.width - valueLabel.implicitWidth
                   - (rowIcon.visible ? Spacing.listItem.gap : 0)
                   - (rowTitle.visible ? Spacing.listItem.gap : 0)
                   - (valueLabel.visible ? Spacing.listItem.gap : 0)

            from: sliderRow.from
            to: sliderRow.to
            value: sliderRow.value

            onMoved: sliderRow.moved(newValue)
        }

        // Value text
        ShellText {
            id: valueLabel
            visible: sliderRow.valueText !== ""
            text: sliderRow.valueText
            role: ShellText.Role.SliderValue
            textColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
