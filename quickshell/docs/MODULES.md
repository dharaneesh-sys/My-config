# Modules

> Reference documentation for every module in the shell.

---

## tokens

**Path:** `tokens/`
**Module name:** `Tokens` (imported as `qs.tokens`)
**Status:** FROZEN — never modify

### Purpose

Design system providing all semantic color roles, typography scales, spacing values, radii, motion configurations, and elevation levels. Every visual property in the shell derives from these tokens.

### Singletons

| Singleton | Purpose | Key Properties |
|---|---|---|
| `Colors` | Semantic color roles + theme switching | `bg`, `fg`, `accent`, `surface`, `pillBg`, `hoverOverlay`, `availableThemes`, `setTheme()`, `paletteForKey()` |
| `Typography` | Font families + text style presets | `families.*`, `heading`, `title`, `body`, `caption`, `clock`, `button`, `mono`, … |
| `Spacing` | All spatial measurements derived from `unit` (4.0) | `unit`, `xs`–`xxxl`, `pill.*`, `panel.*`, `settings.*`, … |
| `Radius` | All corner radii derived from `unit` | `pill.background` (9999), `panel.background` (16), `card.background` (12), … |
| `Motion` | Duration scale, easing curves, spring configs, semantic presets | `duration.*`, `easing.*`, `spring.*`, `panel.*`, `pill.*`, `opacity.*` |
| `Elevation` | Shadow levels, z-ordering, blur/overlay opacity | `level0`–`level4`, `z.*`, `overlay.*`, `blur.*`, `pill.borderWidth`, … |
| `Theme` | Theme orchestration — switching, metadata, palette resolver | `current`, `setTheme()`, `next()`, `previous()`, `key`, `label` |

> **Note:** the animation token was renamed from `Animation` to `Motion`. The token itself stays FROZEN; runtime animation overrides live in the separate `qs.motion` module (`MotionConfig`).

### Palette Singletons (13)

Located in `tokens/palettes/`. Each provides color values plus metadata (`name`, `label`, `isDark`). `Colors.availableThemes` exposes all 13 entries; the enum default is `TokyoNight` (the live `settings.json` currently sets `"theme": "rose-pine"`).

| Palette | Key | Dark |
|---|---|---|
| Ariadne | `ariadne` | ✅ |
| Catppuccin Macchiato | `catppuccin-macchiato` | ✅ |
| Catppuccin Mocha | `catppuccin-mocha` | ✅ |
| Dracula | `dracula` | ✅ |
| Dynamic | `dynamic` | ✅ |
| Everforest | `everforest` | ✅ |
| Gruvbox | `gruvbox` | ✅ |
| Nightfox | `nightfox` | ✅ |
| Noir | `noir` | ✅ |
| Nord | `nord` | ✅ |
| Rosé Pine | `rose-pine` | ✅ |
| Solarized Dark | `solarized-dark` | ✅ |
| Tokyo Night | `tokyo-night` | ✅ |

### Dependencies

None — this is the root of the dependency tree.

### Dependents

Every other module imports tokens.

---

## metrics

**Path:** `metrics/`
**Module name:** `Metrics` (imported as `qs.metrics`)
**Status:** Live-bound to SettingsStore

### Purpose

Centralizes all shell layout dimensions. No other file may hardcode panel widths, pill sizes, or margins — they reference `ShellMetrics`.

### Singleton

**ShellMetrics** — all dimensions are `readonly property` with live bindings to SettingsStore:

| Property | Source | Default | Live |
|---|---|---|---|
| `pillWidth` | `SettingsStore.pillWidth` | 136 | ✅ |
| `pillHeight` | `SettingsStore.pillHeight` | 48 | ✅ |
| `pillTopMargin` | `SettingsStore.pillTopMargin` | 12 | ✅ |
| `pillBottomMargin` | `SettingsStore.pillBottomMargin` | 4 | ✅ |
| `pillCornerRadius` | `SettingsStore.pillCornerRadius` | 9999 | ✅ |
| `pillReservedHeight` | derived: `ceil(topMargin + height + bottomMargin)` | — | ✅ |
| `pillBottomEdge` | derived: `topMargin + height` | — | ✅ |
| `expandedPadding` | `SettingsStore.panelPadding` | 16 | ✅ |
| `expandedWidth` | `SettingsStore.panelMaxWidth` | 420 | ✅ |
| `panelSurfaceHeight` | hardcoded | 600 | ❌ |
| `panelBlurEnabled` | `SettingsStore.blurEnabled` | true | ✅ |
| `panelBlurStrength` | `SettingsStore.blurStrength` | 0.6 | ✅ |
| `shellOpacity` | `SettingsStore.shellOpacity` | 1.0 | ✅ |
| `panelFullWidth` | `SettingsStore.panelMaxWidth` | 420 | ✅ |
| `panelCompactWidth` | hardcoded | 340 | ❌ |
| `panelNarrowWidth` | hardcoded | 280 | ❌ |
| `sidebarWidth` | `Spacing.settings.sidebarWidth` | 80 | ❌ |

