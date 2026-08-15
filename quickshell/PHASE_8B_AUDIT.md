# Phase 8B — Persistent Settings Architecture: Audit

## New Files

| File | Role |
|---|---|
| `settings/SettingsStore.qml` | Singleton. Owns all 58 configurable preferences. No runtime state references. |
| `settings/SettingsSerializer.qml` | Singleton. Converts SettingsStore ↔ JSON. 58 known keys. Validates. |
| `services/ConfigService.qml` | Singleton. Loads/saves config file. Debounced save. Version migration. Import/export. |

## Architecture

```
SettingsStore (58 persistent properties)
       ↕ SettingsSerializer (JSON ↔ Store)
ConfigService (load/save/migrate/import/export)
       ↓ _applyToRuntime()
Runtime State singletons (ClockState, WallpaperState, …)
```

## Separation Rule

| Layer | Persistent? | Example | Owner |
|---|---|---|---|
| **SettingsStore** | ✅ Yes | `theme: "tokyo-night"` | Settings pages edit this |
| **Runtime State** | ❌ No | `AudioState.volume: 0.5` | Services write this from OS |
| **Bridge** | One-way | `ClockState.use24h = SettingsStore.clockUse24h` | ConfigService pushes on load |

---

## Complete Settings Table

| # | Setting | Store Property | Type | Default | Persistence | Runtime Consumer |
|---|---------|---------------|------|---------|-------------|-----------------|
| 1 | Config version | `configVersion` | int | 1 | ✅ JSON | ConfigService (migration) |
| 2 | Theme | `theme` | string | "tokyo-night" | ✅ JSON | ThemeState (via ConfigService) |
| 3 | Wallpaper path | `wallpaper` | string | "" | ✅ JSON | WallpaperState |
| 4 | Wallpaper backend | `wallpaperBackend` | string | "swww" | ✅ JSON | WallpaperState.backend |
| 5 | Blur enabled | `blurEnabled` | bool | true | ✅ JSON | Shell window |
| 6 | Blur strength | `blurStrength` | real | 0.6 | ✅ JSON | Shell window |
| 7 | Shell opacity | `shellOpacity` | real | 1.0 | ✅ JSON | Shell window |
| 8 | Animations enabled | `animationsEnabled` | bool | true | ✅ JSON | Animation tokens |
| 9 | Animation speed | `animationSpeed` | real | 1.0 | ✅ JSON | Animation tokens |
| 10 | Pill width | `pillWidth` | real | 136 | ✅ JSON | ShellMetrics |
| 11 | Pill height | `pillHeight` | real | 48 | ✅ JSON | ShellMetrics |
| 12 | Pill top margin | `pillTopMargin` | real | 12 | ✅ JSON | ShellMetrics |
| 13 | Pill bottom margin | `pillBottomMargin` | real | 4 | ✅ JSON | ShellMetrics |
| 14 | Pill corner radius | `pillCornerRadius` | real | 9999 | ✅ JSON | TopPill |
| 15 | Panel max width | `panelMaxWidth` | real | 420 | ✅ JSON | ShellMetrics |
| 16 | Panel padding | `panelPadding` | real | 16 | ✅ JSON | ShellMetrics |
| 17 | Panel corner radius | `panelCornerRadius` | real | 16 | ✅ JSON | ExpandedSurface |
| 18 | Panel blur | `panelBlur` | bool | true | ✅ JSON | ExpandedSurface |
| 19 | CC show quick toggles | `ccShowQuickToggles` | bool | true | ✅ JSON | ControlCenter |
| 20 | CC show volume | `ccShowVolume` | bool | true | ✅ JSON | ControlCenter |
| 21 | CC show brightness | `ccShowBrightness` | bool | true | ✅ JSON | ControlCenter |
| 22 | CC show media | `ccShowMedia` | bool | true | ✅ JSON | ControlCenter |
| 23 | CC show notifications | `ccShowNotifications` | bool | true | ✅ JSON | ControlCenter |
| 24 | CC show battery | `ccShowBattery` | bool | true | ✅ JSON | ControlCenter |
| 25 | Launcher max results | `launcherMaxResults` | int | 8 | ✅ JSON | LauncherViewModel |
| 26 | Launcher show descriptions | `launcherShowDescriptions` | bool | true | ✅ JSON | Launcher panel |
| 27 | Launcher default action | `launcherDefaultAction` | string | "launch" | ✅ JSON | Launcher panel |
| 28 | Notification position | `notificationPosition` | string | "top-right" | ✅ JSON | Notification overlay |
| 29 | Notification max visible | `notificationMaxVisible` | int | 5 | ✅ JSON | Notification overlay |
| 30 | Notification timeout | `notificationTimeout` | int | 5000 | ✅ JSON | NotificationService |
| 31 | Notification show body | `notificationShowBody` | bool | true | ✅ JSON | NotificationCard |
| 32 | Notification show actions | `notificationShowActions` | bool | true | ✅ JSON | NotificationCard |
| 33 | Media show album art | `mediaShowAlbumArt` | bool | true | ✅ JSON | MediaMiniCard |
| 34 | Media show progress | `mediaShowProgress` | bool | true | ✅ JSON | MediaPlayer |
| 35 | Media preferred player | `mediaPreferredPlayer` | string | "" | ✅ JSON | MediaService |
| 36 | Clock 24h format | `clockUse24h` | bool | true | ✅ JSON | ClockState.use24h |
| 37 | Clock show seconds | `clockShowSeconds` | bool | false | ✅ JSON | ClockState.showSeconds |
| 38 | Clock timezone | `clockTimezone` | string | "" | ✅ JSON | ClockState.timezone |
| 39 | Clock date format | `clockDateFormat` | string | "long" | ✅ JSON | ClockState.dateFormat |
| 40 | Clock show in pill | `clockShowInPill` | bool | true | ✅ JSON | TopPill |
| 41 | Audio step % | `audioStepPercent` | int | 5 | ✅ JSON | AudioService |
| 42 | Audio show input | `audioShowInput` | bool | true | ✅ JSON | Audio panel |
| 43 | Brightness step % | `brightnessStepPercent` | int | 5 | ✅ JSON | BrightnessService |
| 44 | WiFi auto-connect | `wifiAutoConnect` | bool | true | ✅ JSON | NetworkService |
| 45 | Auto suspend (min) | `powerAutoSuspendMinutes` | int | 0 | ✅ JSON | PowerService |
| 46 | Auto screen off (min) | `powerAutoScreenOffMinutes` | int | 0 | ✅ JSON | PowerService |
| 47 | Show battery in CC | `powerShowBatteryInCC` | bool | true | ✅ JSON | ControlCenter |
| 48 | Spring damping | `springDamping` | real | 0.7 | ✅ JSON | Animation tokens |
| 49 | Spring stiffness | `springStiffness` | real | 1.5 | ✅ JSON | Animation tokens |
| 50 | Expand duration | `expandDuration` | int | 300 | ✅ JSON | ExpandedSurface |
| 51 | Collapse duration | `collapseDuration` | int | 300 | ✅ JSON | ExpandedSurface |
| 52 | Keybind: launcher | `keybindLauncher` | string | "Super+Space" | ✅ JSON | IpcHandler |
| 53 | Keybind: theme | `keybindThemeSwitcher` | string | "Super+T" | ✅ JSON | IpcHandler |
| 54 | Keybind: wallpaper | `keybindWallpaperSelector` | string | "Super+W" | ✅ JSON | IpcHandler |
| 55 | Keybind: notifications | `keybindNotificationCenter` | string | "Super+N" | ✅ JSON | IpcHandler |
| 56 | Keybind: media | `keybindMedia` | string | "Super+M" | ✅ JSON | IpcHandler |
| 57 | Keybind: settings | `keybindSettings` | string | "Super+Comma" | ✅ JSON | IpcHandler |
| 58 | Wallpaper directory | `wallpaperDirectory` | string | "" | ✅ JSON | WallpaperService |

