import QtQuick

import qs.tokens
import qs.motion

Item {
    id: smoothSlider

    // ═══════════════════════════════════════════════════════════════
    //  SmoothSlider
    //
    //  Horizontal slider with optional label.
    //  Same public API as ShellSlider (from/to/value/label/moved) so it
    //  slots into SliderRow-style rows unchanged, but:
    //
    //  • Integer-pixel geometry — fill width and handle position are
    //    rounded to whole pixels (Math.round) to avoid the
    //    fractional-pixel shimmer of sub-pixel rendering.
    //  • Smooth catch-up — when `value` changes externally (e.g. a
    //    2s media position poll), the displayed value eases toward the
    //    new target instead of snapping, unless the user is dragging.
    //    While dragging, the value tracks the pointer exactly.
    //
    //  All dimensions from Spacing.slider tokens.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API (mirrors ShellSlider) ────────────────────────────
    property real from: 0.0
    property real to: 1.0
    property real value: 0.0
    property string label: ""
    
    readonly property bool hovered: sliderMouseArea.containsMouse
    readonly property bool pressed: sliderMouseArea.pressed
    
    signal moved(real newValue)

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: label !== "" ? Spacing.slider.height + Spacing.slider.labelGap + labelItem.implicitHeight
                                 : Spacing.slider.height
    implicitWidth:  Spacing.panel.maxWidth - Spacing.panel.padding * 2

    // ── Internal ───────────────────────────────────────────────────
    // Value actually rendered. Eases toward `value` unless dragging.
    property real _displayValue: 0.0
    property bool _dragging: false
    // Suppresses the spurious onValueChanged that fires during component
    // construction (instance `value:` assignment transitions 0→initial).
    property bool _initialized: false

    readonly property real _range: Math.max(to - from, 0.0001)
    readonly property real _normalized: Math.max(0, Math.min(1, (_displayValue - from) / _range))

    // Integer-pixel fill width (no fractional shimmer)
    readonly property real _fillWidth: Math.max(0, Math.round(trackBg.width * _normalized))

    // Smooth catch-up for external value changes (e.g. media polls).
    // Duration honors MotionConfig: 0 when animations are disabled, so
    // the displayed value snaps instantly (and harnesses stay deterministic).
    onValueChanged: {
        if (!_initialized) {
            _displayValue = value
            return
        }
        if (_dragging) {
            _displayValue = value
            return
        }
        var dur = MotionConfig.duration(Motion.duration.slow)
        if (dur === 0) {
            _displayValue = value
            return
        }
        _catchUp.stop()
        _catchUp.from = _displayValue
        _catchUp.to = value
        _catchUp.duration = dur
        _catchUp.start()
    }

    NumberAnimation {
        id: _catchUp
        target: smoothSlider
        property: "_displayValue"
        duration: Motion.duration.slow
        easing.type: Easing.OutCubic
    }

    // Sync the displayed value with the bound value on creation.
    // onValueChanged fires during construction with the instance value
    // (transition 0→initial) but we defer animating until fully built.
    Component.onCompleted: {
        _displayValue = value
        _initialized = true
    }

    // ── Label ──────────────────────────────────────────────────────
    Text {
        id: labelItem
        anchors {
            top: parent.top
            left: parent.left
        }
        visible: smoothSlider.label !== ""
        text: smoothSlider.label
        color: Colors.fgMuted
        font.family: Typography.caption.family
        font.pixelSize: Typography.caption.size
        font.weight: Typography.caption.weight
    }

    // ── Track area ─────────────────────────────────────────────────
    Item {
        id: trackArea
        anchors {
            top: smoothSlider.label !== "" && labelItem.visible ? labelItem.bottom : parent.top
            topMargin: smoothSlider.label !== "" && labelItem.visible ? Spacing.slider.labelGap : 0
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

        // Track fill — width rounded to whole pixels
        Rectangle {
            id: trackFill
            anchors {
                left: trackBg.left
                verticalCenter: trackBg.verticalCenter
            }
            width: smoothSlider._fillWidth
            height: trackBg.height
            radius: height / 2
            color: sliderMouseArea.pressed || sliderMouseArea.containsMouse ? Colors.accent : Colors.sliderFill
        }

        // Handle — positioned at the same rounded fill edge, clamped
        // inside the track so it never hangs over the edges.
        Rectangle {
            id: handle
            width: Spacing.slider.handleSize
            height: Spacing.slider.handleSize
            radius: width / 2
            color: Colors.fg
            anchors.verticalCenter: trackBg.verticalCenter
            x: Math.min(
                   Math.max(trackBg.x, trackBg.x + smoothSlider._fillWidth - width / 2),
                   trackBg.x + trackBg.width - width / 2
               )
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: sliderMouseArea
        anchors.fill: trackArea
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function _updateValue(mouseX) {
            var clamped = Math.max(0, Math.min(width, mouseX))
            var ratio = clamped / width
            var newValue = smoothSlider.from + ratio * smoothSlider._range
            smoothSlider._displayValue = newValue
            smoothSlider.value = newValue
            smoothSlider.moved(newValue)
        }

        onPressed: {
            smoothSlider._dragging = true
            _catchUp.stop()
            _updateValue(mouse.x)
        }
        onPositionChanged: if (pressed) _updateValue(mouse.x)
        onReleased: {
            smoothSlider._dragging = false
            _updateValue(mouse.x)
        }
    }
}