Plus per-panel width aliases and settings window dimensions:

| Alias | Value |
|---|---|
| `launcherWidth` | `panelFullWidth` (live) |
| `controlCenterWidth` | 340 |
| `themeSwitcherWidth` | 300 |
| `wallpaperSelectorWidth` | 680 |
| `notificationCenterWidth` | `panelFullWidth` (live) |
| `mediaPlayerWidth` | 340 |
| `calendarWidth` | 340 |
| `bluetoothWidth` | 340 |
| `wifiWidth` | `panelFullWidth` (live) |
| `audioWidth` | 340 |
| `powerMenuWidth` | 280 |

Settings window dimensions (`settingsDefaultWidth`, `settingsDefaultHeight`, `settingsMinWidth`, `settingsMinHeight`, `sidebarWidth`) come from `Spacing.settings.*`.

### Dependencies

`qs.tokens`, `qs.settings`

### Dependents

`windows/`, `components/`, `panels/`, `settings/`, `shell.qml`

---

## motion

**Path:** `motion/`
**Module name:** `Motion` (imported as `qs.motion`)
**Status:** Runtime animation override layer

### Purpose

`tokens/Motion.qml` is FROZEN and cannot become writable, so this module is the sanctioned runtime animation override layer. All non-frozen motion in the shell consumes durations and spring parameters from here, so `SettingsStore.animationSpeed` / `animationsEnabled` / `spring*` actually drive the animation system.

### Singleton

**MotionConfig** — provides:

| Property / Method | Behavior |
|---|---|
| `animationsEnabled` | Live from `SettingsStore.animationsEnabled` |
| `speedFactor` | `clamp(1 / animationSpeed, min 0.25)` — higher speed means shorter durations |
| `duration(ms)` | Scales the input by `speedFactor`, or returns `0` when animations are disabled |
| `spring` | `{ stiffness, damping, mass: 1.0, epsilon: 0.25 }` — live from `SettingsStore.springStiffness` / `springDamping` |

### Dependencies

`qs.settings`

### Dependents

`windows/PanelSurface.qml`, `components/PillPanel.qml`, and any animated component that must respect the Motion settings page.

---

## state

**Path:** `state/`
**Module name:** `State` (imported as `qs.state`)

### Purpose

Reactive state singletons. Written by Services (or bound to native Quickshell services), read by ViewModels. The single source of truth for runtime data.

### Native Binding Mapping

Audio, Battery, Bluetooth, Network, Media, Launcher, Notification, and Clock are **no longer services**. They are native Quickshell bindings inside the state singletons:

| State | Native Binding |
|---|---|
| `AudioState` | `Quickshell.Services.Pipewire` |
| `BatteryState` | `Quickshell.Services.UPower` |
| `BluetoothState` | `Quickshell.Bluetooth` |
| `NetworkState` | `Quickshell.Networking` |
| `MediaState` | `Quickshell.Services.Mpris` |
| `LauncherState` | `Quickshell` `DesktopEntries` |
| `NotificationState` | `Quickshell.Services.Notifications` |
| `ClockState` | `Quickshell` `SystemClock` |

### Singletons (16)

