pragma Singleton
import QtQuick

QtObject {
    id: root

    // ─── Active theme ─────────────────────────────────────────────
    // Delegate to Colors — the single source of truth.
    // Changing Colors.theme triggers a full cascade: palette resolves,
    // all color roles rebind, every UI property binding updates.

    property int current: Colors.Theme.TokyoNight

    readonly property bool isDark:  Colors.isDark
    readonly property bool isLight: Colors.isLight

    // ─── Theme switching ──────────────────────────────────────────
    function setTheme(t) { current = t }
    function next() {
        const themes = Colors.availableThemes
        const idx = themes.findIndex(t => t.value === current)
        const nextIdx = (idx + 1) % themes.length
        current = themes[nextIdx].value
    }
    function previous() {
        const themes = Colors.availableThemes
        const idx = themes.findIndex(t => t.value === current)
        const prevIdx = (idx - 1 + themes.length) % themes.length
        current = themes[prevIdx].value
    }

    // ─── Propagate to Colors ──────────────────────────────────────
    onCurrentChanged: Colors.theme = current

    // ─── Token references (single import point) ──────────────────
    // Components can: Theme.colors.bg; Theme.spacing.md; Theme.radii.lg
    // Or import singletons directly: Colors.bg; Spacing.md; Radius.lg

    readonly property QtObject colors:     Colors
    readonly property QtObject typography: Typography
    readonly property QtObject spacing:    Spacing
    readonly property QtObject radii:      Radius
    readonly property QtObject animation:  Motion
    readonly property QtObject elevation:  Elevation

    // ─── Derived constants ────────────────────────────────────────

    readonly property real pillHeight: spacing.pill.height
    readonly property real pillWidth:  spacing.pill.width

    readonly property real panelMaxWidth:  spacing.panel.maxWidth
    readonly property real panelMinWidth:  spacing.panel.minWidth
    readonly property real panelMaxHeight: spacing.panel.maxHeight

    // ─── Theme metadata ───────────────────────────────────────────
    readonly property string key:   Colors.key
    readonly property string name:  Colors.name
    readonly property string label: Colors.label
}