---

## ConfigService Capabilities

| Capability | Implementation |
|---|---|
| Load on startup | `readConfig` Process → `SettingsSerializer.deserialize()` → `_migrate()` → `_applyToRuntime()` |
| Save on change | `SettingsStore.settingsChanged` → `_scheduleSave()` → `saveDebounce` Timer (500ms) → `_doSave()` |
| Atomic write | Writes to `.tmp` then `mv` to final path |
| Create defaults | If no config file, uses SettingsStore's property defaults, saves immediately |
| Version migration | `_migrate()` checks `configVersion`, applies upgrade steps, sets latest |
| Import | `importSettings(json)` → validate → deserialize → migrate → apply → save |
| Export | `exportSettings()` → `SettingsSerializer.serialize(SettingsStore)` |

---

## Runtime State Bridge (one-way)

| SettingsStore Property | → | Runtime State Property | Applied When |
|---|---|---|---|
| `clockUse24h` | → | `ClockState.use24h` | Startup + import |
| `clockShowSeconds` | → | `ClockState.showSeconds` | Startup + import |
| `clockTimezone` | → | `ClockState.timezone` | Startup + import |
| `clockDateFormat` | → | `ClockState.dateFormat` | Startup + import |
| `wallpaperBackend` | → | `WallpaperState.backend` | Startup + import |

---

## Violations: None

| Check | Result |
|---|---|
| SettingsStore references any `*State` singleton | ✅ Zero |
| SettingsSerializer references any `*State` singleton | ✅ Zero |
| ConfigService writes to runtime state only in `_applyToRuntime` | ✅ Yes |
| SettingsStore property count = Serializer key count | ✅ 58 = 58 |
| All frozen Phase 8A files unchanged | ✅ Yes |
