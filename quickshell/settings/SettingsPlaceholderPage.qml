import QtQuick

import qs.tokens
import qs.metrics
import qs.components.atoms

Item {
    id: placeholderPage

    // ═══════════════════════════════════════════════════════════════
    //  SettingsPlaceholderPage
    //
    //  Placeholder for unimplemented settings pages.
    //  Displays page header with title + subtitle and a
    //  centered body message. No controls.
    //
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    // ── Page data (passed from SettingsPage) ───────────────────────
    property var pageData: null

    readonly property string _pageId: pageData ? (pageData.id || "") : ""
    readonly property string _pageLabel: pageData ? (pageData.label || "") : ""

    // ── Layout ─────────────────────────────────────────────────────
    anchors.fill: parent

    // ── Content ────────────────────────────────────────────────────
    Column {
        id: content
        anchors {
            fill: parent
            margins: Spacing.settings.padding
        }
        spacing: Spacing.settings.pageGap

        SettingsPageHeader {
            id: header
            width: parent.width
            title: placeholderPage._pageLabel
            subtitle: placeholderPage._placeholderSubtitle()
        }

        Item {
            width: parent.width
            height: content.height - header.height - Spacing.settings.pageGap

            ShellText {
                anchors.centerIn: parent
                text: "Content for " + placeholderPage._pageLabel + " will appear here."
                role: ShellText.Role.Body
                textColor: Colors.fgMuted
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    // ── Placeholder subtitles ──────────────────────────────────────
    function _placeholderSubtitle() {
        switch (_pageId) {
        case "media":          return "Media player integration"
        case "keybinds":       return "Keyboard shortcuts and bindings"
        default:               return ""
        }
    }
}
