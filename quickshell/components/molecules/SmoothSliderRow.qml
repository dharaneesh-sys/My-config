import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: smoothSliderRow

    // ═══════════════════════════════════════════════════════════════
    //  SmoothSliderRow
    //
    //  Horizontal row: [icon chip] [title] [SmoothSlider] [value text].
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

        // ── Icon chip ─────────────────────────────────────────────
        Item {
            id: iconChip
            width: Spacing.listItem.iconSize + Spacing.sm * 2    // 32
            height: width
            visible: smoothSliderRow.iconName !== ""
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Radius.listItem.background
                color: Colors.surface
            }

            ShellIcon {
                id: rowIcon
                anchors.centerIn: parent
                name: smoothSliderRow.iconName
                iconSize: Spacing.listItem.iconSize
                iconColor: (smoothSliderRow.value <= 0 || smoothSliderRow.iconName === "volume_off")
                           ? Colors.error
                           : (slider.hovered || slider.pressed ? Colors.accent : Colors.fgMuted)

                Behavior on iconColor {
                    ColorAnimation { duration: Motion.duration.fast }
                }
            }
        }

        // Title
        ShellText {
            id: rowTitle
            visible: smoothSliderRow.title !== ""
            text: smoothSliderRow.title
            role: ShellText.Role.Body
            textColor: Colors.fgMuted
            anchors.verticalCenter: parent.verticalCenter
            // Let the text keep its natural width. Binding `width` to
            // `implicitWidth` creates a QML layout loop because ShellText's
            // implicit width is derived from its width-constrained Text item.
            width: visible ? contentWidth + Spacing.sm : 0
        }

        // Slider
        SmoothSlider {
            id: slider
            anchors.verticalCenter: parent.verticalCenter
            // contentRow width already excludes paddingH (anchor margins)
            width: contentRow.width
                   - iconChip.width - rowTitle.width - valueLabel.implicitWidth
                   - (iconChip.visible ? Spacing.listItem.gap : 0)
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
