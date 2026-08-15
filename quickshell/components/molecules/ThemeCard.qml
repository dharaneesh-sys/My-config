import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: themeCard

    // ═══════════════════════════════════════════════════════════════
    //  ThemeCard
    //
    //  Theme preview card for the theme switcher / settings.
    //  Shows 3 color dots (bg / accent / surface) + name + selected indicator.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string name: ""
    property color primaryColor: Colors.accent
    property color bgColor: Colors.bg
    property color surfaceColor: Colors.surface
    property color onSurfaceColor: Colors.fg
    property bool selected: false
    property bool highlighted: false
    signal clicked()

    // ── Layout ─────────────────────────────────────────────────────
    // Compact preview cards: palette swatch bar + name. Their own palette
    // colors are intentionally shown rather than the shell's current color.
    width:  Spacing.quickTile.size
    height: 52

    // ── Card background ────────────────────────────────────────────
    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: Radius.listItem.background
        color: themeCard.bgColor
        border.width: (selected || highlighted) ? Elevation.card.borderWidth + 1 : Elevation.card.borderWidth
        border.color: selected ? themeCard.primaryColor
                    : highlighted ? Colors.accent
                    : mouseArea.containsMouse ? Colors.borderStrong
                                              : Colors.border
        clip: true

        Behavior on border.color {
            ColorAnimation { duration: Motion.toggle.trackDuration }
        }

        Behavior on color {
            ColorAnimation { duration: Motion.toggle.trackDuration }
        }
    }

    // Keyboard focus is deliberately more prominent than a one-pixel card
    // border, so the active choice is clear on every palette preview.
    Rectangle {
        anchors.fill: parent
        anchors.margins: -1
        visible: themeCard.highlighted
        color: "transparent"
        radius: Radius.listItem.background + 1
        border.width: 1
        border.color: Colors.accent
        z: 3
    }

    // ── Palette accent ────────────────────────────────────────────
    Rectangle {
        id: accentBar
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 14
        }
        width: 24
        height: 4
        radius: height / 2
        color: themeCard.primaryColor
    }

    // ── Name label ─────────────────────────────────────────────────
    ShellText {
        id: nameLabel
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: 10
        }
        text: themeCard.name.toLowerCase()
        role: ShellText.Role.Caption
        textColor: themeCard.onSurfaceColor
        opacity: selected ? 1.0 : 0.78
        width: parent.width - Spacing.xs * 2
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.NoWrap
        maximumLineCount: 1
        elide: Text.ElideRight
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: themeCard.clicked()
    }

    scale: mouseArea.pressed ? 0.985 : (mouseArea.containsMouse ? 1.012 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: Motion.button.hoverDuration; easing.type: Motion.easing.standard }
    }
}
