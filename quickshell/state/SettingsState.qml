pragma Singleton
import QtQuick

QtObject {
    id: ss

    // ═══════════════════════════════════════════════════════════════
    //  SettingsState
    //
    //  Controls the Settings window visibility and navigation.
    //  The Settings FloatingWindow binds its visible property
    //  to SettingsState.isOpen.
    // ═══════════════════════════════════════════════════════════════

    // ─── Window state ─────────────────────────────────────────────
    property bool isOpen: false

    // ─── Navigation ──────────────────────────────────────────────
    property string currentPage: "appearance"

    // ─── Available pages ──────────────────────────────────────────
    // Order matches the sidebar layout.
    readonly property var pages: [
        { id: "bar-pill",         label: "Bar & Pill",       icon: "dashboard" },
        { id: "appearance",       label: "Appearance",       icon: "palette" },
        { id: "themes",           label: "Themes",           icon: "contrast" },
        { id: "wallpaper",        label: "Wallpaper",        icon: "wallpaper" },
        { id: "launcher",         label: "Launcher",         icon: "rocket_launch" },
        { id: "notifications",    label: "Notifications",    icon: "notifications" },
        { id: "control-center",   label: "Control Center",   icon: "tune" },
        { id: "media",            label: "Media",            icon: "music_note" },
        { id: "clock-date",       label: "Clock & Date",     icon: "schedule" },
        { id: "motion",           label: "Motion",           icon: "animation" },
        { id: "keybinds",         label: "Keybinds",         icon: "keyboard" },
        { id: "system",           label: "System",           icon: "settings" },
        { id: "about",            label: "About",            icon: "info" }
    ]

    // ─── Public API ───────────────────────────────────────────────

    /** Open settings to a specific page. */
    function open(page) {
        if (page !== undefined && page !== "")
            currentPage = page
        isOpen = true
    }

    /** Close settings. */
    function close() {
        isOpen = false
    }

    /** Toggle settings visibility. */
    function toggle() {
        isOpen = !isOpen
    }

    /** Navigate to a different page (without changing isOpen). */
    function navigate(page) {
        currentPage = page
    }

    // ─── Helpers ──────────────────────────────────────────────────

    /** Check if a page ID is valid. */
    function isValidPage(pageId) {
        for (var i = 0; i < pages.length; i++) {
            if (pages[i].id === pageId)
                return true
        }
        return false
    }

    /** Get page info by ID. Returns null if not found. */
    function pageInfo(pageId) {
        for (var i = 0; i < pages.length; i++) {
            if (pages[i].id === pageId)
                return pages[i]
        }
        return null
    }
}
