import QtQuick
import QtQuick.Layouts

import qs.tokens
import qs.metrics

Item {
    id: settingsStack

    // ═══════════════════════════════════════════════════════════════
    //  SettingsStack
    //
    //  StackLayout container for all settings pages.
    //  Binds currentIndex to the router so page switching is
    //  automatic when the sidebar selection changes.
    //
    //  Pages are wrapped in Loaders for lazy loading — a page
    //  is instantiated only on first visit and stays loaded
    //  afterward (no state loss on back-navigation).
    //
    //  Animated page transitions via opacity Behavior.
    // ═══════════════════════════════════════════════════════════════

    // ── Required: the SettingsRouter instance ──────────────────────
    required property QtObject router

    // ── Track which pages have been visited ────────────────────────
    property var _visitedPages: ({})

    // Mark the current page as visited whenever it changes
    onRouterChanged: _markCurrentVisited()
    Component.onCompleted: _markCurrentVisited()

    function _markCurrentVisited() {
        var key = "page_" + router.currentIndex
        var copy = Object.assign({}, _visitedPages)
        copy[key] = true
        _visitedPages = copy
    }

    // ── StackLayout ────────────────────────────────────────────────
    StackLayout {
        id: stackLayout
        anchors.fill: parent
        currentIndex: settingsStack.router.currentIndex

        onCurrentIndexChanged: settingsStack._markCurrentVisited()

        Repeater {
            model: settingsStack.router.pages

            delegate: Loader {
                id: pageLoader

                required property var modelData
                required property int index

                // ── Lazy loading ──────────────────────────────────
                // Load on first visit, then keep loaded permanently.
                readonly property string _visitKey: "page_" + index
                active: settingsStack._visitedPages[_visitKey] === true

                asynchronous: true
                visible: status === Loader.Ready
                source: Qt.resolvedUrl("SettingsPage.qml")

                // Pass page data once loaded
                onLoaded: if (item) item.pageData = modelData

                // ── Page transition animation ─────────────────────
                opacity: status === Loader.Ready ? 1.0 : 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Motion.duration.medium
                        easing.type: Motion.easing.standard
                    }
                }
            }
        }
    }
}
