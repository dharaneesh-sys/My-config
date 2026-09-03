import QtQuick
import Qt5Compat.GraphicalEffects

import qs.tokens
import qs.components.atoms

Item {
    id: wallpaperCard

    // ═══════════════════════════════════════════════════════════════
    //  WallpaperCard
    //
    //  Wallpaper thumbnail card for the wallpaper selector.
    //  Shows a thumbnail preview + name + selected indicator.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string name: ""
    property url thumbnailSource: ""
    property bool selected: false
    property bool highlighted: false
    // Compact mode is used by the panel's wide wallpaper tray.
    property bool compact: false
    signal clicked()

    // ── Layout ─────────────────────────────────────────────────────
    // width is overridable by the parent grid; height follows width so
    // the thumbnail stays square and the card never shifts while images
    // load (the 3×N wallpaper grid relies on this).
    width:  Spacing.quickTile.size
    height: compact ? 64
                    : width + Spacing.card.padding * 2 + Spacing.card.gap + nameLabel.implicitHeight

    // ── Card background ────────────────────────────────────────────
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: Radius.card.background
        color: selected ? Colors.accentSurface : Colors.surfaceVariant
        border.width: (selected || highlighted) ? Elevation.card.borderWidth + 1 : Elevation.card.borderWidth
        border.color: (selected || highlighted || mouseArea.containsMouse) ? Colors.accent : Colors.border
        clip: true

        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }

        Behavior on color {
            ColorAnimation { duration: Motion.toggle.trackDuration }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        visible: wallpaperCard.highlighted
        color: "transparent"
        radius: Radius.card.background + 1
        border.width: 1
        border.color: Colors.accent
        z: 3
    }

    // ── Thumbnail (square) ─────────────────────────────────────────
    Rectangle {
        id: thumbnailFrame
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: wallpaperCard.compact ? 0 : Spacing.card.padding
        }
        height: wallpaperCard.compact ? parent.height : width
        radius: wallpaperCard.compact ? Radius.card.background
                                       : Radius.listItem.background
        color: Colors.surface

        Image {
            id: thumbnail
            anchors.fill: parent
            source: wallpaperCard.thumbnailSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            // The mask renders this source to an intermediate texture; hiding
            // the raw image prevents its square pixels being drawn below it.
            visible: false
        }

        Rectangle {
            id: thumbnailMask
            anchors.fill: parent
            radius: thumbnailFrame.radius
            visible: false
        }

        // Item.clip is rectangular in Qt Quick. An alpha mask is needed to
        // genuinely remove thumbnail pixels from each rounded corner.
        OpacityMask {
            anchors.fill: parent
            source: thumbnail
            maskSource: thumbnailMask
            cached: true
            visible: thumbnail.status === Image.Ready
        }

        // Fallback when no image is available. The rounded parent clips both
        // the actual thumbnail and this fallback to the same silhouette.
        Rectangle {
            anchors.fill: parent
            color: Colors.surface
            visible: thumbnail.status !== Image.Ready
            radius: thumbnailFrame.radius
        }
    }

    // ── Name label ─────────────────────────────────────────────────
    ShellText {
        id: nameLabel
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Spacing.card.padding
        }
        visible: !wallpaperCard.compact
        text: wallpaperCard.name
        role: ShellText.Role.Caption
        textColor: selected ? Colors.accent : Colors.fgMuted
        width: parent.width - Spacing.card.padding * 2
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    // ── Selected indicator ─────────────────────────────────────────
    Rectangle {
        visible: selected
        z: 4
        anchors {
            top: parent.top
            right: parent.right
            topMargin: Spacing.xs
            rightMargin: Spacing.xs
        }
        width: 16
        height: 16
        radius: width / 2
        color: Colors.accent

        ShellIcon {
            anchors.centerIn: parent
            name: "check"
            iconSize: 12
            iconColor: Colors.fgOnAccent
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: wallpaperCard.clicked()
    }

    scale: mouseArea.pressed ? 0.985 : (mouseArea.containsMouse ? 1.015 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }
}
