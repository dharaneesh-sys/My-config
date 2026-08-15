# Services

> Reference for the 5 remaining service singletons.

---

## Overview

Services communicate with the OS via `Process` IPC (Quickshell.Io). They write to State singletons and respond to State signals via `Connections`. Services are instantiated in `shell.qml` and start their poll timers on creation.

Only five services remain as `services/*.qml` files (module `qs.services`). The other eight former services no longer exist as service files: their functionality is provided by native Quickshell Qt services wrapped by the `state/` singletons.

---

## Native Bindings

**The shell's layer split:**

| Layer | Role |
|---|---|
| `services/` (`qs.services`) | 5 singletons that talk to external CLIs and the config file |
| `state/` (`qs.state`) | All UI-visible singletons, including 8 that wrap native Quickshell Qt services |
| `viewmodels/` (`qs.viewmodels`) | Presentation adapters: read State, emit user actions as State signals |
| `panels/` (`qs.panels`) | Pure views. Panels **never import** `qs.services` |

**MVVM wiring pattern:**

1. A ViewModel emits a State signal (e.g. `AudioState.setVolumeRequested(0.5)`).
2. The State singleton either handles it natively (PipeWire node, UPower, BlueZ, MPRIS, NetworkManager) or forwards it to a Service via `Connections`.
3. The Service runs a `Process`, parses output on `onExited`, and writes results back to State.

The eight former services that became native bindings:

| Former Service | Current Home | Native Binding |
|---|---|---|
| AudioService | `AudioState` | `Quickshell.Services.Pipewire` (default sink/source nodes) |
| BatteryService | `BatteryState` | `Quickshell.Services.UPower` (`displayDevice`) |
| BluetoothService | `BluetoothState` | `Quickshell.Bluetooth` (BlueZ) |
| NetworkService | `NetworkState` | `Quickshell.Networking` (NetworkManager) |
| MediaService | `MediaState` | `Quickshell.Services.Mpris` |
| NotificationService | `NotificationState` | `Quickshell.Services.Notifications` (owns `org.freedesktop.Notifications` from shell startup) |
| ClockService | `ClockState` | Native `SystemClock` (Seconds precision) |
| LauncherService | `LauncherState` | Native `DesktopEntries` (XDG desktop-file discovery) |

---

## BrightnessService

**State:** `BrightnessState`
**Backend:** `brightnessctl`

### Responsibilities
- Poll screen brightness level every 300 ms
- Poll keyboard backlight level every 300 ms
- Execute brightness change requests

### IPC Commands
| Purpose | Command |
|---|---|
| Get screen brightness | `brightnessctl info` (parses `(N%)` from output) |
| Set screen brightness | `brightnessctl set <N>%` |
| Get keyboard backlight | `brightnessctl -d kbd_backlight info` |
| Set keyboard backlight | `brightnessctl -d kbd_backlight set <N>%` |

### Wiring
- `BrightnessState.setBrightnessRequested(value)` → `brightnessctl set <pct>%`
- `BrightnessState.setKbdBrightnessRequested(value)` → `brightnessctl -d kbd_backlight set <pct>%`

Results are parsed on `Process.onExited` (not `onStreamFinished`), so the real exit code is available and failed reads never corrupt State.

---

## ConfigService

**State:** `SettingsStore` (via `SettingsSerializer`)
**Backend:** Filesystem JSON via `Quickshell.Io` `FileView` + `JsonAdapter`

### Responsibilities
- Load configuration at startup
- Save on change (debounced 500 ms)
- Create defaults if no config file exists
- Handle version migration
- Support import/export

### File Operations
- **Path:** `StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/quickshell/settings.json"` (set from `shell.qml`)
- **Read:** `FileView` with `preload: true`; on load, `_pullFromDisk()` copies every key in `SettingsSerializer._knownKeys` into `SettingsStore`, then runs `_migrate()` and `_applyToRuntime()`
- **Write:** `_pushToDisk()` copies `SettingsStore` → `JsonAdapter`, then `configFile.writeAdapter()`. Writes are atomic via `FileView.atomicWrites: true` (tmp + rename handled by Quickshell, no shell involved)
- **Debounce:** `saveDebounce` timer restarts on each `SettingsStore.settingsChanged`, fires 500 ms after the last change
- **Defaults:** every `JsonAdapter` property doubles as the default; when the file is missing or unreadable, `_onLoadFailed()` applies defaults and persists them so the file exists next session
- **Migration:** `_migrate()` — currently at `_currentVersion: 1` (`configVersion` lives on the adapter and in `SettingsStore`); future migrations chain here

### Public Methods
| Method | Action |
|---|---|
| `exportSettings()` | Returns `SettingsSerializer.serialize(SettingsStore)` as a JSON string |
| `importSettings(json)` | Validates, deserializes, migrates, applies to runtime, and saves; returns `true` on success |
| `_applyToRuntime()` | Bridges SettingsStore → Theme, WallpaperState, ClockState at startup (one-way) |

