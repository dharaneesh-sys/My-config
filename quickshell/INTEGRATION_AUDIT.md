# Integration Audit — Architectural Compliance

## Dependency Chain (Enforced)

```
Panel       →  ViewModel  →  State  →  Service  →  OS
```

No layer may bypass the layer below it.

---

## Panel → ViewModel → State → Service Mapping

| Panel | ViewModel | State(s) Read | Service(s) |
|---|---|---|---|
| ControlCenter | ControlCenterViewModel | AudioState, BrightnessState, NetworkState, BluetoothState, MediaState, NotificationState, BatteryState, ThemeState, ExpansionManager | AudioService, BrightnessService, NetworkService, BluetoothService, MediaService, NotificationService, BatteryService, ThemeService |
| Launcher | LauncherViewModel | LauncherState | LauncherService |
| ThemeSwitcher | ThemeSwitcherViewModel | ThemeState, Colors (token) | ThemeService |
| WallpaperSelector | WallpaperSelectorViewModel | WallpaperState | WallpaperService |
| NotificationCenter | NotificationCenterViewModel | NotificationState | NotificationService |
| MediaPlayer | MediaPlayerViewModel | MediaState | MediaService |
| Calendar | CalendarViewModel | ClockState | ClockService |
| Bluetooth | BluetoothViewModel | BluetoothState | BluetoothService |
| WiFi | WiFiViewModel | NetworkState | NetworkService |
| Audio | AudioViewModel | AudioState | AudioService |
| PowerMenu | PowerMenuViewModel | PowerState | PowerService |

---

## Violation Scan Results

| Check | Result |
|---|---|
| Panels importing `qs.state` | ✅ None |
| Panels importing `qs.services` | ✅ None |
| Panels using `Process {}` directly | ✅ None |
| Panels referencing `*State` singletons | ✅ None |
| ViewModels importing `qs.services` | ✅ None |
| ViewModels using `Process {}` | ✅ None |
| State singletons importing `qs.services` | ✅ None |
| All 11 panels have a ViewModel | ✅ Yes |
| PowerMenu no longer executes Process | ✅ Yes (delegates to PowerState → PowerService) |

---

## New Files Added

| File | Purpose |
|---|---|
| `state/PowerState.qml` | Reactive power state (locked, suspending) + action signals |
| `services/PowerService.qml` | Executes loginctl commands, wires to PowerState |
| `viewmodels/ThemeSwitcherViewModel.qml` | Formats themes for display |
| `viewmodels/WallpaperSelectorViewModel.qml` | Formats wallpapers, computes selected/empty |
| `viewmodels/NotificationCenterViewModel.qml` | Formats notifications, header subtitle, DND |
| `viewmodels/MediaPlayerViewModel.qml` | Formats time, progress, players, shuffle/repeat |
| `viewmodels/CalendarViewModel.qml` | Formats time/date display, settings toggles |
| `viewmodels/BluetoothViewModel.qml` | Formats devices, header, scan label, empty state |
| `viewmodels/WiFiViewModel.qml` | Formats networks, strength label, header subtitle |
| `viewmodels/AudioViewModel.qml` | Formats volume %, icons, device presence |
| `viewmodels/PowerMenuViewModel.qml` | Emits intent only (lock/suspend/reboot/shutdown) |

---

## Refactored Files

| File | Change |
|---|---|
| `panels/ControlCenter.qml` | Removed direct BatteryState/ExpansionManager references; all actions via vm |
| `panels/Launcher.qml` | Removed direct LauncherState reference; uses vm.isLaunching(), vm.showEmptyState |
| `panels/ThemeSwitcher.qml` | Removed direct ThemeState/Colors; reads vm.themes, vm.selectTheme() |
| `panels/WallpaperSelector.qml` | Removed direct WallpaperState; reads vm.wallpapers, vm.isEmpty |
| `panels/NotificationCenter.qml` | Removed direct NotificationState; reads vm.* |
| `panels/MediaPlayer.qml` | Removed direct MediaState + _formatTime(); reads vm.* |
| `panels/Calendar.qml` | Removed direct ClockState; reads vm.* |
| `panels/Bluetooth.qml` | Removed direct BluetoothState; reads vm.* |
| `panels/WiFi.qml` | Removed direct NetworkState; reads vm.* |
| `panels/Audio.qml` | Removed direct AudioState + Math.round formatting; reads vm.* |
| `panels/PowerMenu.qml` | Removed Process instances + Quickshell.Io import; reads vm.* |
| `viewmodels/ControlCenterViewModel.qml` | Added battery properties + action methods |
| `viewmodels/LauncherViewModel.qml` | Added isLaunching(), showEmptyState, moreResultsText |
| `shell.qml` | Added PowerService {} instantiation |
| `state/qmldir` | Added PowerState singleton |
| `services/qmldir` | Added PowerService singleton |
| `viewmodels/qmldir` | Added all 9 new ViewModels |

---

## Data Flow Verification

### Pattern: UI → ViewModel → State → Service → OS

```
User clicks "Lock" in PowerMenu
  → PowerMenu.qml:  vm.lock()
    → PowerMenuViewModel:  PowerState.lockRequested()
      → PowerState:  signal lockRequested() emitted
        → PowerService (Connections):  PowerState.locked = true; lockProcess.running = true
          → Process:  loginctl lock-session
```

```
User drags volume slider in Audio panel
  → Audio.qml:  vm.setVolume(newValue)
    → AudioViewModel:  AudioState.setVolumeRequested(vol)
      → AudioState:  signal setVolumeRequested(real) emitted
        → AudioService (Connections):  audioService.setVolume(v)
          → Process:  pactl set-sink-volume @DEFAULT_SINK@ <v>
```

```
User toggles WiFi in ControlCenter quick tile
  → ControlCenter.qml:  vm.quickTiles[0].onClicked()
    → ControlCenterViewModel:  NetworkState.setWifiEnabledRequested(!wifiEnabled)
      → NetworkState:  signal setWifiEnabledRequested(bool) emitted
        → NetworkService (Connections):  networkService.setWifiEnabled(e)
          → Process:  nmcli radio wifi on/off
```

Every action follows this chain. No shortcuts exist.

---

## Remaining Work (Not in Scope)

- Phase 8: Settings pages (13 content pages + ViewModels + sidebar wiring)
- Phase 9: Polish (mask, focus grab, animation tuning, multi-monitor)
