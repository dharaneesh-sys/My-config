import QtQuick

import qs.tokens
import qs.components.atoms

Item {
    id: pageHeader

    // ═══════════════════════════════════════════════════════════════
    //  SettingsPageHeader
    //
    //  Title + subtitle bar at the top of each settings page.
    //  Pure presentational — no logic.
    // ═══════════════════════════════════════════════════════════════

    // ── Properties ─────────────────────────────────────────────────
    required property string title
    property string subtitle: ""

    // ── Layout ─────────────────────────────────────────────────────
    height: titleText.height + (subtitleText.visible ? subtitleText.height + Spacing.xs : 0)

    // ── Title ──────────────────────────────────────────────────────
    ShellText {
        id: titleText
        anchors {
            left: parent.left
            top: parent.top
        }
        text: pageHeader.title
        role: ShellText.Role.Title
        textColor: Colors.fg
    }

    // ── Subtitle ───────────────────────────────────────────────────
    ShellText {
        id: subtitleText
        anchors {
            left: parent.left
            top: titleText.bottom
            topMargin: Spacing.xs
        }
        visible: pageHeader.subtitle !== ""
        text: pageHeader.subtitle
        role: ShellText.Role.Body
        textColor: Colors.fgMuted
    }
}
