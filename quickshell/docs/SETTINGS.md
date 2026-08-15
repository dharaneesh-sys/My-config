# Settings

> Complete reference for all 63 SettingsStore properties.

---

## Property Reference

`Default` is the in-code default from `SettingsStore.qml`. `Current` is the live value in `settings.json` at the time of writing (2026-08-10). Runtime behavior follows the persisted value, not the code default.

### Config Version

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `configVersion` | `int` | `1` | `1` | System | SystemSettingsViewModel (display) | ConfigService._migrate() | ✅ | ❌ |

### Theme & Appearance

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `theme` | `string` | `"catppuccin-mocha"` | `"rose-pine"` | Appearance → Themes | AppearanceViewModel | ThemeService → Theme.setTheme → Colors cascade; shell.qml live bridge → ThemeState | ✅ | ✅ Live bridge |
| `wallpaper` | `string` | `""` | `"/home/dinusus/Pictures/Themes/Rose-Pine/ign_evening.png"` | Appearance → Wallpaper | AppearanceViewModel | WallpaperState.setWallpaperRequested → WallpaperService | ✅ | ✅ Live bridge |
| `wallpaperBackend` | `string` | `"awww"` | `"awww"` | Appearance → Wallpaper | AppearanceViewModel | WallpaperState.backend | ✅ | ✅ Live bridge → WallpaperState |
| `blurEnabled` | `bool` | `true` | `false` | Appearance, Bar & Pill | AppearanceViewModel, BarAndPillViewModel | ShellMetrics.panelBlurEnabled (no component binds it yet) | ✅ | ✅ ShellMetrics live-binding |
| `blurStrength` | `real` | `0.6` | `0.5016` | Appearance, Bar & Pill | AppearanceViewModel, BarAndPillViewModel | ShellMetrics.panelBlurStrength (no component binds it yet) | ✅ | ✅ ShellMetrics live-binding |
| `shellOpacity` | `real` | `1.0` | `0.4386` | Appearance, Bar & Pill | AppearanceViewModel, BarAndPillViewModel | ShellMetrics.shellOpacity (exposed; no component currently binds) | ✅ | ✅ ShellMetrics live-binding |
| `animationsEnabled` | `bool` | `true` | `true` | Appearance, Motion | AppearanceViewModel, MotionViewModel | MotionConfig.animationsEnabled → gates every PanelSurface Behavior | ✅ | ✅ Direct MotionConfig read |
| `animationSpeed` | `real` | `1.0` | `1.0321` | Appearance, Motion | AppearanceViewModel, MotionViewModel | MotionConfig.speedFactor = clamp(1/speed, ≥ 0.25) → scales all durations | ✅ | ✅ Direct MotionConfig read |

### Bar & Pill

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `pillWidth` | `real` | `136` | `123.14` | Bar & Pill | BarAndPillViewModel | ShellMetrics.pillWidth → PillPanel.width | ✅ | ✅ ShellMetrics live-binding |
| `pillHeight` | `real` | `48` | `31.54` | Bar & Pill | BarAndPillViewModel | ShellMetrics.pillHeight → PillPanel.height + strut | ✅ | ✅ ShellMetrics live-binding |
| `pillTopMargin` | `real` | `12` | `6.41` | Bar & Pill | BarAndPillViewModel | ShellMetrics.pillTopMargin → Shell.topMargin, PanelSurface y | ✅ | ✅ ShellMetrics live-binding |
| `pillBottomMargin` | `real` | `4` | `4` | Bar & Pill | BarAndPillViewModel | ShellMetrics.pillBottomMargin → pillReservedHeight | ✅ | ✅ ShellMetrics live-binding |
| `pillCornerRadius` | `real` | `9999` | `48` | Bar & Pill | BarAndPillViewModel | ShellMetrics.pillCornerRadius → PillPanel.surface radius | ✅ | ✅ ShellMetrics live-binding |

