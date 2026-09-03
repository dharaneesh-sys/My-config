import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: clipRow

    // ═══════════════════════════════════════════════════════════════
    //  ClipboardRow
    //
    //  Entry row for the clipboard panel.
    //  Layout: [icon tile | image thumbnail] [preview text] [actions]
    //
    //  • Text entries — content_paste glyph + elided preview line.
    //  • Image entries — decoded thumbnail (lazy, via imageVisible)
    //    + "Image · WxH" caption.
    //  • Actions — copy icon (always) + delete icon (hover/selected).
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string entryId: ""
    property string preview: ""
    property bool isImage: false
    property string imageFormat: ""
    property int imageWidth: 0
    property int imageHeight: 0
    property url imageUrl: ""
    property bool highlighted: false
    // Keyboard-nav selection highlight (clipboard Up/Down).
    signal clicked()
    signal deleteClicked()
    // Emitted when the row becomes visible but has no decoded thumbnail
    // yet — the panel routes this to ClipboardService.
    signal imageVisible()

    // ── Layout ─────────────────────────────────────────────────────
    implicitHeight: Spacing.listItem.height
    implicitWidth:  parent ? parent.width : Spacing.panel.minWidth

    readonly property real _tileSize: Spacing.icon.large + Spacing.sm * 2   // 40

    // ── Background ─────────────────────────────────────────────────
    Rectangle {
        id: rowBg
        anchors.fill: parent
        radius: Radius.listItem.background
        color: highlighted ? Colors.accentSurface
             : mouseArea.pressed ? Colors.surfaceRaised
             : mouseArea.containsMouse ? Colors.surfaceVariant
             : "transparent"
        border.width: 0

        Behavior on color {
            ColorAnimation { duration: Motion.listItem.hoverDuration }
        }
    }

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

        // ── Icon tile / image thumbnail ─────────────────────────
        Item {
            id: iconSlot
            width: clipRow._tileSize
            height: clipRow._tileSize
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.fill: parent
                radius: Radius.listItem.background
                color: mouseArea.containsMouse ? Colors.surfaceRaised : Colors.surfaceVariant

                Behavior on color {
                    ColorAnimation { duration: Motion.listItem.hoverDuration }
                }
            }

            // Image thumbnail (loaded lazily from /tmp via the panel)
            Image {
                id: thumbImage
                visible: clipRow.isImage
                anchors.fill: parent
                anchors.margins: 3
                source: clipRow.imageUrl
                fillMode: Image.PreserveAspectCrop
                sourceSize { width: clipRow._tileSize * 2; height: clipRow._tileSize * 2 }
                smooth: true
                mipmap: true
                cache: false
                asynchronous: true
            }

            // Text-entry glyph
            ShellIcon {
                visible: !clipRow.isImage
                anchors.centerIn: parent
                name: "content_paste"
                iconSize: Spacing.icon.small
                iconColor: Colors.fgMuted
            }
        }

        // ── Preview text ─────────────────────────────────────────
        Column {
            id: textColumn
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter
            width: contentRow.width
                   - iconSlot.width - actionsSlot.width
                   - Spacing.listItem.gap * 2

            ShellText {
                id: previewLine
                text: clipRow.isImage
                      ? "Image" + (clipRow.imageFormat ? " · " + clipRow.imageFormat : "")
                      : clipRow.preview
                role: ShellText.Role.Body
                textColor: Colors.fg
                width: parent.width
                elide: Text.ElideRight
                clip: true
            }

            ShellText {
                text: clipRow.isImage && clipRow.imageWidth > 0
                      ? clipRow.imageWidth + "×" + clipRow.imageHeight
                      : ""
                visible: text !== ""
                role: ShellText.Role.Caption
                textColor: Colors.fgMuted
                width: parent.width
                elide: Text.ElideRight
            }
        }

        // ── Action icons (copy + delete) ─────────────────────────
        Row {
            id: actionsSlot
            spacing: Spacing.xxs
            anchors.verticalCenter: parent.verticalCenter
            // Actions appear on hover or when keyboard-selected.
            opacity: (mouseArea.containsMouse || clipRow.highlighted) ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: Motion.duration.fast }
            }

            // Copy
            Rectangle {
                width: Spacing.icon.medium + Spacing.xs * 2
                height: width
                radius: width / 2
                color: copyMouse.pressed ? Colors.surfaceRaised
                     : copyMouse.containsMouse ? Colors.surfaceVariant
                     : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Motion.button.hoverDuration }
                }

                ShellIcon {
                    anchors.centerIn: parent
                    name: "content_copy"
                    iconSize: Spacing.icon.small
                    iconColor: copyMouse.containsMouse ? Colors.accent : Colors.fgMuted
                }

                MouseArea {
                    id: copyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // Copy icon must not also trigger the row click
                        mouse.accepted = true
                        clipRow.clicked()
                    }
                }
            }

            // Delete
            Rectangle {
                width: Spacing.icon.medium + Spacing.xs * 2
                height: width
                radius: width / 2
                color: deleteMouse.pressed ? Colors.surfaceRaised
                     : deleteMouse.containsMouse ? Colors.surfaceVariant
                     : "transparent"

                Behavior on color {
                    ColorAnimation { duration: Motion.button.hoverDuration }
                }

                ShellIcon {
                    anchors.centerIn: parent
                    name: "delete"
                    iconSize: Spacing.icon.small
                    iconColor: deleteMouse.containsMouse ? Colors.error : Colors.fgMuted
                }

                MouseArea {
                    id: deleteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        mouse.accepted = true
                        clipRow.deleteClicked()
                    }
                }
            }
        }
    }

    // ── Interaction ────────────────────────────────────────────────
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: -1
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clipRow.clicked()
    }

    scale: mouseArea.pressed ? 0.992 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Motion.listItem.pressDuration; easing.type: Motion.easing.standard }
    }

    // ── Lazy thumbnail request ─────────────────────────────────────
    // Fires when the row is visible (or becomes visible) but the
    // thumbnail is not decoded yet. The panel routes this to the
    // service; the service sets imageUrl via ClipboardState.
    Component.onCompleted: clipRow._ensurePreview()

    onVisibleChanged: clipRow._ensurePreview()


    function _ensurePreview() {
        // QUrl objects are truthy even when empty — compare as string.
        if (clipRow.isImage && clipRow.visible && String(clipRow.imageUrl) === "")
            clipRow.imageVisible()
    }
}