| Singleton | Category | Key Properties | Key Signals |
|---|---|---|---|
| `ExpansionRegistry` | Navigation | `_entries`, `count`, `register()`, `lookup()`, `componentFor()`, `widthFor()`, `heightFor()` | — |
| `ExpansionManager` | Navigation | `activePanelId`, `lifecycle`, `isExpanded`, `isInteractive`, `previousPanelId` | — |
| `SettingsState` | Navigation | `isOpen`, `currentPage`, `pages` | — |
| `AudioState` | Hardware | `volume`, `muted`, `sourceVolume`, `deviceName` | `setVolumeRequested`, `setMutedRequested`, `setSourceVolumeRequested`, `setSourceMutedRequested` |
| `BrightnessState` | Hardware | `brightness`, `kbdBrightness` | `setBrightnessRequested`, `setKbdBrightnessRequested` |
| `BatteryState` | Hardware | `percentage`, `charging`, `state`, `acConnected` | — |
| `BluetoothState` | Hardware | `enabled`, `scanning`, `devices`, `connectedDevice` | `setEnabledRequested`, `connectRequested`, `disconnectRequested`, `pairRequested`, `unpairRequested`, `scanRequested` |
| `NetworkState` | Hardware | `wifiEnabled`, `connected`, `ssid`, `availableNetworks`, `wiredConnected` | `setWifiEnabledRequested`, `connectRequested`, `disconnectRequested`, `scanRequested` |
| `MediaState` | Media | `title`, `artist`, `playing`, `position`, `length`, `players` | `playPauseRequested`, `nextRequested`, `previousRequested`, `seekRequested`, `setShuffleRequested`, `setRepeatRequested`, `setActivePlayerRequested` |
| `WallpaperState` | Appearance | `currentWallpaper`, `wallpapers`, `backend`, `scope` | `setWallpaperRequested`, `setBackendRequested`, `setScopeRequested`, `refreshRequested` |
| `ThemeState` | Appearance | `currentTheme`, `currentKey`, `isDark`, `systemTheme`, `systemThemes` | `setThemeRequested`, `setSystemThemeRequested`, `nextRequested`, `previousRequested` |
| `LauncherState` | Apps | `applications`, `query`, `filteredApplications`, `pinned`, `recent` | `setQueryRequested`, `launchRequested`, `pinRequested`, `unpinRequested` |
| `NotificationState` | Notifications | `notifications`, `unreadCount`, `dnd` | `dismissRequested`, `dismissAllRequested`, `markReadRequested`, `markAllReadRequested`, `setDndRequested` |
| `ClockState` | Time | `time`, `timeSeconds`, `date`, `use24h`, `showSeconds`, `timezone`, `dateFormat` | `set24hRequested`, `setShowSecondsRequested`, `setTimezoneRequested`, `setDateFormatRequested` |
| `PowerState` | System | `locked`, `suspending` | `lockRequested`, `suspendRequested`, `rebootRequested`, `shutdownRequested`, `reloadShellRequested`, `restartShellRequested`, `quitShellRequested`, `openConfigDirRequested`, `showLogsRequested` |
| `IconRegistry` | Apps | `ready`, `iconSource(name)` | — |

`IconRegistry` is the newest singleton. It indexes desktop-entry icon names to `file://` URLs by running `find` once over the standard icon directories (user icons first, then hicolor, then Papirus/breeze/Adwaita), preferring scalable SVGs. `iconSource(name)` returns `""` until the index is built, so callers fall back to a Material glyph.

### Dependencies

`qs.tokens` (ThemeState, ExpansionManager), native Quickshell service modules

### Dependents

`services/`, `viewmodels/`, `windows/`, `components/`, `shell.qml`

---

## services

**Path:** `services/`
**Module name:** `Services` (imported as `qs.services`)

### Purpose

Service singletons that communicate with the OS via Process IPC. Write to State singletons. Never imported by panels or settings pages.

**Exactly 5 services remain.** Audio, Battery, Bluetooth, Network, Media, Launcher, Notification, and Clock are native Quickshell bindings inside `state/` (see the mapping table above) — they are not services anymore.

### Singletons

| Service | State Written | Backend Command(s) |
|---|---|---|
| `BrightnessService` | BrightnessState | `brightnessctl info`, `brightnessctl set`, `brightnessctl -d kbd_backlight …` |
| `WallpaperService` | WallpaperState | `find` (listing), `awww img` (apply), `magick` (thumbnails), shared `~/.cache/wallpaper/last_wallpaper` |
| `ThemeService` | ThemeState | `theme-list`, `theme-switcher`, `~/.cache/wallpaper/current_theme` watcher |
| `PowerService` | PowerState | `loginctl lock-session/suspend/reboot/poweroff`, `hyprlock`, `systemctl --user restart quickshell`, `xdg-open`, `Quickshell.reload()`, `Qt.quit()` |
| `ConfigService` | SettingsStore | `FileView` + `JsonAdapter` (atomic writes, no shell) |

### Wiring Pattern

Every service uses `Connections { target: SomeState; onSignalRequested() { ... } }` to respond to State signals.

### Dependencies

