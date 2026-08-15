import QtQuick

import qs.tokens
import qs.metrics
import qs.components.atoms

Item {
    id: settingsPage

    // ═══════════════════════════════════════════════════════════════
    //  SettingsPage
    //
    //  Page router. Reads pageData.id and loads the matching
    //  content component. Implemented pages get their real QML;
    //  unimplemented pages get the placeholder.
    //
    //  Phase 8J+: All 13 pages are live:
    //            "appearance", "themes", "wallpaper",
    //            "bar-pill", "motion", "control-center",
    //            "launcher", "notifications", "clock-date",
    //            "media", "keybinds", "system", "about".
    //  No pages remain as placeholder.
    //
    //  Pure view — no logic, no State access.
    // ═══════════════════════════════════════════════════════════════

    // ── Page data (from router) ────────────────────────────────────
    // Not `required`: SettingsStack's Loader sets this *after* the
    // component is constructed (onLoaded), so `required` would fire
    // the "not initialized" warning on every page load.
    property var pageData: ({})

    // ── Page metadata (derived from pageData) ──────────────────────
    readonly property string _pageId: pageData.id || ""
    readonly property string _pageLabel: pageData.label || ""

    // ── Layout ─────────────────────────────────────────────────────
    anchors.fill: parent

    // ── Page content loader ────────────────────────────────────────
    Loader {
        id: pageLoader
        anchors.fill: parent
        source: _pageSource()
    }

    function _pageSource() {
        switch (_pageId) {
        case "appearance": return Qt.resolvedUrl("AppearancePage.qml")
        case "themes":     return Qt.resolvedUrl("ThemePage.qml")
        case "wallpaper":  return Qt.resolvedUrl("WallpaperPage.qml")
        case "bar-pill":       return Qt.resolvedUrl("BarAndPillPage.qml")
        case "motion":         return Qt.resolvedUrl("MotionPage.qml")
        case "control-center": return Qt.resolvedUrl("ControlCenterPage.qml")
        case "launcher":       return Qt.resolvedUrl("LauncherPage.qml")
        case "notifications":  return Qt.resolvedUrl("NotificationPage.qml")
        case "clock-date":     return Qt.resolvedUrl("ClockDatePage.qml")
        case "media":          return Qt.resolvedUrl("MediaPage.qml")
        case "keybinds":       return Qt.resolvedUrl("KeybindsPage.qml")
        case "system":         return Qt.resolvedUrl("SystemPage.qml")
        case "about":          return Qt.resolvedUrl("AboutPage.qml")
        default:           return Qt.resolvedUrl("SettingsPlaceholderPage.qml")
        }
    }

    // ── Pass pageData to placeholder pages ────────────────────────
    Connections {
        target: pageLoader.item
        ignoreUnknownSignals: true
        function onPageDataChanged() {} // no-op, just for binding
    }

    on_PageIdChanged: {
        if (pageLoader.item && pageLoader.item.hasOwnProperty("pageData"))
            pageLoader.item.pageData = pageData
    }

    Component.onCompleted: {
        if (pageLoader.item && pageLoader.item.hasOwnProperty("pageData"))
            pageLoader.item.pageData = pageData
    }
}
