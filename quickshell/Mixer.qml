import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "Singletons"

/**
 * Mixer surface: header with DND / Keep-Awake chips and a row of three vertical
 * ink-faders wired to real hardware (volume, brightness via brightnessctl, mic
 * via Pipewire). Fills the lower body of the pill.
 */
PillSurface {
    id: root

    mTop: 13
    mLeft: 14
    mRight: 14
    mBottom: 12

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    property int focusIndex: -1
    readonly property int faderCount: faders.length
    readonly property var faders: [volFader, brightnessFader, micFader]
    readonly property bool surfaceHovered: hoverTracker.hovered

    /**
     * Tick centre of the focused fader, mapped into this mixer's root so the
     * bead glides as keyboard/hover focus moves across the row. Layout deps are
     * voided before mapToItem so the binding re-evaluates on resize (else stale).
     */
    readonly property point focusTickPoint: {
        void root.width;
        void root.height;
        void root.focusIndex;
        const i = Math.max(0, Math.min(faders.length - 1, root.focusIndex));
        const f = faders[i];
        if (!f)
            return Qt.point(0, 0);
        return f.mapToItem(root, f.tickCenter.x, f.tickCenter.y);
    }

    ameForm: "tick"
    amePoint: focusTickPoint

    /**
     * Pointer-driven fader targeting. MouseArea hover is flaky on this
     * layer-shell surface, so a non-blocking HoverHandler is the only hover
     * source. Its pointer x maps to a fader column and drives keyboard focus.
     */
    readonly property int hoverIndex: surfaceHovered && width > 0
        && hoverTracker.point.position.y >= faderRow.y
        ? Math.max(0, Math.min(faders.length - 1, Math.floor(hoverTracker.point.position.x / (width / faders.length))))
        : -1
    onHoverIndexChanged: if (hoverIndex >= 0) focusIndex = hoverIndex

    HoverHandler {
        id: hoverTracker
    }

    onActiveChanged: focusIndex = active ? 0 : -1

    /**
     * Nudge the focused fader by `deltaPct` percent. Returns true when a fader
     * handled the step.
     */
    function stepFocused(deltaPct) {
        if (focusIndex < 0)
            return false;
        faders[focusIndex].step(deltaPct);
        return true;
    }

    /**
     * Move keyboard focus across the fader row, wrapping at the ends. `dir` is +1
     * (right) or -1 (left); a fresh focus lands on the first or last fader.
     */
    function moveFocus(dir) {
        focusIndex = focusIndex < 0 ? (dir > 0 ? 0 : faders.length - 1)
                                    : (focusIndex + dir + faders.length) % faders.length;
    }

    Component.onCompleted: Devices.detect()

    PwObjectTracker {
        objects: [root.sink, root.source].filter(Boolean)
    }

    component IconChip: Rectangle {
        id: chip
        property string glyph: ""
        property bool on: false
        signal toggled()

        width: 26 * root.s
        height: 26 * root.s
        radius: 8 * root.s
        color: chip.on ? Theme.frameBg : "transparent"
        border.width: 1
        border.color: chip.on ? Theme.frameBorder : Theme.border

        GlyphIcon {
            anchors.centerIn: parent
            width: 15 * root.s
            height: 15 * root.s
            name: chip.glyph
            color: chip.on ? Theme.vermLit : Theme.iconDim
            stroke: 1.7
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.toggled()
        }
    }

    Item {
        id: header
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 24 * root.s

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8 * root.s
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "MIXER"
                color: Theme.cream
                font.family: Theme.fontJp
                font.weight: Font.Medium
                font.pixelSize: 16 * root.s
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "MIXER"
                color: Theme.subtle
                font.family: Theme.font
                font.pixelSize: 10 * root.s
                font.weight: Font.DemiBold
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1.6 * root.s
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6 * root.s
            IconChip {
                glyph: "dnd"
                on: Flags.dnd
                onToggled: Flags.dnd = !Flags.dnd
            }
            IconChip {
                glyph: "awake"
                on: Flags.keepAwake
                onToggled: Flags.keepAwake = !Flags.keepAwake
            }
        }
    }

    Rectangle {
        id: divider
        anchors.top: header.bottom
        anchors.topMargin: 9 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.hair
    }

    Row {
        id: faderRow
        anchors.top: divider.bottom
        anchors.topMargin: 10 * root.s
        anchors.left: parent.left
        anchors.right: parent.right
        height: 138 * root.s
        spacing: 0

        readonly property real colW: width / Math.max(1, root.faderCount)

        VFader {
            id: volFader
            width: faderRow.colW
            s: root.s
            icon: "speaker"
            focused: root.focusIndex === root.faderCount - 3
            value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
            valueLabel: Math.round((root.sink && root.sink.audio ? root.sink.audio.volume : 0) * 100) + "%"
            onMoved: (v) => { if (root.sink && root.sink.audio) root.sink.audio.volume = v; }
        }
        VFader {
            id: brightnessFader
            width: faderRow.colW
            s: root.s
            icon: "sun"
            focused: root.focusIndex === root.faderCount - 2
            value: pct / 100
            valueLabel: pct + "%"

            property int pct: 75
            property real pendingPct: -1

            onMoved: (v) => pct = Math.max(5, Math.min(100, Math.round(v * 100)))
            onCommitted: (v) => {
                pendingPct = Math.max(5, Math.min(100, Math.round(v * 100)));
                briCommit.restart();
            }

            Timer {
                id: briCommit
                interval: 160
                onTriggered: if (brightnessFader.pendingPct >= 0) {
                    Quickshell.execDetached(["brightnessctl", "set", brightnessFader.pendingPct + "%"]);
                    brightnessFader.pendingPct = -1;
                }
            }

            Process {
                id: brRead
                command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | sed 's/%//'"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: {
                        var v = parseInt(this.text.trim(), 10);
                        if (!isNaN(v) && v >= 0)
                            brightnessFader.pct = v;
                    }
                }
            }
        }
        VFader {
            id: micFader
            width: faderRow.colW
            s: root.s
            icon: (root.source && root.source.audio && root.source.audio.muted) ? "mic-off" : "mic"
            focused: root.focusIndex === root.faderCount - 1
            value: root.source && root.source.audio ? root.source.audio.volume : 0
            valueLabel: (root.source && root.source.audio && root.source.audio.muted)
                ? "off"
                : (Math.round((root.source && root.source.audio ? root.source.audio.volume : 0) * 100) + "%")
            onMoved: (v) => { if (root.source && root.source.audio) root.source.audio.volume = v; }

            MouseArea {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: 24 * root.s
                height: 22 * root.s
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (root.source && root.source.audio) root.source.audio.muted = !root.source.audio.muted; }
            }
        }
    }

    MouseArea {
        id: wheelArea
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        property real acc: 0
        onWheel: (event) => {
            acc += event.angleDelta.y / 120;
            const notches = Math.trunc(acc);
            if (notches !== 0 && root.stepFocused(notches * 5))
                acc -= notches;
            event.accepted = true;
        }
    }
}
