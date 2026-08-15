import QtQuick

import qs.tokens

Item {
    id: shellSlider

    // ═══════════════════════════════════════════════════════════════
    //  ShellSlider
    //
    //  Horizontal slider with optional label.
    //  All dimensions from Spacing.slider tokens.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property real from:   0.0
    property real to:     1.0
    property real value:  0.0
    property string label: ""
    signal moved(real newValue)

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: label !== "" ? Spacing.slider.height + Spacing.slider.labelGap + labelItem.implicitHeight
                                 : Spacing.slider.height
    implicitWidth:  Spacing.panel.maxWidth - Spacing.panel.padding * 2

    // ── Internal ───────────────────────────────────────────────────
    readonly property real _range: Math.max(to - from, 0.0001)
    readonly property real _normalized: Math.max(0, Math.min(1, (value - from) / _range))

    // ── Label ──────────────────────────────────────────────────────
    Text {
        id: labelItem
        anchors {
            top: parent.top
            left: parent.left
        }
        visible: shellSlider.label !== ""
        text: shellSlider.label
        color: Colors.fgMuted
        font.family: Typography.caption.family
        font.pixelSize: Typography.caption.size
        font.weight: Typography.caption.weight
    }

    // ── Track area ─────────────────────────────────────────────────
    Item {
        id: trackArea
        anchors {
            top: shellSlider.label !== "" && labelItem.visible ? labelItem.bottom : parent.top
            topMargin: shellSlider.label !== "" && labelItem.visible ? Spacing.slider.labelGap : 0
            left: parent.left
            right: parent.right
        }
        height: Spacing.slider.height

        // Track background
        Rectangle {
            id: trackBg
            anchors.centerIn: parent
            width: parent.width
            height: Spacing.slider.trackHeight
            radius: height / 2
            color: Colors.sliderTrack
        }

        // Track fill
        Rectangle {
            id: trackFill
            anchors {
                left: trackBg.left
                verticalCenter: trackBg.verticalCenter
            }
            width: trackBg.width * _normalized
            height: trackBg.height
            radius: height / 2
            color: Colors.sliderFill

            Behavior on width {
                NumberAnimation { duration: Motion.slider.fillDuration }
            }
        }

        // Handle
        Rectangle {
            id: handle
            width: Spacing.slider.handleSize
            height: Spacing.slider.handleSize
            radius: width / 2
            color: Colors.fg
            anchors.verticalCenter: trackBg.verticalCenter
            x: trackBg.x + trackBg.width * _normalized - width / 2

            Behavior on x {
                NumberAnimation { duration: Motion.slider.handleDuration }
            }
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        anchors.fill: trackArea
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function _updateValue(mouseX) {
            var clamped = Math.max(0, Math.min(width, mouseX))
            var ratio = clamped / width
            var newValue = from + ratio * _range
            value = newValue
            shellSlider.moved(newValue)
        }

        onPressed:  _updateValue(mouse.x)
        onPositionChanged: if (pressed) _updateValue(mouse.x)
        onReleased: _updateValue(mouse.x)
    }
}
