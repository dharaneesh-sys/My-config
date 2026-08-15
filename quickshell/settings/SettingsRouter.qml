import QtQuick

import qs.state

QtObject {
    id: router

    // ═══════════════════════════════════════════════════════════════
    //  SettingsRouter
    //
    //  Non-visual navigation controller for Settings.
    //  Reads page list and current page from SettingsState.
    //  Computes the StackLayout index for the current page.
    //  All navigation flows through SettingsState so selection
    //  persists automatically.
    //
    //  Architecture:
    //    SettingsSidebar → router.navigate(id)
    //      → SettingsState.navigate(id)
    //        → SettingsState.currentPage updates
    //          → router.currentPageId updates
    //            → router.currentIndex updates
    //              → SettingsStack.currentIndex updates
    // ═══════════════════════════════════════════════════════════════

    // ── Pages ──────────────────────────────────────────────────────
    property string searchQuery: ""
    
    readonly property var allPages: SettingsState.pages
    readonly property var pages: {
        if (searchQuery === "") return allPages;
        var q = searchQuery.toLowerCase();
        var res = [];
        for (var i = 0; i < allPages.length; i++) {
            var label = allPages[i].label || "";
            if (label.toLowerCase().indexOf(q) !== -1 || allPages[i].id.toLowerCase().indexOf(q) !== -1) {
                res.push(allPages[i]);
            }
        }
        return res;
    }

    // ── Current page ───────────────────────────────────────────────
    readonly property string currentPageId: SettingsState.currentPage

    // ── Current index in StackLayout ───────────────────────────────
    readonly property int currentIndex: _findPageIndex()

    // ── Current page data object ───────────────────────────────────
    readonly property var currentPageObject: {
        var idx = currentIndex
        return (idx >= 0 && idx < pages.length) ? pages[idx] : null
    }

    // ── Navigation ─────────────────────────────────────────────────
    function navigate(pageId) {
        SettingsState.navigate(pageId)
        SettingsStore.settingsPageId = pageId
    }

    // ── Startup ────────────────────────────────────────────────────
    Component.onCompleted: {
        if (SettingsStore.settingsPageId !== "") {
            navigate(SettingsStore.settingsPageId)
        }
    }

    // ── Internal ───────────────────────────────────────────────────
    function _findPageIndex() {
        for (var i = 0; i < pages.length; i++) {
            if (pages[i].id === currentPageId)
                return i
        }
        return 0
    }
}
