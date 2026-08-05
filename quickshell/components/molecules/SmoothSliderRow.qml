import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: smoothSliderRow

    // ═══════════════════════════════════════════════════════════════
    //  SmoothSliderRow
    //
    //  Horizontal row: [icon] [title] [SmoothSlider] [value text].
    //  Same public API as SliderRow (iconName/title/from/to/value/
    //  valueText/moved) but composes SmoothSlider instead of
    //  ShellSlider — integer-pixel geometry + smooth catch-up for
    //  externally-driven values (e.g. 2s media position polls).
    // ═══════════════════════════════════════════════════════════════

    // ── Public API (mirrors SliderRow) ─────────────────────────────
    property string iconName: ""
    property string title: ""
    property real from: 0.0
    property real to: 1.0
    property real value: 0.0
    property string valueText: ""
    signal moved(real newValue)

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
            visible: smoothSliderRow.iconName !== ""
            name: smoothSliderRow.iconName
            iconSize: Spacing.listItem.iconSize
            iconColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
        }

        // Title
        ShellText {
            id: rowTitle
            visible: smoothSliderRow.title !== ""
            text: smoothSliderRow.title
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
            width: visible ? implicitWidth + Spacing.sm : 0
        }

        // Slider
        SmoothSlider {
            id: slider
            anchors.verticalCenter: parent.verticalCenter
            width: contentRow.width
                   - rowIcon.implicitWidth - rowTitle.width - valueLabel.implicitWidth
                   - Spacing.listItem.paddingH * 2
                   - (rowIcon.visible ? Spacing.listItem.gap : 0)
                   - (rowTitle.visible ? Spacing.listItem.gap : 0)
                   - (valueLabel.visible ? Spacing.listItem.gap : 0)

            from: smoothSliderRow.from
            to: smoothSliderRow.to
            value: smoothSliderRow.value

            onMoved: smoothSliderRow.moved(newValue)
        }

        // Value text
        ShellText {
            id: valueLabel
            visible: smoothSliderRow.valueText !== ""
            text: smoothSliderRow.valueText
            role: ShellText.Role.SliderValue
            textColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
