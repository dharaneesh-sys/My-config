import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms
import qs.state

Item {
    id: mediaPlayer

    // ═══════════════════════════════════════════════════════════════
    //  MediaPlayer — PURE VIEW
    //
    //  Media player panel. Triggered by Super+M.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    MediaPlayerViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.mediaPlayerWidth
    // Reference-style compact now-playing strip.
    implicitHeight: 64

    // ── Keyboard navigation ──────────────────────────────────────────────────
    property int currentIndex: -1
    // Compact seven-day strip centred on the real local date. Reading
    // ClockState.date keeps the binding current across midnight.
    readonly property var calendarDays: _calendarDays()

    function _calendarDays() {
        var dateDependency = ClockState.date
        var today = new Date()
        var values = []
        for (var offset = -3; offset <= 3; offset++) {
            var day = new Date(today.getFullYear(), today.getMonth(), today.getDate() + offset)
            values.push({
                label: String(day.getDate()),
                weekday: ["S", "M", "T", "W", "T", "F", "S"][day.getDay()],
                isToday: offset === 0
            })
        }
        return values
    }

    focus: true

    Keys.onEscapePressed: ExpansionManager.requestCollapse()

    Connections {
        target: vm.playersModel
        function onCountChanged() { mediaPlayer.currentIndex = -1 }
    }

    Keys.onDownPressed: {
        if (vm.playersModel.count > 0)
            mediaPlayer.currentIndex = Math.min(mediaPlayer.currentIndex + 1,
                vm.playersModel.count - 1)
        event.accepted = true
    }
    Keys.onUpPressed: {
        mediaPlayer.currentIndex = Math.max(mediaPlayer.currentIndex - 1, -1)
        event.accepted = true
    }
    Keys.onReturnPressed: {
        var idx = mediaPlayer.currentIndex >= 0
            ? mediaPlayer.currentIndex : 0
        if (vm.playersModel.count > 0) {
            var item = vm.playersModel.get(idx)
            vm.selectPlayer(item.name)
        }
    }

    Row {
        anchors.fill: parent
        spacing: Spacing.sm

        Rectangle {
            id: artworkFrame
            width: 48
            height: 48
            radius: Radius.listItem.background
            color: Colors.surface
            clip: true

            Image {
                anchors.fill: parent
                source: vm.artwork
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: vm.hasMedia && status === Image.Ready
            }

            ShellIcon {
                anchors.centerIn: parent
                visible: !vm.hasMedia
                name: "music_note"
                iconSize: Spacing.icon.medium
                iconColor: Colors.fgMuted
            }
        }

        Column {
            width: 116
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1

            ShellText {
                width: parent.width
                text: vm.hasMedia ? vm.title : "No media playing"
                role: ShellText.Role.CaptionMedium
                textColor: Colors.fg
                elide: Text.ElideRight
            }

            ShellText {
                width: parent.width
                text: vm.hasMedia ? vm.artist : ""
                visible: text !== ""
                role: ShellText.Role.Overline
                textColor: Colors.fgMuted
                elide: Text.ElideRight
            }

            Row {
                spacing: 2
                height: 18
                visible: vm.hasMedia

                TransportButton { iconName: "skip_previous"; onClicked: vm.previous() }
                TransportButton { iconName: vm.playing ? "pause" : "play_arrow"; active: vm.playing; onClicked: vm.playPause() }
                TransportButton { iconName: "skip_next"; onClicked: vm.next() }
            }
        }

        Item { width: 1; height: 1 }

        Column {
            width: 104
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            ShellText {
                width: parent.width
                text: ClockState.time
                role: ShellText.Role.CaptionMedium
                textColor: Colors.fg
                horizontalAlignment: Text.AlignHCenter
            }

            Column {
                width: parent.width
                spacing: 0

                Row {
                    width: parent.width
                    spacing: 2
                    Repeater {
                        model: mediaPlayer.calendarDays
                        delegate: ShellText {
                            required property var modelData
                            width: (parent.width - 12) / 7
                            text: modelData.weekday
                            role: ShellText.Role.Overline
                            textColor: Colors.fgDisabled
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: 2
                    Repeater {
                        model: mediaPlayer.calendarDays
                        delegate: ShellText {
                            required property var modelData
                            width: (parent.width - 12) / 7
                            text: modelData.label
                            role: ShellText.Role.Overline
                            textColor: modelData.isToday ? Colors.accent : Colors.fgDisabled
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    component TransportButton : Item {
        property string iconName: ""
        property bool active: false
        signal clicked()

        width: 16
        height: 16

        ShellIcon {
            anchors.centerIn: parent
            name: parent.iconName
            iconSize: 14
            iconColor: parent.active ? Colors.accent : Colors.fgMuted
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