`qs.state`, `qs.tokens`, `qs.settings` (ConfigService, ThemeService, WallpaperService), `Quickshell.Io`

### Dependents

`shell.qml` (instantiates all services)

---

## viewmodels

**Path:** `viewmodels/`
**Module name:** `Viewmodels` (imported as `qs.viewmodels`)

### Purpose

Presentation adapters between State/SettingsStore and the UI. Format, sort, and derive display data. Never execute Process or import Services.

### Panel ViewModels (read State)

| ViewModel | Panel | State Read |
|---|---|---|
| `ControlCenterViewModel` | ControlCenter | Audio, Brightness, Network, Bluetooth, Media, Notification, Battery, Theme |
| `LauncherViewModel` | Launcher | LauncherState |
| `ThemeSwitcherViewModel` | ThemeSwitcher | ThemeState |
| `WallpaperSelectorViewModel` | WallpaperSelector | WallpaperState |
| `NotificationCenterViewModel` | NotificationCenter | NotificationState |
| `MediaPlayerViewModel` | MediaPlayer | MediaState |
| `CalendarViewModel` | Calendar | ClockState |
| `BluetoothViewModel` | Bluetooth | BluetoothState |
| `WiFiViewModel` | WiFi | NetworkState |
| `AudioViewModel` | Audio | AudioState |
| `PowerMenuViewModel` | PowerMenu | PowerState |

### Settings ViewModels (read SettingsStore)

| ViewModel | Page | State Access |
|---|---|---|
| `AppearanceViewModel` | Appearance | SettingsStore, ThemeState, WallpaperState, Colors |
| `BarAndPillViewModel` | Bar & Pill | SettingsStore only |
| `MotionViewModel` | Motion | SettingsStore only |
| `ControlCenterSettingsViewModel` | Control Center | SettingsStore only |
| `LauncherSettingsViewModel` | Launcher | SettingsStore only |
| `NotificationSettingsViewModel` | Notifications | SettingsStore only |
| `ClockDateSettingsViewModel` | Clock & Date | SettingsStore only |
| `MediaSettingsViewModel` | Media | SettingsStore only |
| `KeybindsSettingsViewModel` | Keybinds | SettingsStore only |
| `AboutViewModel` | About | SettingsStore (configVersion, theme) |
| `SystemSettingsViewModel` | System | SettingsStore + PowerState |

### Dependencies

`qs.state`, `qs.settings`, `qs.tokens`

### Dependents

`panels/`, `settings/`

---

## atoms

**Path:** `components/atoms/`
**Module name:** `Atoms` (imported as `qs.components.atoms`)
**Status:** FROZEN — never modify

### Purpose

Primitive leaf components. The smallest reusable UI building blocks.

### Components (10)

| Atom | Purpose | Key API |
|---|---|---|
| `PillShape` | Rounded pill container | `contentData` |
| `ShellIcon` | Material Symbols icon | `name`, `iconSize`, `iconColor` |
| `ShellText` | Text with semantic roles | `role`, `text`, `textColor` |
| `AppIcon` | App icon (IconRegistry-backed) | `name`, `iconSize` |
| `ShellButton` | Clickable button (icon + text) | `text`, `iconName`, `active`, `disabled`, `clicked()` |
| `ShellToggle` | Toggle switch | `checked`, `toggled()` |
| `ShellSlider` | Horizontal slider | `from`, `to`, `value`, `moved(real)` |
| `SmoothSlider` | Slider with smooth value animation | `from`, `to`, `value`, `moved(real)` |
| `SectionHeader` | Card section title | `text` |
| `ListItem` | Row with leading + trailing slots | `iconName`, `title`, `subtitle`, `trailing` |

### Dependencies

`qs.tokens`

### Dependents

`molecules/`, `panels/`, `settings/`, `components/PillPanel.qml`

---

## molecules

**Path:** `components/molecules/`
**Module name:** `Molecules` (imported as `qs.components.molecules`)
**Status:** FROZEN — never modify

### Purpose

Composite components built from atoms. Domain-specific UI patterns.

### Components (18)

