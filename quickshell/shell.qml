import QtCore
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import qs.state
import qs.metrics
import qs.tokens
import qs.windows
import qs.keybinds
import qs.services
import qs.settings

ShellRoot {
    id: root

    // ═══════════════════════════════════════════════════════════════
    //  Quickshell Desktop Shell — Entry Point
    //
    //  Exactly three windows:
    //    1. Shell         — PanelWindow (pill bar, permanent strut)
    //    2. PanelSurface  — PanelWindow (floating expanded panel)
    //    3. Settings      — FloatingWindow (sidebar + pages)
    //
    //  No PopupWindow instances. No other top-level windows.
    // ═══════════════════════════════════════════════════════════════

    // ─── Window 1: Shell (pill bar) ───────────────────────────────
    Shell {
        id: shellWindow
    }

    // ─── Window 2: PanelSurface (floating expanded panel) ─────────
    PanelSurface {
        id: panelSurface
    }

    // ─── Window 3: Settings ──────────────────────────────────────
    SettingsWindow {
        id: settingsWindow
    }

    // ─── Icon font ───────────────────────────────────────────────
    // Material Symbols Rounded is a ligature variable font. Register
    // it explicitly with Qt's font database so ShellIcon's
    // `font.family: Typography.families.icons` resolves reliably
    // (avoids fontconfig matching quirks for variable TTF faces).
    FontLoader {
        id: shellIconFont
        source: "/usr/share/fonts/TTF/MaterialSymbolsRounded[FILL,GRAD,opsz,wght].ttf"
    }

    // ─── IPC handler ─────────────────────────────────────────────
    // Routes Hyprland keybind calls to ExpansionManager and SettingsState.
    // See IpcHandler.qml for the full hyprland.conf snippet.
    IpcHandler {
        id: ipcHandler
    }

    // ─── Services ────────────────────────────────────────────────
    // Only services without a native Quickshell equivalent remain.
    // Audio/Battery/Media/Clock/Bluetooth/Network/Launcher/Notification
    // are now native bindings inside the state/ singletons.
    // Services write to State singletons; UI reads State.
    // Panels never import Services — they only read State.

    BrightnessService {}
    WallpaperService {
        id: wallpaperServiceInstance
        wallpaperDir: SettingsStore.wallpaperDirectory
    }
    ThemeService {
        id: themeServiceInstance
    }
    PowerService {}
    ConfigService {
        id: configServiceInstance
        configPath: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/settings.json"
    }
    ClipboardService {}

    // ── Eager state instantiation ─────────────────────────────────
    // NotificationState is a lazily-created singleton; referencing it
    // here forces the native NotificationServer to own
    // org.freedesktop.Notifications from startup — not only after the
    // notification-center panel is first opened.
    readonly property var notificationStateRef: NotificationState
    // Keep night-light state alive from startup so the saved temperature is
    // reapplied even before the control center is opened.
    readonly property var nightLightStateRef: NightLightState
    // Eagerly load GameModeState so its startup sync (hyprctl getoption)
    // runs at boot, not on the first F1 press — avoids a race where the
    // sync could read pre-toggle state and flip the flag back.
    readonly property var gameModeStateRef: GameModeState

    // ═══════════════════════════════════════════════════════════════
    //  LIVE SETTINGS→RUNTIME BRIDGE
    //
    //  ConfigService._applyToRuntime() runs once at load.
    //  This Connections block propagates live SettingsStore changes
    //  to runtime State singletons so settings page edits take
    //  effect immediately without a shell reload.
    // ═══════════════════════════════════════════════════════════════

    Connections {
        target: SettingsStore

        // ── Theme ────────────────────────────────────────────
        function onThemeChanged() {
            var key = SettingsStore.theme
            var themes = Colors.availableThemes
            for (var i = 0; i < themes.length; i++) {
                if (themes[i].key === key) {
                    Theme.setTheme(themes[i].value)
                    ThemeState.currentTheme = themes[i].value
                    return
                }
            }
        }

        // ── Wallpaper ────────────────────────────────────────
        function onWallpaperChanged() {
            if (SettingsStore.wallpaper !== "")
                WallpaperState.setWallpaperRequested(SettingsStore.wallpaper)
        }

        function onWallpaperBackendChanged() {
            WallpaperState.backend = SettingsStore.wallpaperBackend
        }

        function onWallpaperDirectoryChanged() {
            wallpaperServiceInstance.setWallpaperDir(SettingsStore.wallpaperDirectory)
        }

        // ── Blur / Opacity ───────────────────────────────────
        // ShellMetrics reads SettingsStore directly — no bridge needed.
        // onBlurEnabledChanged, onBlurStrengthChanged, onShellOpacityChanged
        // all propagate through ShellMetrics → Shell bindings.

        // ── Animations ───────────────────────────────────────
        // ExpandedSurface reads SettingsStore.animationsEnabled,
        // .expandDuration, .collapseDuration directly — no bridge needed.

        // ── Clock ────────────────────────────────────────────
        function onClockUse24hChanged() {
            ClockState.use24h = SettingsStore.clockUse24h
        }

        function onClockShowSecondsChanged() {
            ClockState.showSeconds = SettingsStore.clockShowSeconds
        }

        function onClockTimezoneChanged() {
            ClockState.timezone = SettingsStore.clockTimezone
        }

        function onClockDateFormatChanged() {
            ClockState.dateFormat = SettingsStore.clockDateFormat
        }

        // ── Keybinds ─────────────────────────────────────────
        function onKeybindLauncherChanged() {
            ipcHandler.updateKeybind("launcher", SettingsStore.keybindLauncher)
        }

        function onKeybindThemeSwitcherChanged() {
            ipcHandler.updateKeybind("theme-switcher", SettingsStore.keybindThemeSwitcher)
        }

        function onKeybindWallpaperSelectorChanged() {
            ipcHandler.updateKeybind("wallpaper-selector", SettingsStore.keybindWallpaperSelector)
        }

        function onKeybindNotificationCenterChanged() {
            ipcHandler.updateKeybind("notification-center", SettingsStore.keybindNotificationCenter)
        }

        function onKeybindMediaChanged() {
            ipcHandler.updateKeybind("media-player", SettingsStore.keybindMedia)
        }

        function onKeybindSettingsChanged() {
            ipcHandler.updateKeybind("settings", SettingsStore.keybindSettings)
        }

        function onKeybindClipboardChanged() {
            ipcHandler.updateKeybind("clipboard", SettingsStore.keybindClipboard)
        }

        function onKeybindLyricsChanged() {
            ipcHandler.updateKeybind("lyrics", SettingsStore.keybindLyrics)
        }
    }

    // ─── Hyprland focus grab ─────────────────────────────────────
    // Dismisses the active panel when the user clicks outside the
    // PanelSurface (the interactive window while expanded).
    // Only active when the panel is in the Expanded lifecycle state.

    HyprlandFocusGrab {
        id: shellFocusGrab

        windows: [panelSurface]
        active: ExpansionManager.isExpanded

        onActiveChanged: {
            if (!active) {
                // Delay collapse slightly to avoid race with pill click.
                // When the user clicks a pill to switch panels, the focus
                // grab may go inactive before the pill's onClicked fires.
                // The timer allows the expand request to win over collapse.
                focusGrabCollapseTimer.start()
            }
        }
    }

    // ── Delayed collapse timer for focus grab ────────────────────
    // Only collapses if the lifecycle is still Expanded after the
    // delay — meaning no pill click (requestExpand) intervened.
    Timer {
        id: focusGrabCollapseTimer
        interval: 50
        onTriggered: {
            if (ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Expanded) {
                ExpansionManager.requestCollapse()
            }
        }
    }

    // ─── Panel registration ──────────────────────────────────────
    // All expandable panels register with ExpansionRegistry.
    // Adding a new panel only requires adding a register() call here.
    // ExpansionManager is never modified.

    Component.onCompleted: {
        ExpansionRegistry.register(
            "launcher",
            Qt.resolvedUrl("panels/Launcher.qml"),
            ShellMetrics.launcherWidth,
            520
        )

        ExpansionRegistry.register(
            "control-center",
            Qt.resolvedUrl("panels/ControlCenter.qml"),
            ShellMetrics.controlCenterWidth,
            520
        )

        ExpansionRegistry.register(
            "theme-switcher",
            Qt.resolvedUrl("panels/ThemeSwitcher.qml"),
            ShellMetrics.themeSwitcherWidth,
            260
        )

        ExpansionRegistry.register(
            "wallpaper-selector",
            Qt.resolvedUrl("panels/WallpaperSelector.qml"),
            ShellMetrics.wallpaperSelectorWidth,
            520
        )

        ExpansionRegistry.register(
            "notification-center",
            Qt.resolvedUrl("panels/NotificationCenter.qml"),
            ShellMetrics.notificationCenterWidth,
            520
        )

        ExpansionRegistry.register(
            "media-player",
            Qt.resolvedUrl("panels/MediaPlayer.qml"),
            ShellMetrics.mediaPlayerWidth,
            300
        )

        ExpansionRegistry.register(
            "calendar",
            Qt.resolvedUrl("panels/Calendar.qml"),
            ShellMetrics.calendarWidth,
            400
        )

        ExpansionRegistry.register(
            "bluetooth",
            Qt.resolvedUrl("panels/Bluetooth.qml"),
            ShellMetrics.bluetoothWidth,
            420
        )

        ExpansionRegistry.register(
            "wifi",
            Qt.resolvedUrl("panels/WiFi.qml"),
            ShellMetrics.wifiWidth,
            420
        )

        ExpansionRegistry.register(
            "audio",
            Qt.resolvedUrl("panels/Audio.qml"),
            ShellMetrics.audioWidth,
            300
        )

        ExpansionRegistry.register(
            "power-menu",
            Qt.resolvedUrl("panels/PowerMenu.qml"),
            ShellMetrics.powerMenuWidth,
            260
        )

        ExpansionRegistry.register(
            "clipboard",
            Qt.resolvedUrl("panels/Clipboard.qml"),
            ShellMetrics.clipboardWidth,
            520
        )

        ExpansionRegistry.register(
            "lyrics",
            Qt.resolvedUrl("panels/Lyrics.qml"),
            ShellMetrics.lyricsWidth,
            520
        )

        console.info("Shell: registered %1 panels".arg(ExpansionRegistry.count))
    }
}