### `_applyToRuntime()` Bridges
- **Theme →** `Theme.setTheme` + `ThemeState.currentTheme`
- **Wallpaper →** `WallpaperState.backend` + `WallpaperState.setWallpaperRequested`
- **Clock →** `ClockState.use24h`, `.showSeconds`, `.timezone`, `.dateFormat`
- **ShellMetrics** is live-bound to `SettingsStore` (pill/panel dimensions, blur, opacity, animation durations need no bridge)

---

## PowerService

**State:** `PowerState`
**Backend:** `hyprlock`, `loginctl`, `Quickshell`, `systemctl`, `xdg-open`, `foot` + `journalctl`

### Responsibilities
- Execute lock, suspend, reboot, shutdown
- Handle shell management: reload, restart, quit
- Open config directory, show logs

### IPC Commands
| Action | Command |
|---|---|
| Lock | `sh -c "pidof hyprlock >/dev/null || exec hyprlock"` (also sets `PowerState.locked`) |
| Suspend | `loginctl suspend` |
| Reboot | `loginctl reboot` |
| Shutdown | `loginctl poweroff` |
| Reload shell | `Quickshell.reload()` (via `Qt.callLater`) |
| Restart shell | `systemctl --user restart quickshell` |
| Quit shell | `Qt.quit()` |
| Open config dir | `xdg-open <ConfigLocation>/quickshell` |
| Show logs | `sh -c "foot -e journalctl --user -u quickshell -f &"` |

### Wiring
`PowerState.lockRequested`, `.suspendRequested`, `.rebootRequested`, `.shutdownRequested`, `.reloadShellRequested`, `.restartShellRequested`, `.quitShellRequested`, `.openConfigDirRequested`, `.showLogsRequested` → service.

---

## ThemeService

**State:** `ThemeState`
**Backend:** `~/.local/bin/theme-list`, `~/.local/bin/theme-switcher`, file watchers

### Responsibilities
- List real system themes via `theme-list` (JSON lines `{name, color, icon, active}` → `ThemeState.systemThemes`)
- Apply a theme system-wide via `theme-switcher <name>`
- Persist the theme key (`SettingsStore.theme`)
- Watch `~/.cache/wallpaper/current_theme` (the canonical cache written by theme-switcher) via `FileView` and mirror it into `ThemeState.systemTheme` + the frozen `Theme`/`Colors` tokens
- Fall back to `~/.config/hypr/colors.conf` (`# Theme: <name>` comment, written by matugen) at startup when the cache is missing
- Revert to the cached theme if `theme-switcher` fails

### Public Methods
| Method | Action |
|---|---|
| `next()` / `previous()` | Cycle through real themes (falls back to `Colors.availableThemes` before `theme-list` returns) |
| `refreshThemes()` | Re-run `theme-list` |
| `applySystemTheme(name)` | Optimistically sync shell + persist, then run `theme-switcher <name>` |

### Wiring
`ThemeState.setThemeRequested`, `.setSystemThemeRequested`, `.nextRequested`, `.previousRequested` → service.

---

## WallpaperService

**State:** `WallpaperState`
**Backend:** `awww` (the same daemon matuwall uses) + shared `~/.cache/wallpaper/` state files

### Responsibilities
- List wallpapers from the active directory via `find` (png, jpg, jpeg, webp, gif, bmp, avif)
- Build small preview thumbnails once with ImageMagick `magick` (240×140 webp) into `~/.cache/quickshell/wallpaper-thumbnails`, reused on every panel open
- Apply a wallpaper via `awww img <path> --transition-type random --transition-step 18 --transition-fps 60 --transition-duration 2.5`
- Write the shared `~/.cache/wallpaper/last_wallpaper` cache so every wallpaper app on the system agrees, and watch it (`FileView`) for external changes
- When the active theme is `Dynamic`, run `wallpaper-to-theme.sh` (matugen → theme-switcher) after applying

### Scope
- `"all"` → the configured `wallpaperDir` (Super+W default scope)
- `"theme"` → `~/Pictures/Themes/<active theme>/` (Super+Shift+I)
- `wallpaperDir` property fed from `SettingsStore.wallpaperDirectory` (live bridge from `shell.qml`)

### Wiring
`WallpaperState.setWallpaperRequested`, `.setBackendRequested`, `.setScopeRequested`, `.refreshRequested` → service. `ThemeState.systemThemeChanged` re-points the theme-scoped list live.

---

## Retired Services

The former `AudioService`, `BatteryService`, `BluetoothService`, `NetworkService`, `MediaService`, `NotificationService`, `ClockService`, and `LauncherService` files are gone. Their responsibilities moved into the native bindings table above; the only processes still spawned in those domains are:

- `rfkill unblock bluetooth` (BluetoothState, before enabling a soft-blocked adapter)
- `nmcli -t -f NAME,TYPE connection show` (NetworkState, saved-profile list)
- `nmcli --wait 20 connection up id <ssid>` / `nmcli device wifi connect <ssid> [password <pw>]` (NetworkState, connect)
