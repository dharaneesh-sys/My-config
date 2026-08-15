import QtQuick

import qs.settings

QtObject {
    id: vm

    // ═══════════════════════════════════════════════════════════════
    //  MediaSettingsViewModel
    //
    //  Presentation adapter for the Media settings page.
    //  Reads SettingsStore for media configuration values.
    //  Formats display strings. All mutations write to SettingsStore.
    //
    //  • Reads:  SettingsStore
    //  • Writes: SettingsStore only
    //  • Emits:  nothing
    // ═══════════════════════════════════════════════════════════════

    // ── Album art ──────────────────────────────────────────────────
    readonly property bool showAlbumArt: SettingsStore.mediaShowAlbumArt

    // ── Progress ──────────────────────────────────────────────────
    readonly property bool showProgress: SettingsStore.mediaShowProgress

    // ── Preferred player ───────────────────────────────────────────
    readonly property string preferredPlayer: SettingsStore.mediaPreferredPlayer
    readonly property string preferredPlayerLabel: SettingsStore.mediaPreferredPlayer !== ""
                                                 ? SettingsStore.mediaPreferredPlayer
                                                 : "Auto-detect"

    // ── Actions (all write SettingsStore) ──────────────────────────
    function setShowAlbumArt(val)      { SettingsStore.mediaShowAlbumArt = val }
    function setShowProgress(val)      { SettingsStore.mediaShowProgress = val }
    function setPreferredPlayer(name)  { SettingsStore.mediaPreferredPlayer = name }
    function clearPreferredPlayer()    { SettingsStore.mediaPreferredPlayer = "" }
}
