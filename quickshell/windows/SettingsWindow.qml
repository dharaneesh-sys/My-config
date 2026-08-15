import Quickshell
import QtQuick

import qs.state
import qs.metrics
import qs.tokens
import qs.settings

FloatingWindow {
    id: settingsWindow

    // ═══════════════════════════════════════════════════════════════
    //  SettingsWindow — the sole FloatingWindow
    //
    //  Shell only. Delegates navigation to SettingsRouter,
    //  sidebar to SettingsSidebar, page switching to SettingsStack.
    //  No page content lives here.
    //
    //  Architecture:
    //    SettingsWindow
    //      → SettingsSidebar  (navigation input)
    //      → SettingsSearch   (future filtering)
    //      → SettingsStack    (page display via StackLayout)
    //        → SettingsPage (one per page, lazy-loaded)
    //          → SettingsPageHeader
    //          → (future content)
    //
    //  Router is a non-visual SettingsRouter instance that
    //  reads/writes SettingsState and drives the stack.
    // ═══════════════════════════════════════════════════════════════

    // ── Visibility ─────────────────────────────────────────────────
    visible: SettingsState.isOpen

    // ── Dimensions ────────────────────────────────────────────────
    // width/height are deprecated on FloatingWindow — use the
    // implicit* variants (FloatingWindow.width/height log a deprecation
    // warning on every reload).
    // Keep Settings intentionally compact and focused, even if an older
    // persisted geometry came from the wider dashboard-style window.
    implicitWidth: Math.min(SettingsStore.settingsW, 860)
    implicitHeight: Math.min(SettingsStore.settingsH, 620)
    
    // Position is managed by the Wayland compositor (Hyprland)

    onWidthChanged: { if (SettingsState.isOpen) SettingsStore.settingsW = width }
    onHeightChanged: { if (SettingsState.isOpen) SettingsStore.settingsH = height }

    minimumSize: Qt.size(ShellMetrics.settingsMinWidth, ShellMetrics.settingsMinHeight)
    maximumSize: Qt.size(860, 620)

    // ── Title (for Hyprland window rules) ─────────────────────────
    title: "Settings"

    // ── Background ────────────────────────────────────────────────
    // Colors.bg follows the active theme (see Colors.qml — delegated
    // to the palette, never hardcoded).
    color: "transparent"

    // ── Router (non-visual) ───────────────────────────────────────
    SettingsRouter {
        id: router
    }

    // ── Layout ────────────────────────────────────────────────────
    Rectangle {
        id: windowContent
        anchors.fill: parent
        radius: Radius.settings.window + 4
        color: Colors.bg
        border.width: Elevation.settings.borderWidth
        border.color: Colors.borderStrong
        clip: true

        // ── Title bar ─────────────────────────────────────────────
        Rectangle {
            id: titleBar

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }

            height: 32
            color: Colors.surfaceVariant
            radius: windowContent.radius

            Rectangle {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
                height: 1
                color: Colors.divider
            }

            MouseArea {
                anchors.fill: parent
                // drag.target must be an Item, not a FloatingWindow —
                // Hyprland moves floating windows (keybind), so the
                // window keeps its titlebar without a QML drag.
                cursorShape: Qt.ArrowCursor
            }

            // Title text
            Text {
                anchors {
                    left: parent.left
                    leftMargin: Spacing.lg
                    verticalCenter: parent.verticalCenter
                }

                text: "Settings"
                color: Colors.fg
                font {
                    family: Typography.heading.family
                    pixelSize: Typography.heading.size
                    weight: Typography.heading.weight
                }
            }

            // Close button
            Rectangle {
                id: closeButton

                anchors {
                    right: parent.right
                    rightMargin: Spacing.md
                    verticalCenter: parent.verticalCenter
                }

                width: Spacing.icon.small + Spacing.xs
                height: width
                radius: Radius.iconButton.background
                color: closeMouseArea.pressed ? Colors.accentPressed
                       : closeMouseArea.containsMouse ? Colors.accentHover
                       : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: closeMouseArea.containsMouse ? Colors.fgOnAccent : Colors.fgMuted
                    font.pixelSize: Typography.body.size
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SettingsState.close()
                }
            }
        }

        // ── Sidebar ───────────────────────────────────────────────
        Rectangle {
            id: sidebarBackground

            anchors {
                top: titleBar.bottom
                left: parent.left
                bottom: parent.bottom
            }

            width: ShellMetrics.sidebarWidth
            color: Colors.surface

            Rectangle {
                anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
                width: 1
                color: Colors.divider
            }

            SettingsSidebar {
                id: sidebar
                anchors.fill: parent
                router: router
            }
        }

        // ── Page area (search + stack) ────────────────────────────
        Item {
            id: pageArea

            anchors {
                top: titleBar.bottom
                left: sidebarBackground.right
                right: parent.right
                bottom: parent.bottom
            }

            // ── Search field ──────────────────────────────────────
            SettingsSearch {
                id: searchField

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Spacing.settings.padding
                }

                // Phase 8A: query is exposed but does not filter.
                onQueryChanged: {
                    router.searchQuery = query
                }
            }

            // ── Separator below search ────────────────────────────
            Rectangle {
                id: searchSeparator

                anchors {
                    top: searchField.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Spacing.sm
                }

                height: 1
                color: Colors.divider
            }

            // ── Page stack ────────────────────────────────────────
            SettingsStack {
                id: pageStack

                anchors {
                    top: searchSeparator.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    topMargin: Spacing.sm
                }

                router: router
            }
        }
    }

    // Make the native floating surface follow the rounded visual frame as
    // well, so the corner treatment is consistent with every layer panel.
    mask: Region { item: windowContent }
}