| Molecule | Purpose | Key API |
|---|---|---|
| `PanelHeader` | Panel top bar | `title`, `iconName` |
| `SearchBar` | Search input field | `query`, `placeholder`, `queryChanged()`, `accepted()` |
| `QuickToggle` | Quick settings tile | `iconName`, `title`, `subtitle`, `active`, `clicked()` |
| `SliderRow` | Icon + title + slider + value | `iconName`, `title`, `from`, `to`, `value`, `valueText`, `moved(real)` |
| `SmoothSliderRow` | Slider row with smooth value animation | `iconName`, `title`, `from`, `to`, `value`, `moved(real)` |
| `ToggleRow` | Icon + title + toggle | `iconName`, `title`, `subtitle`, `checked`, `toggled()` |
| `ButtonRow` | Horizontal button group | `buttons[]`, `buttonClicked(int)` |
| `SettingRow` | Generic row with trailing slot | `iconName`, `title`, `subtitle`, `trailing`, `clicked()` |
| `SettingsCard` | Card with header + body + footer | `headerText`, `bodyContent`, `footerContent` |
| `ThemeCard` | Theme preview swatch | `name`, `primaryColor`, `surfaceColor`, `selected`, `clicked()` |
| `WallpaperCard` | Wallpaper thumbnail | `name`, `thumbnailSource`, `selected`, `clicked()` |
| `MediaMiniCard` | Mini media player | `artworkSource`, `title`, `artist`, `playing`, `playPause()`, `next()`, `previous()` |
| `NotificationCard` | Notification item | `appName`, `iconName`, `title`, `body`, `urgency` |
| `AppRow` | Application search result | `appName`, `description`, `iconName`, `launching`, `clicked()` |
| `QuickSettingsGrid` | Grid of QuickToggle tiles | `tiles[]`, `tileClicked(int)` |
| `QuickSettingsGridModel` | Model backing the quick settings grid | `tiles[]` |
| `DynamicBatteryWidget` | Battery widget with dynamic icon | `percentage`, `charging`, `state` |
| `PowerActionsRow` | Power action buttons row | `onLock`, `onSuspend`, `onReboot`, `onShutdown` |

### Dependencies

`qs.tokens`, `qs.atoms`

### Dependents

`panels/`, `settings/`

---

## panels

**Path:** `panels/`
**Module name:** `Panels` (imported as `qs.panels`)

### Purpose

Pure view components displayed inside the PanelSurface window. Each panel composes molecules and reads from its ViewModel. Panels never import Services or execute Process.

### Panels (11)

Widths come from `ShellMetrics` aliases; heights are the registration heights passed to `ExpansionRegistry` in `shell.qml`.

| Panel | ViewModel | Width | Height |
|---|---|---|---|
| `Launcher` | LauncherViewModel | `launcherWidth` (live) | 520 |
| `ControlCenter` | ControlCenterViewModel | 340 | 520 |
| `ThemeSwitcher` | ThemeSwitcherViewModel | 300 | 260 |
| `WallpaperSelector` | WallpaperSelectorViewModel | 680 | 520 |
| `NotificationCenter` | NotificationCenterViewModel | `notificationCenterWidth` (live) | 520 |
| `MediaPlayer` | MediaPlayerViewModel | 340 | 300 |
| `Calendar` | CalendarViewModel | 340 | 400 |
| `Bluetooth` | BluetoothViewModel | 340 | 420 |
| `WiFi` | WiFiViewModel | `wifiWidth` (live) | 420 |
| `Audio` | AudioViewModel | 340 | 300 |
| `PowerMenu` | PowerMenuViewModel | 280 | 260 |

### Dependencies

`qs.tokens`, `qs.metrics`, `qs.molecules`, `qs.viewmodels`, `qs.atoms` (Bluetooth, MediaPlayer, WiFi also import `qs.state` for `ExpansionManager` / `ClockState`)

### Dependents

Loaded dynamically by `PanelSurface` via `ExpansionRegistry`

---

## settings

**Path:** `settings/`
**Module name:** `Settings` (imported as `qs.settings`)

### Purpose

Settings window components, persistent store, and serializer.

### Key Singletons

| Singleton | Purpose |
|---|---|
| `SettingsStore` | 64 persistent properties with dirty tracking (`settingsChanged()` signal) |
| `SettingsSerializer` | JSON ↔ Store conversion, known-key whitelist, validation |

### Navigation Components

| Component | Purpose |
|---|---|
| `SettingsRouter` | Navigation controller (reads SettingsState) |
| `SettingsSidebar` | Vertical icon+label nav rail |
| `SettingsStack` | StackLayout with lazy Loaders |
| `SettingsPage` | Page router (routes page ID → QML component) |
| `SettingsPageHeader` | Title + subtitle bar |
| `SettingsSearch` | Search field (query exposed, no filtering yet) |
| `SettingsPlaceholderPage` | Fallback for unimplemented pages |

