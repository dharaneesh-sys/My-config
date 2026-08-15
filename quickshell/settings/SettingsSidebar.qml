import QtQuick

import qs.tokens
import qs.metrics
import qs.components.atoms

Item {
    id: sidebar

    // ═══════════════════════════════════════════════════════════════
    //  SettingsSidebar
    //
    //  Vertical navigation rail. Displays one entry per settings
    //  page. Clicking an entry calls router.navigate(pageId).
    //  The selected entry reads from router.currentPageId.
    //
    //  Only binds properties and emits user actions.
    // ═══════════════════════════════════════════════════════════════

    // ── Required: the SettingsRouter instance ──────────────────────
    required property QtObject router

    // ── Layout ─────────────────────────────────────────────────────
    width: ShellMetrics.sidebarWidth

    // ── Probe accessors (read-only, for M3 geometry harness) ───────
    readonly property int entryCount: entriesRepeater.count
    readonly property real entriesContentHeight: entries.height

    function entryLabelBottom(index) {
        var d = entries.children[index]
        return d ? d.entryLabel.y + d.entryLabel.height : -1
    }

    function entryDelegateHeight(index) {
        var d = entries.children[index]
        return d ? d.height : -1
    }

    function entryDelegateTop(index) {
        var d = entries.children[index]
        return d ? d.y : -1
    }

    // ── Page entries ───────────────────────────────────────────────
    // Scrollable: 13 pages × entry height exceeds the sidebar area at
    // the default window height, so entries must scroll (and clip)
    // instead of overflowing/cutting off the bottom pages.
    Flickable {
        id: entriesScroll
        anchors {
            top: parent.top
            topMargin: Spacing.sm
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        contentWidth: width
        contentHeight: entries.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: entries
            width: parent.width
            spacing: Spacing.xxs

            Repeater {
                id: entriesRepeater
                model: sidebar.router.pages

                delegate: Item {
                    id: entryDelegate

                    required property var modelData
                    required property int index

                    // Probe hook: expose the label item for the M3 harness
                    readonly property alias entryLabel: entryLabelItem

                    width: entries.width
                    // Reserve the REAL rendered label height: caption
                    // line = size × lineHeight (11 × 1.4 = 15.4px), not
                    // size + xs (15px). The old value under-reserved by
                    // 0.4px per entry, so adjacent labels overlapped.
                    height: Spacing.listItem.height

                    readonly property real _iconSize: Spacing.icon.medium
                    readonly property real _labelHeight: Typography.caption.size * Typography.caption.lineHeight
                    readonly property bool _selected: modelData.id === sidebar.router.currentPageId

                    // ── Background highlight ──────────────────────────
                    Rectangle {
                        anchors.fill: parent
                        radius: Radius.listItem.background
                        color: entryDelegate._selected
                             ? Colors.surfaceVariant
                             : "transparent"

                        Behavior on color {
                            enabled: !entryMouseArea.pressed
                            ColorAnimation {
                                duration: Motion.duration.fast
                                easing.type: Motion.easing.standard
                            }
                        }
                    }

                    // ── Icon ───────────────────────────────────────────
                    Rectangle {
                        id: entryIconFrame
                        anchors {
                            left: parent.left
                            leftMargin: Spacing.md
                            verticalCenter: parent.verticalCenter
                        }
                        width: 24
                        height: width
                        radius: width / 2
                        color: entryDelegate._selected ? Colors.accentSurface : Colors.surfaceVariant

                        ShellIcon {
                            anchors.centerIn: parent
                            name: modelData.icon || ""
                            iconSize: entryDelegate._iconSize
                            iconColor: entryDelegate._selected ? Colors.accent : Colors.fgMuted
                        }
                    }

                    // ── Label ──────────────────────────────────────────
                    ShellText {
                        id: entryLabelItem
                        anchors {
                            left: entryIconFrame.right
                            leftMargin: Spacing.sm
                            right: parent.right
                            rightMargin: Spacing.sm
                            verticalCenter: parent.verticalCenter
                        }
                        text: modelData.label || ""
                        role: ShellText.Role.Caption
                        textColor: entryDelegate._selected ? Colors.fg : Colors.fgMuted
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                    }

                    // ── Interaction ────────────────────────────────────
                    MouseArea {
                        id: entryMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sidebar.router.navigate(modelData.id)
                    }
                }
            }
        }
    }
}