### Panels

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `panelMaxWidth` | `real` | `420` | `500.64` | Bar & Pill | BarAndPillViewModel | ShellMetrics.panelFullWidth → PanelSurface implicitWidth + full-width panels | ✅ | ✅ ShellMetrics live-binding |
| `panelPadding` | `real` | `16` | `16` | Bar & Pill | BarAndPillViewModel | ShellMetrics.expandedPadding → PanelSurface loader margins, panel height | ✅ | ✅ ShellMetrics live-binding |
| `panelCornerRadius` | `real` | `16` | `16` | Bar & Pill | BarAndPillViewModel | PanelSurface.panelRect radius | ✅ | ✅ Direct SettingsStore read |
| `panelBlur` | `bool` | `true` | `true` | Bar & Pill | BarAndPillViewModel | (reserved for Hyprland blur rules) | ✅ | ❌ |

### Control Center

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `ccShowQuickToggles` | `bool` | `true` | `true` | Control Center | ControlCenterSettingsViewModel | (deferred: CC sections not yet conditional) | ✅ | ❌ |
| `ccShowVolume` | `bool` | `true` | `true` | Control Center | ControlCenterSettingsViewModel | (deferred) | ✅ | ❌ |
| `ccShowBrightness` | `bool` | `true` | `true` | Control Center | ControlCenterSettingsViewModel | (deferred) | ✅ | ❌ |
| `ccShowMedia` | `bool` | `true` | `true` | Control Center | ControlCenterSettingsViewModel | (deferred) | ✅ | ❌ |
| `ccShowNotifications` | `bool` | `true` | `true` | Control Center | ControlCenterSettingsViewModel | (deferred) | ✅ | ❌ |
| `ccShowBattery` | `bool` | `true` | `true` | Control Center | ControlCenterSettingsViewModel | (deferred) | ✅ | ❌ |

### Launcher

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `launcherMaxResults` | `int` | `8` | `7` | Launcher | LauncherSettingsViewModel | LauncherViewModel (result count) | ✅ | ❌ |
| `launcherShowDescriptions` | `bool` | `true` | `false` | Launcher | LauncherSettingsViewModel | LauncherViewModel (description visibility) | ✅ | ❌ |
| `launcherDefaultAction` | `string` | `"launch"` | `"launch"` | Launcher | LauncherSettingsViewModel | LauncherState (launch vs terminal) | ✅ | ❌ |

### Notifications

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `notificationPosition` | `string` | `"top-right"` | `"top-right"` | Notifications | NotificationSettingsViewModel | NotificationState (native server) | ✅ | ❌ |
| `notificationMaxVisible` | `int` | `5` | `4` | Notifications | NotificationSettingsViewModel | NotificationState | ✅ | ❌ |
| `notificationTimeout` | `int` | `5000` | `5000` | Notifications | NotificationSettingsViewModel | NotificationState (auto-dismiss, ms) | ✅ | ❌ |
| `notificationShowBody` | `bool` | `true` | `true` | Notifications | NotificationSettingsViewModel | NotificationState | ✅ | ❌ |
| `notificationShowActions` | `bool` | `true` | `false` | Notifications | NotificationSettingsViewModel | NotificationState | ✅ | ❌ |

### Media

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `mediaShowAlbumArt` | `bool` | `true` | `true` | Media | MediaSettingsViewModel | MediaState / MediaPlayerViewModel (artwork visibility) | ✅ | ❌ |
| `mediaShowProgress` | `bool` | `true` | `true` | Media | MediaSettingsViewModel | MediaState / MediaPlayerViewModel (progress visibility) | ✅ | ❌ |
| `mediaPreferredPlayer` | `string` | `""` | `""` | Media | MediaSettingsViewModel | MediaState (player filter; empty = auto) | ✅ | ❌ |

