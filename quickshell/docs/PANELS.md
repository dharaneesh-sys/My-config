# Panels

> Reference for all 11 expandable panels.

---

## Overview

Panels are pure view components loaded dynamically by `PanelSurface` (a `PanelWindow`) via `ExpansionRegistry`. `PanelSurface` hosts a `Loader` whose `source` resolves to the active panel through `ExpansionRegistry.componentFor()`. Panels are registered in `shell.qml` `Component.onCompleted`; they compose molecules and read from ViewModels. Panels never import `qs.services` — they only read State through their ViewModel.

The panel content sits inside `panelRect` (a `Rectangle` with a `Region` mask), so the floating surface stays mapped while only the rect animates in height/opacity.

---

## Panel Reference

### Registration (shell.qml → ExpansionRegistry)

| Panel | ID | Width | Height |
|---|---|---|---|
| Launcher | `launcher` | `ShellMetrics.launcherWidth` = panelFullWidth (live `panelMaxWidth`) | 520 |
| Control Center | `control-center` | `ShellMetrics.controlCenterWidth` = 340 | 520 |
| Theme Switcher | `theme-switcher` | `ShellMetrics.themeSwitcherWidth` = 300 | 260 |
| Wallpaper Selector | `wallpaper-selector` | `ShellMetrics.wallpaperSelectorWidth` = 680 | 520 |
| Notification Center | `notification-center` | `ShellMetrics.notificationCenterWidth` = panelFullWidth | 520 |
| Media Player | `media-player` | `ShellMetrics.mediaPlayerWidth` = 340 | 300 |
| Calendar | `calendar` | `ShellMetrics.calendarWidth` = 340 | 400 |
| Bluetooth | `bluetooth` | `ShellMetrics.bluetoothWidth` = 340 | 420 |
| Wi-Fi | `wifi` | `ShellMetrics.wifiWidth` = panelFullWidth | 420 |
| Audio | `audio` | `ShellMetrics.audioWidth` = 340 | 300 |
| Power Menu | `power-menu` | `ShellMetrics.powerMenuWidth` = 280 | 260 |

`panelFullWidth` is live from `SettingsStore.panelMaxWidth` (default 420).

---

### Launcher

| Field | Value |
|---|---|
| **ID** | `launcher` |
| **Shortcut** | `Super+Space` |
| **Width / Height** | panelFullWidth / 520 |
| **ViewModel** | LauncherViewModel |
| **State Read** | LauncherState |

**Composition:** SearchBar (auto-focused on open, up/down/Enter keyboard nav), Repeater of AppRow, "more results" indicator, empty-state ShellText. Result list scrolls inside the panel (height clamped to 520).

**Settings affecting it:** `launcherMaxResults`, `launcherShowDescriptions`, `launcherDefaultAction`

---

### ControlCenter

| Field | Value |
|---|---|
| **ID** | `control-center` |
| **Shortcut** | Pill click, or `Super+I` |
| **Width / Height** | 340 / 520 |
| **ViewModel** | ControlCenterViewModel |
| **State Read** | AudioState, BrightnessState, NetworkState, BluetoothState, MediaState, NotificationState, BatteryState, ThemeState |

**Composition:** PanelHeader, QuickSettingsGridModel (Wi-Fi, Bluetooth, DND, Theme tiles), volume SmoothSliderRow, brightness SmoothSliderRow, DynamicBatteryWidget, MediaMiniCard, PowerActionsRow.

**Settings affecting it:** `ccShowQuickToggles`, `ccShowVolume`, `ccShowBrightness`, `ccShowMedia`, `ccShowBattery` (each section is conditionally visible)

---

### ThemeSwitcher

| Field | Value |
|---|---|
| **ID** | `theme-switcher` |
| **Shortcut** | `Super+T` |
| **Width / Height** | 300 / 260 |
| **ViewModel** | ThemeSwitcherViewModel |
| **State Read** | ThemeState |

**Composition:** "Theme" title, GridView of ThemeCard (3-column grid, each card shows bg/accent/surface color dots), arrow-key navigation + Enter to select.

**Settings affecting it:** `theme` (selection state)

---

### WallpaperSelector

| Field | Value |
|---|---|
| **ID** | `wallpaper-selector` |
| **Shortcut** | `Super+W` (theme scope) / `Super+Shift+I` (all scope) |
| **Width / Height** | 680 / 520 |
| **ViewModel** | WallpaperSelectorViewModel |
| **State Read** | WallpaperState |

**Composition:** "Wallpaper" title, 6-column Grid of WallpaperCard (thumbnail previews), empty-state ShellText. Scope is set by `IpcHandler.expandWallpapers(scope)` before expanding.

**Settings affecting it:** `wallpaper`, `wallpaperBackend`, `wallpaperDirectory`

---

### NotificationCenter

