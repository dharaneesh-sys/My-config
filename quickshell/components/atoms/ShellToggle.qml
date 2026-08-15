import QtQuick

import qs.tokens

Item {
    id: shellToggle

    // ═══════════════════════════════════════════════════════════════
    //  ShellToggle
    //
    //  On/off switch toggle.
    //  All dimensions from Spacing.toggle tokens.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property bool checked: false
    signal toggled()

    // ── Layout ─────────────────────────────────────────────────────
    width:  Spacing.toggle.width
    height: Spacing.toggle.height

    // ── Track ──────────────────────────────────────────────────────
    Rectangle {
        id: track
        anchors.fill: parent
        radius: Radius.toggle.track
        color: checked ? Colors.toggleActive : Colors.toggleTrack
        border.width: 0

        Behavior on color {
            ColorAnimation {
                duration: Motion.toggle.trackDuration
                easing.type: Motion.easing.standard
            }
        }
    }

    // ── Thumb ──────────────────────────────────────────────────────
    Rectangle {
        id: thumb
        width:  Spacing.toggle.thumbSize
        height: Spacing.toggle.thumbSize
        radius: Radius.toggle.thumb
        color: Colors.fg
        y: (parent.height - height) / 2
        x: checked
           ? parent.width - width - Spacing.toggle.trackGap
           : Spacing.toggle.trackGap

        Behavior on x {
            NumberAnimation {
                duration: Motion.toggle.thumbDuration
                easing.type: Motion.easing.standard
            }
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            shellToggle.checked = !shellToggle.checked
            shellToggle.toggled()
        }
    }
}