### Clock & Date

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `clockUse24h` | `bool` | `true` | `false` | Clock & Date | ClockDateSettingsViewModel | ClockState.use24h → PillPanel clock | ✅ | ✅ Live bridge → ClockState |
| `clockShowSeconds` | `bool` | `false` | `false` | Clock & Date | ClockDateSettingsViewModel | ClockState.showSeconds → PillPanel clock | ✅ | ✅ Live bridge → ClockState |
| `clockTimezone` | `string` | `""` | `""` | Clock & Date | ClockDateSettingsViewModel | ClockState.timezone (empty = system) | ✅ | ✅ Live bridge → ClockState |
| `clockDateFormat` | `string` | `"long"` | `"short"` | Clock & Date | ClockDateSettingsViewModel | ClockState.dateFormat (long | short | iso) | ✅ | ✅ Live bridge → ClockState |
| `clockShowInPill` | `bool` | `true` | `true` | Clock & Date | ClockDateSettingsViewModel | PillPanel.visible (clock or notice) | ✅ | ✅ Direct SettingsStore read |

### Audio

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `audioStepPercent` | `int` | `5` | `5` | — | — | AudioState (volume step per scroll/click) | ✅ | ❌ |
| `audioShowInput` | `bool` | `true` | `true` | — | — | AudioViewModel (input slider visibility) | ✅ | ❌ |

### Brightness

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `brightnessStepPercent` | `int` | `5` | `5` | — | — | BrightnessState (step per scroll) | ✅ | ❌ |

### Network

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `wifiAutoConnect` | `bool` | `true` | `true` | — | — | NetworkState (auto-connect behavior) | ✅ | ❌ |

### Power

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `powerAutoSuspendMinutes` | `int` | `0` | `0` | — | — | PowerState (idle timer; 0 = disabled) | ✅ | ❌ |
| `powerAutoScreenOffMinutes` | `int` | `0` | `0` | — | — | PowerState (idle timer; 0 = disabled) | ✅ | ❌ |
| `powerShowBatteryInCC` | `bool` | `true` | `true` | — | — | ControlCenterViewModel (battery row visibility) | ✅ | ❌ |

### Motion / Transitions

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `springDamping` | `real` | `1.4` | `1.4` | Motion | MotionViewModel | MotionConfig.spring.damping | ✅ | ✅ Direct MotionConfig read |
| `springStiffness` | `real` | `2.4` | `2.4` | Motion | MotionViewModel | MotionConfig.spring.stiffness | ✅ | ✅ Direct MotionConfig read |
| `expandDuration` | `int` | `300` | `290` | Motion | MotionViewModel | Motion page slider + presets; System page reset | ✅ | ❌ |
| `collapseDuration` | `int` | `300` | `289` | Motion | MotionViewModel | Motion page slider + presets; System page reset | ✅ | ❌ |

The four spring/duration settings are wired at runtime through `motion/MotionConfig.qml`. `springDamping` and `springStiffness` feed `MotionConfig.spring.{damping,stiffness}`; `animationsEnabled` and `animationSpeed` feed the `MotionConfig` gate and `speedFactor`. Panel animators in `PanelSurface` source their durations from the frozen `Motion` tokens scaled by `MotionConfig.duration()`, so the `expandDuration`/`collapseDuration` ints are the page-editable configured values rather than a direct binding.

### Keybinds

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `keybindLauncher` | `string` | `"Super+Space"` | `"Super+Space"` | Keybinds | KeybindsSettingsViewModel | IpcHandler.updateKeybind() → hyprctl | ✅ | ✅ Live bridge → IpcHandler |
| `keybindThemeSwitcher` | `string` | `"Super+T"` | `"Super+T"` | Keybinds | KeybindsSettingsViewModel | IpcHandler.updateKeybind() → hyprctl | ✅ | ✅ Live bridge → IpcHandler |
| `keybindWallpaperSelector` | `string` | `"Super+W"` | `"Super+W"` | Keybinds | KeybindsSettingsViewModel | IpcHandler.updateKeybind() → hyprctl | ✅ | ✅ Live bridge → IpcHandler |
| `keybindNotificationCenter` | `string` | `"Super+N"` | `"Super+N"` | Keybinds | KeybindsSettingsViewModel | IpcHandler.updateKeybind() → hyprctl | ✅ | ✅ Live bridge → IpcHandler |
| `keybindMedia` | `string` | `"Super+M"` | `"Super+M"` | Keybinds | KeybindsSettingsViewModel | IpcHandler.updateKeybind() → hyprctl | ✅ | ✅ Live bridge → IpcHandler |
| `keybindSettings` | `string` | `"Super+Comma"` | `"Super+Comma"` | Keybinds | KeybindsSettingsViewModel | IpcHandler.updateKeybind() → hyprctl | ✅ | ✅ Live bridge → IpcHandler |

