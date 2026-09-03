import QtQuick
import Quickshell

import qs.state

// ═══════════════════════════════════════════════════════════════
//  M3 — ClipboardState verification
//
//  Pure-state tests for the cliphist-backed clipboard panel:
//   1. _parseLine text entries (id / preview split)
//   2. _parseLine image entries (binary-data placeholder → metadata)
//   3. Malformed lines are rejected
//   4. setEntries mirrors entries into filteredEntries
//   5. Filtering: text match, image format, dimensions, case, empty
//   6. Optimistic delete removes from entries + filtered
//   7. dropImagePath removes one thumbnail (object reassigned)
//
//  Runs headless through the real quickshell engine.
//  Exit code 0 = pass. Run via a temp copy at the config root so
//  qs.* module imports resolve:
//    cp tests/M3-clipboardstate.qml .M3-run.qml && quickshell -p .M3-run.qml
// ═══════════════════════════════════════════════════════════════
ShellRoot {
    id: root

    property bool okAll: true
    property int checkCount: 0

    function check(name, cond) {
        root.checkCount++
        console.log("M3-CHECK " + name + "=" + cond)
        if (!cond) root.okAll = false
    }

    Component.onCompleted: {
        // defer exit until the event loop + engine quit wiring are live
        exitTimer.start()
    }

    Timer {
        id: exitTimer
        interval: 1

        onTriggered: {
            // ── 1. _parseLine: text entry ──
            var e = ClipboardState._parseLine("42\thello world")
            root.check("parse-text-id", e !== null && e.id === "42")
            root.check("parse-text-preview", e !== null && e.preview === "hello world")
            root.check("parse-text-notimage", e !== null && e.isImage === false)

            // ── 2. _parseLine: image entry (cliphist placeholder) ──
            var img = ClipboardState._parseLine("7\t[[ binary data 3 MiB jpeg 5472x3648 ]]")
            root.check("parse-img-isimage", img !== null && img.isImage === true)
            root.check("parse-img-format", img !== null && img.imageFormat === "jpeg")
            root.check("parse-img-width", img !== null && img.imageWidth === 5472)
            root.check("parse-img-height", img !== null && img.imageHeight === 3648)
            root.check("parse-img-preview", img !== null && img.preview.indexOf("[[ binary data") === 0)

            // ── 3. Malformed line ──
            root.check("parse-malformed", ClipboardState._parseLine("no-tab-here") === null)

            // ── 4. setEntries ──
            ClipboardState.setEntries([
                "3\t[[ binary data 2 MiB png 1920x1080 ]]",
                "2\thello world",
                "1\tfoo bar baz"
            ])
            root.check("entries-count", ClipboardState.entries.length === 3)
            root.check("filtered-mirrors-entries", ClipboardState.filteredEntries.length === 3)
            root.check("entries-recent-first", ClipboardState.entries[0].id === "3")

            // ── 5. Filtering ──
            ClipboardState.setQueryRequested("hello")
            root.check("filter-text", ClipboardState.filteredEntries.length === 1
                                       && ClipboardState.filteredEntries[0].id === "2")
            ClipboardState.setQueryRequested("png")
            root.check("filter-format", ClipboardState.filteredEntries.length === 1
                                        && ClipboardState.filteredEntries[0].id === "3")
            ClipboardState.setQueryRequested("1920x1080")
            root.check("filter-dims", ClipboardState.filteredEntries.length === 1
                                      && ClipboardState.filteredEntries[0].id === "3")
            ClipboardState.setQueryRequested("HELLO")
            root.check("filter-case-insensitive", ClipboardState.filteredEntries.length === 1)
            ClipboardState.setQueryRequested("zzz")
            root.check("filter-nomatch", ClipboardState.filteredEntries.length === 0)
            ClipboardState.setQueryRequested("")
            root.check("filter-empty-query-all", ClipboardState.filteredEntries.length === 3)

            // ── 6. Optimistic delete ──
            ClipboardState.deleteRequested("2")
            root.check("delete-removes-entry", ClipboardState.entries.length === 2)
            root.check("delete-removes-filtered", ClipboardState.filteredEntries.length === 2)
            root.check("delete-keeps-image", ClipboardState.entries[0].id === "3"
                                              || ClipboardState.entries[1].id === "3")

            // ── 7. dropImagePath ──
            var p1 = Object.assign({}, ClipboardState.imagePaths)
            p1["3"] = "file:///tmp/qsh-clipboard-3.img"
            ClipboardState.imagePaths = p1
            root.check("imagepath-set", ClipboardState.imagePaths["3"] !== undefined)
            ClipboardState.dropImagePath("3")
            root.check("imagepath-dropped", ClipboardState.imagePaths["3"] === undefined)
            root.check("imagepath-reassigned", ClipboardState.imagePaths !== p1)

            console.log("M3-RESULT checks=" + root.checkCount + " ok=" + root.okAll)
            Qt.exit(root.okAll ? 0 : 1)
        }
    }
}