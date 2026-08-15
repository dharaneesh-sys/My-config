import QtQuick

import qs.tokens
import qs.components.atoms
import qs.state

Item {
    id: appIcon

    // ═══════════════════════════════════════════════════════════════
    //  AppIcon
    //
    //  Renders a real application icon from the system icon themes
    //  (resolved by IconRegistry from the desktop-entry icon name),
    //  falling back to a generic Material "apps" glyph when no theme
    //  file matches.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    property string iconName: ""
    property real iconSize: Spacing.icon.large
    property color iconColor: Colors.fg

    // ── Layout ─────────────────────────────────────────────────────
    implicitWidth: iconSize
    implicitHeight: iconSize

    // ── Real theme icon (preferred) ────────────────────────────────
    Image {
        id: themedIcon
        anchors.fill: parent
        source: IconRegistry.iconSource(appIcon.iconName)
        // Launcher results only render a handful of 24px icons. Loading
        // them synchronously once the registry has resolved the path avoids
        // the visibly delayed icon pop-in from queued image decoding.
        asynchronous: false
        cache: true
        fillMode: Image.PreserveAspectFit
        sourceSize.width: Math.round(appIcon.iconSize * 2)
        sourceSize.height: Math.round(appIcon.iconSize * 2)
        visible: source !== "" && status === Image.Ready
    }

    // ── Material fallback ──────────────────────────────────────────
    ShellIcon {
        anchors.fill: parent
        name: "apps"
        iconSize: appIcon.iconSize
        iconColor: appIcon.iconColor
        visible: !themedIcon.visible
    }
}