### System

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `wallpaperDirectory` | `string` | `"/home/dinusus/Pictures/Wallpapers"` | `"/home/dinusus/Pictures/Wallpapers"` | Appearance → Wallpaper | AppearanceViewModel | WallpaperService.wallpaperDir → find wallpapers | ✅ | ✅ Live bridge → WallpaperService |

### Window State

Persisted so the Settings window and last-visited page survive restarts.

| Property | Type | Default | Current | Page | ViewModel | Runtime Consumer | Persistence | Live |
|---|---|---|---|---|---|---|---|---|
| `settingsX` | `real` | `-1` | `-1` | — | — | (reserved; position is compositor-managed) | ✅ | ❌ |
| `settingsY` | `real` | `-1` | `-1` | — | — | (reserved; position is compositor-managed) | ✅ | ❌ |
| `settingsW` | `real` | `800` | `1428` | — | — | SettingsWindow.implicitWidth; onWidthChanged writes back | ✅ | ✅ SettingsWindow write-back |
| `settingsH` | `real` | `600` | `846` | — | — | SettingsWindow.implicitHeight; onHeightChanged writes back | ✅ | ✅ SettingsWindow write-back |
| `settingsPageId` | `string` | `""` | `"bar-pill"` | — | — | SettingsRouter.navigate() at startup | ✅ | ✅ Router write-back |

---

## Persistence Details

- **Format:** JSON (2-space indent)
- **Path:** `StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/settings.json"` (set in `shell.qml`, read by `ConfigService`)
- **Write pattern:** `FileView` with `atomicWrites: true` (tmp + rename via `Quickshell.Io`); writes go through the `JsonAdapter` then `configFile.writeAdapter()`
- **Debounce:** 500ms after last `settingsChanged()` (`saveDebounce` Timer in ConfigService)
- **Dirty tracking:** `SettingsStore._connectAll()` connects the `Changed` signal of every writable property to `settingsChanged()`. It uses an **explicit property-name array** (62 entries) instead of `Object.keys()`, which the comment notes is unreliable for QML-declared properties. `configVersion` is deliberately excluded.
- **Version migration:** `ConfigService._migrate()` runs after deserialization; currently at version 1 (`_currentVersion = 1`)
- **Known keys:** `SettingsSerializer._knownKeys` holds 63 keys (all 63 store properties). Unknown keys in the file are preserved, not deleted.
- **Load:** `FileView.onLoaded → _pullFromDisk()` copies known keys into SettingsStore, then `_applyToRuntime()` pushes theme/wallpaper/clock into the State singletons
- **Import/Export:** `ConfigService.importSettings(json)` (validates, deserializes, migrates, applies, saves) / `ConfigService.exportSettings()` → JSON string
- **Validation:** `SettingsSerializer.validate(json)` reports known/unknown key counts; import rejects invalid JSON
- **Reset to Defaults:** System page → `SystemSettingsViewModel._resetToDefaults()` restores 58 properties (everything except the five window-state entries)

## Live Update Mechanism

SettingsStore changes propagate to runtime three ways:

1. **Live bridge** (in `shell.qml`): `Connections { target: SettingsStore }` with named handlers for theme, wallpaper, wallpaperBackend, wallpaperDirectory, the four clock settings, and the six keybinds. These push into ThemeState/WallpaperState/ClockState and `IpcHandler.updateKeybind()`.
2. **Direct bindings**: ShellMetrics reads SettingsStore directly (pill/panel dimensions, blur, opacity); PillPanel reads `clockShowInPill`; PanelSurface reads `panelCornerRadius` and all four motion settings via MotionConfig; SettingsWindow reads `settingsW`/`settingsH` and writes them back on resize.
3. **One-shot apply at load**: `ConfigService._applyToRuntime()` pushes persisted theme/wallpaper/clock values into the State singletons when the config is first read.

No shell reload is needed for any setting change.