| Field | Value |
|---|---|
| **ID** | `notification-center` |
| **Shortcut** | `Super+N` |
| **Width / Height** | panelFullWidth / 520 |
| **ViewModel** | NotificationCenterViewModel |
| **State Read** | NotificationState |

**Composition:** PanelHeader (subtitle = unread count), DND ToggleRow, Repeater of NotificationCard (dismiss / mark-read), "Clear All" ShellButton, empty-state ShellText.

**Settings affecting it:** `notificationShowBody`, `notificationShowActions`, `notificationMaxVisible`

---

### MediaPlayer

| Field | Value |
|---|---|
| **ID** | `media-player` |
| **Shortcut** | `Super+M` |
| **Width / Height** | 340 / 300 |
| **ViewModel** | MediaPlayerViewModel |
| **State Read** | MediaState (also reads ClockState for the clock column) |

**Composition:** Compact single-purpose bar: 48×48 artwork frame, title/artist, transport buttons (previous / play-pause / next), and a clock column (time, day-of-week + date, 7-day strip centered on today).

**Settings affecting it:** `mediaShowAlbumArt`, `mediaShowProgress`, `mediaPreferredPlayer`

---

### Calendar

| Field | Value |
|---|---|
| **ID** | `calendar` |
| **Shortcut** | None (programmatic only) |
| **Width / Height** | 340 / 400 |
| **ViewModel** | CalendarViewModel |
| **State Read** | ClockState |

**Composition:** PanelHeader, long date (title), day of week, time (heading), 24-hour format ToggleRow, Show seconds ToggleRow.

**Settings affecting it:** `clockDateFormat`, `clockTimezone`, `clockUse24h`, `clockShowSeconds`

---

### Bluetooth

| Field | Value |
|---|---|
| **ID** | `bluetooth` |
| **Shortcut** | None (programmatic only) |
| **Width / Height** | 340 / 420 |
| **ViewModel** | BluetoothViewModel |
| **State Read** | BluetoothState |

**Composition:** PanelHeader (subtitle = connection status), enable ToggleRow, scan ShellButton, device list of SettingRow (Connect/Pair/Disconnect), status/error ShellText, empty-state ShellText.

**Settings affecting it:** None

---

### WiFi

| Field | Value |
|---|---|
| **ID** | `wifi` |
| **Shortcut** | None (programmatic only) |
| **Width / Height** | panelFullWidth / 420 |
| **ViewModel** | WiFiViewModel |
| **State Read** | NetworkState |

**Composition:** PanelHeader (subtitle = connection status), enable ToggleRow, "Scan for networks" ShellButton, current-connection SettingRow (with Disconnect), inline password prompt (TextInput + Cancel/Connect), status/error ShellText, "Available Networks" list of SettingRow.

**Settings affecting it:** `wifiAutoConnect`

---

### Audio

| Field | Value |
|---|---|
| **ID** | `audio` |
| **Shortcut** | None (programmatic only) |
| **Width / Height** | 340 / 300 |
| **ViewModel** | AudioViewModel |
| **State Read** | AudioState |

**Composition:** PanelHeader, output SmoothSliderRow, mute ToggleRow, device-name SettingRow, "Input" SectionHeader, microphone SmoothSliderRow, mute-mic ToggleRow.

**Settings affecting it:** `audioStepPercent`, `audioShowInput`

---

### PowerMenu

| Field | Value |
|---|---|
| **ID** | `power-menu` |
| **Shortcut** | None (opened from the Control Center) |
| **Width / Height** | 280 / 260 |
| **ViewModel** | PowerMenuViewModel |
| **State Read** | PowerState |

**Composition:** PanelHeader, ShellButton ×4 (Lock, Suspend, Reboot, Shutdown).

**Settings affecting it:** None

---

## Expansion Behavior Summary

| Trigger | Mechanism |
|---|---|
| Keybind | Hyprland → `quickshell ipc call shell expand <id>` → `IpcHandler.expand(id)` → `ExpansionManager.requestExpand(id)` |
| Wallpaper scope | `Super+W` / `Super+Shift+I` → `quickshell ipc call shell expandWallpapers theme\|all` → `IpcHandler.expandWallpapers(scope)` (sets `WallpaperState.scope`) → `requestExpand("wallpaper-selector")` |
| Pill click | `PillPanel.onClicked` → `ExpansionManager.requestExpand("control-center")` |
| Focus loss | `HyprlandFocusGrab` (tracks `panelSurface`, active while `isExpanded`) goes inactive → 50 ms `focusGrabCollapseTimer` → `requestCollapse()` if still `Expanded` |
| Escape | `Shortcut` (Qt.WindowShortcut) in `PanelSurface` + `Keys.onEscapePressed` on `panelRect` → `requestCollapse()` |
| Same panel toggle | `Expanded + requestExpand(sameId)` → `requestCollapse()` |
| Different panel | `Expanded + requestExpand(otherId)` → `Switching` lifecycle |
