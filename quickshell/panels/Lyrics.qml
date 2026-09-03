import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.components.atoms
import qs.viewmodels

Item {
    id: lyricsPanel

    // ── ViewModel ──────────────────────────────────────────────────
    LyricsViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.lyricsWidth
    implicitHeight: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        // ── Header ───────────────────────────────────────────────
        PanelHeader {
            width: parent.width
            title: vm.headerTitle
            iconName: "lyrics"
            subtitle: vm.headerSubtitle
        }

        // ── Player info (for kdeconnect device) ──────────────────
        ShellText {
            visible: vm.playerName !== "" && vm.trackTitle !== ""
            width: parent.width
            text: vm.playerName + (vm.isVideo ? " • Video" : "")
            role: ShellText.Role.Overline
            textColor: Colors.fgMuted
            horizontalAlignment: Text.AlignHCenter
        }

        // ── Sync offset controls (online fix for out-of-sync) ────────
        // LRCs for same song can differ by recording version; offset shifts all stamps.
        // Uses [offset: +/-ms] logic + per-track syncOffset. Auto-pick by duration already
        // tries best, but manual ±0.5s fixes remaining drift without re-fetch.
        Item {
            visible: vm.hasSynced && !vm.isVideo && !vm.isInstrumental
            width: parent.width
            height: 36
            Row {
                anchors.centerIn: parent
                spacing: 8
                ShellButton {
                    text: "-0.5s"
                    iconName: "remove"
                    onClicked: vm.adjustOffset(-0.5)
                }
                ShellText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (vm.syncOffset > 0 ? "+" : "") + vm.syncOffset.toFixed(1) + "s"
                    role: ShellText.Role.Caption
                    textColor: vm.syncOffset !== 0 ? Colors.accent : Colors.fgMuted
                    width: 60
                    horizontalAlignment: Text.AlignHCenter
                }
                ShellButton {
                    text: "+0.5s"
                    iconName: "add"
                    onClicked: vm.adjustOffset(0.5)
                }
                ShellButton {
                    visible: vm.syncOffset !== 0
                    text: "Reset"
                    iconName: "restart_alt"
                    onClicked: vm.resetOffset()
                }
            }
        }

        // Candidate picker removed — auto-pick best only (per request)

        // ── Instrumental ─────────────────────────────────────────
        Item {
            visible: vm.isInstrumental
            width: parent.width
            height: 80
            ShellText {
                anchors.centerIn: parent
                text: "♪ Instrumental ♪"
                role: ShellText.Role.Title
                textColor: Colors.fgMuted
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // ── Video placeholder ────────────────────────────────────
        Item {
            visible: vm.isVideo && !vm.isInstrumental
            width: parent.width
            height: 60
            ShellText {
                anchors.centerIn: parent
                width: parent.width - Spacing.panel.padding * 2
                text: "Video playback — lyrics hidden"
                role: ShellText.Role.Body
                textColor: Colors.fgMuted
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        // ── No lyrics ────────────────────────────────────────────
        Item {
            visible: !vm.isVideo && !vm.isInstrumental && !vm.hasLyrics && vm.trackTitle !== ""
            width: parent.width
            height: 60
            Column {
                anchors.centerIn: parent
                width: parent.width
                spacing: Spacing.xxs
                ShellText {
                    width: parent.width
                    text: "No lyrics found"
                    role: ShellText.Role.Body
                    textColor: Colors.fgMuted
                    horizontalAlignment: Text.AlignHCenter
                }
                ShellButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Refresh"
                    iconName: "refresh"
                    onClicked: vm.refresh()
                }
            }
        }

        // ── Disabled ─────────────────────────────────────────────
        Item {
            visible: !vm.isEnabled && !vm.isVideo && vm.trackTitle === ""
            width: parent.width
            height: 60
            ShellText {
                anchors.centerIn: parent
                text: vm.isEnabled ? "No track playing" : "Lyrics disabled in settings"
                role: ShellText.Role.Body
                textColor: Colors.fgMuted
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // ── Current lyric (large) ────────────────────────────────
        // Shows the current synced line prominently — fixes "no current lyrics"
        Item {
            visible: vm.hasSynced && vm.currentLine >= 0 && !vm.isInstrumental && !vm.isVideo && vm.autoSync
            width: parent.width
            height: currentLyricText.implicitHeight + 16
            clip: true
            Rectangle {
                anchors.fill: parent
                radius: 10
                color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.08)
                border.width: 0
            }
            ShellText {
                id: currentLyricText
                anchors.centerIn: parent
                width: parent.width - 24
                text: vm.currentLine >= 0 && vm.currentLine < vm.lyricsLines.length ? vm.lyricsLines[vm.currentLine].text : ""
                role: ShellText.Role.Body
                textColor: Colors.accent
                font.weight: Font.DemiBold
                font.pixelSize: Typography.body.size + 1
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        // ── Synced lyrics ────────────────────────────────────────
        Item {
            visible: vm.hasSynced && !vm.isInstrumental && !vm.isVideo
            width: parent.width
            height: Math.min(280, lyricsList.contentHeight + 12)
            clip: true

            ListView {
                id: lyricsList
                anchors.fill: parent
                model: vm.lyricsLines
                clip: true
                cacheBuffer: 400
                boundsBehavior: Flickable.StopAtBounds
                // Highlight current line
                highlight: Rectangle {
                    color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.12)
                    radius: 8
                    border.width: 0
                    border.color: "transparent"
                }
                highlightMoveDuration: 220
                highlightMoveVelocity: -1
                highlightFollowsCurrentItem: true
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: 120
                preferredHighlightEnd: 200
                currentIndex: vm.autoSync ? vm.currentLine : -1
                // Auto-scroll to current line when it changes
                onCurrentIndexChanged: {
                    if (vm.autoSync && currentIndex >= 0)
                        positionViewAtIndex(currentIndex, ListView.Contain)
                }

                delegate: Item {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: lyricText.implicitHeight + 14
                    // Subtle row background for current line already handled by highlight
                    ShellText {
                        id: lyricText
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.text || "♪"
                        role: ShellText.Role.Body
                        textColor: index === vm.currentLine && vm.autoSync ? Colors.accent : (index < vm.currentLine ? Colors.fg : Colors.fgMuted)
                        font.weight: index === vm.currentLine && vm.autoSync ? Font.DemiBold : Font.Normal
                        font.pixelSize: index === vm.currentLine && vm.autoSync ? Typography.body.size + 1 : Typography.body.size
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        opacity: index === vm.currentLine && vm.autoSync ? 1.0 : (index < vm.currentLine ? 0.85 : 0.6)
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                        Behavior on font.pixelSize { NumberAnimation { duration: 150 } }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: vm.seekToLine(index)
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // ── Plain lyrics (fallback) ──────────────────────────────
        Item {
            visible: !vm.hasSynced && vm.hasLyrics && !vm.isInstrumental && !vm.isVideo
            width: parent.width
            height: Math.min(320, plainText.implicitHeight + 20)
            clip: true
            Flickable {
                anchors.fill: parent
                contentHeight: plainText.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ShellText {
                    id: plainText
                    width: parent.width - 24
                    x: 12
                    text: vm.plainLyrics
                    role: ShellText.Role.Body
                    textColor: Colors.fg
                    wrapMode: Text.WordWrap
                    lineHeight: 1.4
                }
            }
        }

        // ── Translation toggle (future) ──────────────────────────
        // Placeholder for every-single-lyrics-feature: translation, etc.
        // Currently plain vs synced is the core; translation will be added
        // when LRCLIB or other source provides it.
    }

    // Ensure lyrics view scrolls to current on position change even when panel already open
    // Fixed: highlight stuck on first line due to ListView not updating when model changes
    Connections {
        target: vm
        function onCurrentLineChanged() {
            // Declarative currentIndex binding already sets highlight;
            // scroll only — do not reassign currentIndex to avoid binding loop
            if (vm.autoSync && vm.hasSynced && lyricsList.count > 0 && vm.currentLine >= 0) {
                lyricsList.positionViewAtIndex(vm.currentLine, ListView.Contain)
            }
        }
        function onLyricsLinesChanged() {
            // New lyrics loaded — binding updates currentIndex; ensure it is visible
            if (vm.autoSync && vm.hasSynced && vm.currentLine >= 0 && lyricsList.count > 0)
                lyricsList.positionViewAtIndex(vm.currentLine, ListView.Contain)
        }
    }
}