### Content Pages (13/13)

| Page | ID | ViewModel |
|---|---|---|
| AppearancePage | `appearance` | AppearanceViewModel |
| ThemePage | `themes` | — (uses AppearanceViewModel via ThemeState) |
| WallpaperPage | `wallpaper` | — (uses AppearanceViewModel via WallpaperState) |
| BarAndPillPage | `bar-pill` | BarAndPillViewModel |
| MotionPage | `motion` | MotionViewModel |
| ControlCenterPage | `control-center` | ControlCenterSettingsViewModel |
| LauncherPage | `launcher` | LauncherSettingsViewModel |
| NotificationPage | `notifications` | NotificationSettingsViewModel |
| ClockDatePage | `clock-date` | ClockDateSettingsViewModel |
| MediaPage | `media` | MediaSettingsViewModel |
| KeybindsPage | `keybinds` | KeybindsSettingsViewModel |
| SystemPage | `system` | SystemSettingsViewModel |
| AboutPage | `about` | AboutViewModel |

### Dependencies

`qs.tokens`, `qs.metrics`, `qs.molecules`, `qs.atoms`, `qs.viewmodels`, `qs.state` (SettingsRouter, AppearancePage)

### Dependents

`windows/SettingsWindow.qml`

---

## windows

**Path:** `windows/`
**Module name:** `Windows` (imported as `qs.windows`)

### Purpose

The top-level windows. Four components are registered; three are instantiated by `shell.qml`.

### Components

| Window | QML Type | Description |
|---|---|---|
| `Shell` | `PanelWindow` | Full-width transparent top strip, `exclusionMode: Normal` (permanent strut), `focusable: false`. Content is `PillPanel` centered. Masked to the pill pixels. |
| `PanelSurface` | `PanelWindow` | Full-width transparent top strip, always visible, `exclusionMode: Ignore`, `aboveWindows: true`, `focusable: isExpanded`. Content is a centered `panelRect` (rounded, `Colors.bg`) with a Loader for the active panel; height animates 0 → content. Masked to `panelRect`. Escape collapses. |
| `SettingsWindow` | `FloatingWindow` | Visible bound to `SettingsState.isOpen`. Transparent background with rounded `Colors.bg` content (title bar, sidebar, search, page stack). Persists `settingsW`/`settingsH` to SettingsStore on resize; moved by Hyprland. |
| `LockScreen` | `WlSessionLock` | Compositor-backed session lock with PAM (`hyprlock` policy). **NOT instantiated by `shell.qml`** — unwired WIP. The "lock" IPC action runs `hyprlock` instead. |

### Dependencies

`qs.tokens`, `qs.metrics`, `qs.state`, `qs.settings`, `qs.components`, `qs.motion` (PanelSurface)

### Dependents

`shell.qml`

---

## keybinds

**Path:** `keybinds/`
**Module name:** `Keybinds` (imported as `qs.keybinds`)

### Purpose

Routes Hyprland keybind IPC calls to ExpansionManager and SettingsState. Supports dynamic keybind registration via hyprctl.

### Singleton

**IpcHandler** (`target: "shell"`) — provides:

| Method | Action |
|---|---|
| `expand(panelId)` | `ExpansionManager.requestExpand(panelId)` |
| `collapse()` | `ExpansionManager.requestCollapse()` |
| `lock()` | Runs `hyprlock` via `execDetached` (does NOT use LockScreen) |
| `expandWallpapers(scope)` | Sets `WallpaperState` scope (`"theme"` or `"all"`) then expands `wallpaper-selector` |
| `settingsOpen(pageId)` | `SettingsState.open(pageId)` |
| `settingsClose()` | `SettingsState.close()` |
| `settingsToggle()` | `SettingsState.toggle()` |
| `themeNext()` | `ThemeState.nextRequested()` |
| `themePrevious()` | `ThemeState.previousRequested()` |
| `updateKeybind(panelId, newShortcut)` | Dynamic hyprctl unbind/bind |

The dynamic keybind map `_keybinds` (panelId → shortcut) is initialized from SettingsStore and updated live via `updateKeybind()`, which runs `hyprctl keyword unbind` / `hyprctl keyword bind` Processes. `hyprlandConfigSnippet` is a reference string for `hyprland.conf` (not used at runtime).

### Dependencies

`Quickshell`, `Quickshell.Io`, `qs.state`, `qs.tokens`, `qs.settings`

### Dependents

`shell.qml`