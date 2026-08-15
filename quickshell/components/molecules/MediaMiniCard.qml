import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: mediaMiniCard

    // ═══════════════════════════════════════════════════════════════
    //  MediaMiniCard
    //
    //  Compact media player card.
    //  Layout: [artwork] [title + artist] [controls]
    //
    //  • Artwork thumbnail (square)
    //  • Title + artist text
    //  • Play/pause + skip controls
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property url artworkSource: ""
    property string title: ""
    property string artist: ""
    property bool playing: false
    signal playPause()
    signal next()
    signal previous()

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.icon.huge + Spacing.card.padding * 2
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    // ── Card background ────────────────────────────────────────────
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: Radius.card.background
        color: Colors.surface
        border.width: Elevation.card.borderWidth
        border.color: Colors.borderStrong
        clip: true

        // A restrained top edge gives the opaque card separation without a
        // glass highlight or a heavy border.
        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: Colors.fg
            opacity: 0.08
        }
    }

    // ── Content ────────────────────────────────────────────────────
    Row {
        id: contentRow
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Spacing.card.padding
            right: parent.right
            rightMargin: Spacing.card.padding
        }
        spacing: Spacing.card.gap

        // Artwork
        Rectangle {
            id: artworkFrame
            width: Spacing.icon.huge
            height: Spacing.icon.huge
            radius: Radius.listItem.background
            color: Colors.surface
            clip: true

            Image {
                anchors.fill: parent
                source: mediaMiniCard.artworkSource
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
        }

        // Title + artist
        Column {
            id: textColumn
            spacing: Spacing.xxs
            anchors.verticalCenter: parent.verticalCenter
            width: contentRow.width
                   - artworkFrame.width - controlsRow.width
                   - Spacing.card.gap * 2

            ShellText {
                text: mediaMiniCard.title
                role: ShellText.Role.BodyBold
                textColor: Colors.fg
                width: parent.width
            }

            ShellText {
                text: mediaMiniCard.artist
                visible: mediaMiniCard.artist !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
                width: parent.width
            }
        }

        // Controls
        Row {
            id: controlsRow
            spacing: Spacing.xs
            anchors.verticalCenter: parent.verticalCenter

            MediaControlButton { iconName: "skip_previous"; onClicked: mediaMiniCard.previous() }
            MediaControlButton { iconName: mediaMiniCard.playing ? "pause" : "play_arrow"; active: mediaMiniCard.playing; onClicked: mediaMiniCard.playPause() }
            MediaControlButton { iconName: "skip_next"; onClicked: mediaMiniCard.next() }
        }
    }

    component MediaControlButton : Item {
        property string iconName: ""
        property bool active: false
        signal clicked()
        width: Spacing.icon.medium
        height: width

        ShellIcon {
            anchors.centerIn: parent
            name: parent.iconName
            iconSize: Spacing.icon.small
            iconColor: parent.active ? Colors.accent : Colors.fgMuted
        }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width
            height: width
            radius: width / 2
            color: controlMouse.containsMouse ? Colors.surfaceRaised : "transparent"
            z: -1
            Behavior on color { ColorAnimation { duration: Motion.duration.fast } }
        }
        MouseArea {
            id: controlMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
        scale: controlMouse.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: Motion.duration.fast; easing.type: Motion.easing.standard } }
    }
}
