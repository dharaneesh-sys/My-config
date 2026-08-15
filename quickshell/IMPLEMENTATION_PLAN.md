# Quickshell Desktop Shell — Implementation Plan

## 0. Invariants (from specification)

```
WINDOWS     Exactly 2: Shell, SettingsWindow
POPUPS      None. Zero. No PopupWindow instances.
PANELS      All expand inline from the pill inside Shell.
SETTINGS    The only "popup-like" surface — but implemented as FloatingWindow.
OVERLAYS    None as separate windows. Dimming is an Item inside Shell.
```

## 1. Current State

```
shell/
└── tokens/          ← FROZEN design system (20 singletons, 13 palettes)
    ├── Colors.qml
    ├── Theme.qml
    ├── Typography.qml
    ├── Spacing.qml
    ├── Radius.qml
    ├── Animation.qml
    ├── Elevation.qml
    ├── qmldir
    └── palettes/
        ├── Ariadne.qml
        ├── CatppuccinMacchiato.qml
        ├── CatppuccinMocha.qml
        ├── Dracula.qml
        ├── Dynamic.qml
        ├── Everforest.qml
        ├── Gruvbox.qml
        ├── Nightfox.qml
        ├── Noir.qml
        ├── Nord.qml
        ├── RosePine.qml
        ├── SolarizedDark.qml
        └── TokyoNight.qml
```

No other files exist. The design system is the only implemented layer.

---

## 2. Window Architecture Audit

### 2.1 Shell — PanelWindow

| Property | Value | Rationale |
|---|---|---|
| `anchors.top` | `true` | Attached to top edge |
| `anchors.left` | `true` | Full width — content centers itself |
| `anchors.right` | `true` | Full width — content centers itself |
| `exclusionMode` | `ExclusionMode.Ignore` | Floating pill must NOT reserve space |
| `color` | `"transparent"` | Only the pill/panel region is opaque |
| `aboveWindows` | `true` | Shell sits above tiled windows |
| `focusable` | bound to `ExpansionManager.isExpanded` | Only grab focus when a panel needs input |
| `mask` | `Region { item: shellContent }` | Tells Hyprland which pixels are opaque — enables correct blur and prevents rendering empty transparent area |

**Critical architectural decision: full-width transparent PanelWindow.**

Why NOT a narrow centered PanelWindow:
- A full-width window gives us a natural click-outside target (the transparent area around the pill/panel).
- Centering via margins requires recalculating on every size change. Centering an Item inside a full-width window is trivial: `anchors.horizontalCenter: parent.horizontalCenter`.
- `mask: Region { item: ... }` tells Hyprland to only render/blur the opaque region, so the transparent area is zero-cost.
- Keyboard focus grab and release is simpler with a full-width surface.

### 2.2 Shell — Internal Layout

```
┌──────────────────── screen width ────────────────────┐
│                     (transparent)                     │
│              ┌──── shellContent ────┐                │
│              │     TopPill          │  ← always      │
│              │─────────────────────│                │
│              │  ExpandedSurface    │  ← conditional │
│              │  (active panel)     │                │
│              └────────────────────┘                │
│                     (transparent)                     │
│          (click-outside MouseArea)                    │
└──────────────────────────────────────────────────────┘
```

`shellContent` is a Column-centered Item. Its width is `max(pillWidth, activePanelWidth)`. Its height is `pillHeight + (expanded ? expandedHeight : 0)`.

The Shell window's `implicitHeight` is bound to `shellContent.height` plus top/bottom padding for visual margin from screen edge.

### 2.3 SettingsWindow — FloatingWindow

| Property | Value | Rationale |
|---|---|---|
| Type | `FloatingWindow` | Needs to be centered, draggable, resizable — impossible with PanelWindow or PopupWindow |
| `visible` | bound to `SettingsState.isOpen` | Show/hide on demand |
| `width` | `Theme.spacing.settings.defaultW` (576) | Default size from tokens |
| `height` | `Theme.spacing.settings.defaultH` (432) | Default size from tokens |
| `minimumWidth` | `Theme.spacing.settings.minWindowW` (336) | From tokens |
| `minimumHeight` | `Theme.spacing.settings.minWindowH` (288) | From tokens |
| `color` | `Colors.surface` | Opaque surface background |
| `HyprlandWindow.opacity` | not set (handled by Hyprland rules) | Let hyprland.conf handle blur |

**Why NOT PopupWindow:**
- PopupWindow requires an anchor to a parent window and cannot be freely positioned.
- PopupWindow cannot be dragged by the user.
- PopupWindow cannot be resized.
- Settings needs all three.

**Hyprland window rules (in hyprland.conf, not in QML):**
```
windowrule = float, class:quickshell, title:Settings
windowrule = size 576 432, class:quickshell, title:Settings
windowrule = center, class:quickshell, title:Settings
windowrule = pinned, class:quickshell, title:Settings
layerrule = blur, class:quickshell    # if blur desired on shell panels
```

### 2.4 SettingsWindow — Internal Layout

```
┌──────────────────────────────────────────┐
│  TitleBar (drag handle + close button)   │
│  ┌──────────┬───────────────────────────┐│
│  │ Sidebar  │     ContentPage           ││
│  │          │     (Loader)              ││
│  │ Bar&Pi…  │                          ││
│  │ Appear…  │                          ││
│  │ Themes   │                          ││
│  │ Wallpa…  │                          ││
│  │ Launcher │                          ││
│  │ Notifi…  │                          ││
│  │ Ctrl C…  │                          ││
│  │ Media    │                          ││
│  │ Clock&D… │                          ││
│  │ Motion   │                          ││
│  │ Keybinds │                          ││
│  │ System   │                          ││
│  │ About    │                          ││
│  └──────────┴───────────────────────────┘│
└──────────────────────────────────────────┘
```

---

## 3. Component Audit

### 3.1 Surfaces (visual containers that occupy window space)

| Component | Container | Exists When | Role |
|---|---|---|---|
| `TopPill` | Shell | Always | Clock display, click target for ControlCenter |
| `ExpandedSurface` | Shell | `ExpansionManager.isExpanded` | Loader for the active panel |
| `OverlayDim` | Shell | `ExpansionManager.isExpanded` | Semi-transparent click-outside target |

### 3.2 Panels (content loaded into ExpandedSurface)

| Panel | Trigger | Has Input? | Estimated Height |
|---|---|---|---|
| `Launcher` | Super+Space | Yes (search) | ~450 |
| `ControlCenter` | Pill click | No (toggles only) | ~360 |
| `ThemeSwitcher` | Super+T | No (grid selection) | ~300 |
| `WallpaperSelector` | Super+W | Yes (search) | ~400 |
| `NotificationCenter` | Super+N | No (buttons only) | ~450 |
| `MediaPlayer` | Super+M | No (controls only) | ~200 |
| `Calendar` | (from ControlCenter) | No | ~350 |
| `Bluetooth` | (from ControlCenter) | Yes (pairing) | ~300 |
| `WiFi` | (from ControlCenter) | Yes (password) | ~350 |
| `Audio` | (from ControlCenter) | No (sliders) | ~250 |
| `PowerMenu` | (from ControlCenter) | No (buttons) | ~180 |

### 3.3 Overlays / Dialogs

| Component | Type | Container | Trigger |
|---|---|---|---|
| `OverlayDim` | Semi-transparent Rectangle | Shell (behind panel) | Any panel expansion |
| No other overlays exist | | | |

### 3.4 Settings Pages (loaded into SettingsWindow)

| Page | ViewModel | Content |
|---|---|---|
| `BarPillPage` | `SettingsBarPillVm` | Pill height, clock format, pill visibility toggles |
| `AppearancePage` | `SettingsAppearanceVm` | Font family, font size, spacing scale, density |
| `ThemesPage` | `SettingsThemesVm` | Theme grid with live preview swatches, current indicator |
| `WallpaperPage` | `SettingsWallpaperVm` | Wallpaper grid, current selection, directory config |
| `LauncherPage` | `SettingsLauncherVm` | Pinned apps, search backend, result count |
| `NotificationsPage` | `SettingsNotificationsVm` | DND toggle, timeout, per-app filters |
| `ControlCenterPage` | `SettingsControlCenterVm` | Card order (drag), card visibility toggles |
| `MediaPage` | `SettingsMediaVm` | Default player, show/hide controls, position |
| `ClockDatePage` | `SettingsClockVm` | 12h/24h, date format, timezone, seconds toggle |
| `MotionPage` | `SettingsMotionVm` | Animation speed scale, spring stiffness/damping overrides |
| `KeybindsPage` | `SettingsKeybindsVm` | Shortcut list, conflict detection, remap UI |
| `SystemPage` | `SettingsSystemVm` | Shutdown/suspend/lock availability, session options |
| `AboutPage` | — | Version, license, links |

---

## 4. State Architecture

### 4.1 ExpansionManager + ExpansionRegistry

**ExpansionRegistry** decouples panel registration from expansion logic. Panels register themselves at startup; ExpansionManager never needs modification when a panel is added.

```
// ─── ExpansionRegistry (singleton) ─────────────────────────────
// Panels register themselves. Extensible without touching ExpansionManager.

property var _entries: ({})

function register(id, component, preferredWidth, preferredHeight) {
    _entries[id] = { component, preferredWidth, preferredHeight }
}

function lookup(id) { return _entries[id] || null }

function allIds() { return Object.keys(_entries) }
```

Each panel registers during Component.onCompleted:
```
ExpansionRegistry.register("launcher",   Qt.resolvedUrl("../panels/Launcher.qml"),   420, 450)
ExpansionRegistry.register("control-center", Qt.resolvedUrl("../panels/ControlCenter.qml"), 380, 360)
// … etc
```

**ExpansionManager** works exclusively with string IDs. No enum. No hardcoded panel list.

```
enum Lifecycle {
    Collapsed,     // No panel visible. Pill only.
    Opening,       // Panel content loading, height animating open.
    Expanded,      // Panel fully visible, interactive.
    Switching,     // Old panel fading out, new panel loading, height may change.
    Closing        // Height animating shut, content fading out.
}

property string activePanelId: ""
property int lifecycle: Lifecycle.Collapsed

readonly property bool isExpanded: lifecycle !== Lifecycle.Collapsed
readonly property bool isTransitioning: lifecycle === Lifecycle.Opening
                                   || lifecycle === Lifecycle.Switching
                                   || lifecycle === Lifecycle.Closing

function requestExpand(panelId) {
    if (lifecycle === Lifecycle.Collapsed || lifecycle === Lifecycle.Expanded) {
        if (activePanelId === panelId) {
            requestCollapse()                               // toggle off
        } else if (activePanelId === "") {
            activePanelId = panelId
            lifecycle = Lifecycle.Opening                   // starts open animation
        } else {
            activePanelId = panelId
            lifecycle = Lifecycle.Switching                 // direct swap, no intermediate collapse
        }
    }
    // If already Opening/Switching/Closing, queue is rejected.
    // The caller should wait for the transition to complete.
}

function requestCollapse() {
    if (lifecycle === Lifecycle.Expanded) {
        lifecycle = Lifecycle.Closing                       // starts close animation
    }
}

// Called by ExpandedSurface when animation completes:
function onOpenCompleted()  { lifecycle = Lifecycle.Expanded }
function onCloseCompleted() { lifecycle = Lifecycle.Collapsed; activePanelId = "" }
function onSwitchCompleted() { lifecycle = Lifecycle.Expanded }
```

**Why explicit lifecycle states over binary expanded/collapsed:**

| Problem | Binary flag | Lifecycle enum |
|---|---|---|
| Height animation still running when content swaps | Race condition — new content loads into still-animating container | `Opening`/`Closing` states gate swaps — `Switching` is a distinct path |
| Click-outside during open animation | Collapses mid-open, janky | `Closing` state only valid from `Expanded` — ignored during `Opening` |
| Two rapid keybind presses | Second expand overwrites first mid-transition | Rejected during transitioning states |
| Crossfade vs. height animation ordering | Ambiguous — both fight | `Opening`: height first, then content fade. `Switching`: content swap first, then height. `Closing`: content fade first, then height. |

**No enum of panel names.** The string `"launcher"` replaces `Panel.Launcher`. Adding a new panel requires only registering it with ExpansionRegistry — ExpansionManager is never touched.

### 4.2 SettingsState

```
property bool isOpen: false
property string currentPage: "appearance"

function open(page)  { currentPage = page; isOpen = true }
function close()     { isOpen = false }
function toggle()    { isOpen = !isOpen }
```

### 4.3 ViewModels (presentation layer between UI and State)

UI never formats backend data. UI never performs filtering. UI never performs sorting. ViewModels prepare all presentation data.

| ViewModel | Consumes | Prepares | Used By |
|---|---|---|---|
| `LauncherViewModel` | `HyprlandState` | Sorted app list, filtered by query, icon resolution, formatted names | `Launcher.qml` |
| `NotificationViewModel` | `NotificationState` | Sorted notifications, unread badge count, formatted timestamps, group headers | `NotificationCenter.qml` |
| `WallpaperViewModel` | `WallpaperState` | Wallpaper grid items, preview paths, current selection index | `WallpaperSelector.qml` |
| `MediaViewModel` | `MediaPlayerState` | Active player display data (title, artist, art, progress), formatted duration strings | `MediaPlayer.qml` |
| `ControlCenterViewModel` | `AudioState`, `NetworkState`, `BluetoothState`, `PowerState` | Quick-setting toggle states, volume/brightness values, connectivity summaries | `ControlCenter.qml` |
| `SettingsBarPillVm` | `SettingsState` | Clock format config, pill visibility toggles | `BarPillPage.qml` |
| `SettingsAppearanceVm` | `Theme`, `Typography` | Theme list, font family list, spacing scale options | `AppearancePage.qml` |
| `SettingsThemesVm` | `Colors` | Available themes, current theme, preview colors | `ThemesPage.qml` |
| `SettingsWallpaperVm` | `WallpaperState` | Wallpaper list, current selection, preview paths | `WallpaperPage.qml` |
| `SettingsLauncherVm` | `HyprlandState` | Pinned apps, search backend config | `LauncherPage.qml` |
| `SettingsNotificationsVm` | `NotificationState` | DND toggle, timeout config, app filter list | `NotificationsPage.qml` |
| `SettingsControlCenterVm` | `ControlCenterViewModel` | Card order, card visibility toggles | `ControlCenterPage.qml` |
| `SettingsMediaVm` | `MediaPlayerState` | Default player, show/hide controls | `MediaPage.qml` |
| `SettingsClockVm` | `SettingsState` | Date format, time format, timezone | `ClockDatePage.qml` |
| `SettingsMotionVm` | `Animation` | Animation speed scale, spring config overrides | `MotionPage.qml` |
| `SettingsKeybindsVm` | `KeybindState` | Current keybind list, conflict detection | `KeybindsPage.qml` |
| `SettingsSystemVm` | `PowerState` | Shutdown/suspend/lock availability | `SystemPage.qml` |

**ViewModel contract:**
- Each ViewModel is a `QtObject` (not a singleton) — instantiated by the panel or page that needs it.
- ViewModels read from State singletons. They never call Services.
- ViewModels may compute derived properties (sorting, filtering, formatting) but never mutate State.
- User actions flow through the panel/page → State → Service. ViewModels are read-only presentation adapters.

### 4.4 Domain State Singletons (backend-facing)

| Singleton | Data | Service Backend |
|---|---|---|
| `AudioState` | volume, muted, sinkName, sources | PipeWire (Quickshell.Io Process) |
| `NetworkState` | connected, ssid, strength, connections | nmcli/iwd Process |
| `BluetoothState` | enabled, devices | bluetoothctl Process |
| `NotificationState` | notifications[], unreadCount | swaync D-Bus or custom |
| `MediaPlayerState` | players[], activePlayer, title, artist, art | MPRIS2 D-Bus |
| `PowerState` | (actions only) | loginctl/systemctl Process |
| `WallpaperState` | currentPath, list[] | hyprpaper/swww Process |
| `HyprlandState` | workspaces[], focusedWorkspace, activeWindow | Quickshell.Hyprland |

### 4.5 Data Flow

```
Services (Process/DBUS/IPC)
    │
    │ write
    ▼
State Singletons (ExpansionManager, AudioState, …)
    │
    │ property bindings (reactive)
    ▼
ViewModels (presentation: sort, filter, format, derive)
    │
    │ property bindings (reactive)
    ▼
UI Components (panels, atoms, molecules)
    │
    │ signal/slot (user intent)
    ▼
State Singletons (e.g., AudioState.setVolume(0.5))
    │
    │ call
    ▼
Services (e.g., pactl set-sink-volume …)
```

UI never calls services directly. UI never formats, filters, or sorts. State is the only mutation choke point. ViewModels are the only presentation choke point.

---

## 5. Reusable Component Architecture

### 5.1 Atoms (zero internal logic, pure presentation)

| Atom | Props | Token Dependencies |
|---|---|---|
| `PillShape` | radius, color, borderColor, borderWidth | `Colors.*`, `Radius.radii.*` |
| `ShellButton` | text, icon, onClicked, active, toggled | `Colors.*`, `Spacing.button.*`, `Radius.button.*`, `Typography.button` |
| `ShellToggle` | checked, onToggled | `Colors.toggleTrack/Active`, `Spacing.toggle.*`, `Radius.toggle.*` |
| `ShellSlider` | from, to, value, label, onChanged | `Colors.sliderTrack/Fill`, `Spacing.slider.*` |
| `ShellIcon` | name, size, color | `Colors.fg` |
| `ShellText` | text, role, color | `Typography.*`, `Colors.fg/fgMuted` |
| `SectionHeader` | text | `Colors.divider`, `Typography.subheading` |
| `ListItem` | icon, title, subtitle, trailing | `Colors.*`, `Spacing.listItem.*`, `Radius.listItem.*` |

### 5.2 Molecules (compose atoms, minimal state)

| Molecule | Composed From | Used In |
|---|---|---|
| `PanelContainer` | PillShape + Flickable | Every panel |
| `QuickSettingTile` | ShellButton + ShellIcon + ShellText | QuickSettingsGrid |
| `QuickSettingsGrid` | Flow + QuickSettingTile × N | ControlCenter, Settings |
| `SliderRow` | ShellIcon + ShellText + ShellSlider | VolumeCard, BrightnessCard |
| `SearchField` | TextField + ShellIcon | Launcher, WallpaperSelector |
| `AppGridItem` | ShellIcon + ShellText | Launcher |
| `NotificationCard` | ShellIcon + ShellText + ShellButton | NotificationCenter |
| `NavigationSidebar` | ListItem × N | SettingsWindow |

### 5.3 ControlCenter Cards (composable cards, not a monolithic page)

ControlCenter is composed from reusable cards. Each card is a self-contained molecule that can be reused in Settings pages or other panels.

| Card | Composed From | Data Source | Reusable In |
|---|---|---|---|
| `QuickSettingsGrid` | QuickSettingTile × N (WiFi, BT, DND, Theme, …) | `ControlCenterViewModel.toggleItems` | `ControlCenterPage` (Settings) |
| `BrightnessCard` | SliderRow + ShellIcon | `ControlCenterViewModel.brightness` | Standalone Audio panel |
| `VolumeCard` | SliderRow + ShellIcon | `ControlCenterViewModel.volume` | Standalone Audio panel |
| `ConnectivityCard` | ShellIcon + ShellText (WiFi SSID, BT status) | `ControlCenterViewModel.connectivity` | `WiFi.qml`, `Bluetooth.qml` |
| `PowerCard` | ShellButton × N (lock, suspend, reboot, shutdown) | `PowerState` |8| `PowerMenu.qml` |
| `MediaMiniCard` | ShellIcon + ShellText + ShellButton (play/pause) | `MediaViewModel` | `MediaPlayer.qml` |

`ControlCenter.qml` is a `PanelContainer` containing a Column of these cards, ordered and visibility-toggled by `ControlCenterViewModel`. `ControlCenterPage` (Settings) can show the same cards in a configuration UI.

### 5.4 Layout Helpers

| Helper | Purpose |
|---|---|
| `AnimatedSize` | Wraps an Item and animates width/height changes using SpringAnimation from `Animation.spring.*` |

---

## 6. Animation Architecture

### 6.1 Shell Window Height

The Shell PanelWindow's `implicitHeight` is bound to:

```
padding + shellContent.height + padding
```

`shellContent.height` is `pillHeight + (isExpanded ? expandedHeight : 0)`.

`expandedHeight` has a `Behavior on expandedHeight` with `SpringAnimation` using `Animation.panel.springConfig`.

**Lifecycle-driven animation sequencing:**

| Transition | Lifecycle Path | Sequence |
|---|---|---|
| Open | `Collapsed → Opening → Expanded` | Height animates open → content fades in → `onOpenCompleted()` |
| Close | `Expanded → Closing → Collapsed` | Content fades out → height animates shut → `onCloseCompleted()` |
| Swap | `Expanded → Switching → Expanded` | Old content fades out → new content loads → height animates to new size → new content fades in → `onSwitchCompleted()` |
| Toggle off | `Expanded → Closing → Collapsed` | Same as Close |

This sequencing prevents the most common animation conflict: height and content opacity fighting on the same frame. Height leads on open; content leads on close; on swap they interleave.

### 6.2 Content Transitions

| Transition | Duration | Easing | Token |
|---|---|---|---|
| Panel expand | 300ms | Spring | `Animation.panel.expandDuration` |
| Panel collapse | 300ms | Spring | `Animation.panel.collapseDuration` |
| Content fade-in | 100ms | OutCubic | `Animation.panel.contentFadeIn` |
| Content fade-out | 50ms | OutCubic | `Animation.panel.contentFadeOut` |
| Button press scale | 50ms | Linear | `Animation.button.pressDuration` |
| Toggle position | 200ms | Spring | `Animation.toggle.thumbDuration` |
| Theme crossfade | 500ms | InOutCubic | `Animation.theme.crossfadeDuration` |

### 6.3 Layered Animation (one thing moves at a time)

1. **Window layer** — Shell height animates (spring physics)
2. **Content layer** — Panel content opacity crossfades (fast ease)
3. **Micro layer** — Button/toggle/slider interactions (instant or micro)

Never animate height and opacity on the same element simultaneously.

---

## 7. Keyboard and Focus Architecture

### 7.1 KeybindHandler

Listens to Hyprland keybinds via `Quickshell.Hyprland` IPC. Maps:

| Keybind | Action |
|---|---|
| Super+Space | `ExpansionManager.requestExpand("launcher")` |
| Super+T | `ExpansionManager.requestExpand("theme-switcher")` |
| Super+W | `ExpansionManager.requestExpand("wallpaper-selector")` |
| Super+N | `ExpansionManager.requestExpand("notification-center")` |
| Super+M | `ExpansionManager.requestExpand("media-player")` |
| Escape | `ExpansionManager.requestCollapse()` |

**Implementation:** Hyprland keybinds are registered in `hyprland.conf`, not in QML. The keybinds dispatch `quickshell ipc` calls that trigger QML methods. This avoids conflicting with Hyprland's own keybind system.

```
# In hyprland.conf
bind = SUPER, Space, exec, quickshell ipc call expand launcher
bind = SUPER, T, exec, quickshell ipc call expand theme-switcher
bind = SUPER, W, exec, quickshell ipc call expand wallpaper-selector
bind = SUPER, N, exec, quickshell ipc call expand notification-center
bind = SUPER, M, exec, quickshell ipc call expand media-player
```

The shell registers an `IpcHandler` that routes these calls to `ExpansionManager.requestExpand()`.

### 7.2 Focus Management

| Lifecycle State | Shell.focusable | Keyboard Focus |
|---|---|---|
| `Collapsed` | `false` | None — clicks pass through |
| `Opening` | `true` | Shell prepares to grab focus |
| `Expanded` | `true` | Shell holds focus |
| `Switching` | `true` | Shell holds focus (new panel may claim it) |
| `Closing` | `true` | Shell holds focus until complete |
| Settings open | N/A | SettingsWindow gets focus from WM |

When a panel with a SearchField expands (Launcher), focus is explicitly set to the search field via `forceActiveFocus()` during the `Expanded` lifecycle state.

When `ExpansionManager.lifecycle` reaches `Collapsed`, `Shell.focusable` becomes `false` and keyboard focus returns to the previously focused window.

### 7.3 HyprlandFocusGrab (optional, for click-outside detection)

```qml
HyprlandFocusGrab {
    id: shellGrab
    windows: [shellWindow]
    active: ExpansionManager.isExpanded
    onActiveChanged: if (!active && ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Expanded)
        ExpansionManager.requestCollapse()
}
```

Focus grab dismissal is only acted upon when in the `Expanded` state — not during `Opening`, `Switching`, or `Closing`, where it would conflict with ongoing animations.

This provides robust click-outside dismissal on Hyprland. When the user clicks outside the Shell window, the grab is dismissed and we collapse.

---

## 8. Directory Structure (to be created)

```
shell/
├── shell.qml                        # ShellRoot + IpcHandler
├── CMakeLists.txt
│
├── tokens/                          # ← FROZEN, do not modify
│   ├── Colors.qml
│   ├── Theme.qml
│   ├── Typography.qml
│   ├── Spacing.qml
│   ├── Radius.qml
│   ├── Animation.qml
│   ├── Elevation.qml
│   ├── qmldir
│   └── palettes/
│       └── … (13 files)
│
├── metrics/
│   ├── ShellMetrics.qml             # Shell-wide dimensions (pill, panel, settings sizes)
│   └── qmldir
│
├── state/
│   ├── ExpansionManager.qml         # Lifecycle state machine (Collapsed/Opening/Expanded/Switching/Closing)
│   ├── ExpansionRegistry.qml        # Panel registration (id → component + dimensions)
│   ├── SettingsState.qml
│   ├── AudioState.qml
│   ├── NetworkState.qml
│   ├── BluetoothState.qml
│   ├── NotificationState.qml
│   ├── MediaPlayerState.qml
│   ├── PowerState.qml
│   ├── WallpaperState.qml
│   ├── HyprlandState.qml
│   └── qmldir
│
├── viewmodels/
│   ├── LauncherViewModel.qml
│   ├── NotificationViewModel.qml
│   ├── WallpaperViewModel.qml
│   ├── MediaViewModel.qml
│   ├── ControlCenterViewModel.qml
│   ├── settings/
│   │   ├── BarPillVm.qml
│   │   ├── AppearanceVm.qml
│   │   ├── ThemesVm.qml
│   │   ├── WallpaperVm.qml
│   │   ├── LauncherVm.qml
│   │   ├── NotificationsVm.qml
│   │   ├── ControlCenterVm.qml
│   │   ├── MediaVm.qml
│   │   ├── ClockVm.qml
│   │   ├── MotionVm.qml
│   │   ├── KeybindsVm.qml
│   │   ├── SystemVm.qml
│   │   └── qmldir
│   └── qmldir
│
├── windows/
│   ├── Shell.qml                    # PanelWindow
│   ├── SettingsWindow.qml           # FloatingWindow
│   └── qmldir
│
├── pill/
│   ├── TopPill.qml
│   └── qmldir
│
├── surface/
│   ├── ExpandedSurface.qml
│   ├── OverlayDim.qml
│   └── qmldir
│
├── panels/
│   ├── Launcher.qml
│   ├── ControlCenter.qml
│   ├── ThemeSwitcher.qml
│   ├── WallpaperSelector.qml
│   ├── NotificationCenter.qml
│   ├── MediaPlayer.qml
│   ├── Calendar.qml
│   ├── Bluetooth.qml
│   ├── WiFi.qml
│   ├── Audio.qml
│   ├── PowerMenu.qml
│   └── qmldir
│
├── settings/
│   ├── SettingsSidebar.qml
│   ├── SettingsTitleBar.qml
│   ├── pages/
│   │   ├── BarPillPage.qml
│   │   ├── AppearancePage.qml
│   │   ├── ThemesPage.qml
│   │   ├── WallpaperPage.qml
│   │   ├── LauncherPage.qml
│   │   ├── NotificationsPage.qml
│   │   ├── ControlCenterPage.qml
│   │   ├── MediaPage.qml
│   │   ├── ClockDatePage.qml
│   │   ├── MotionPage.qml
│   │   ├── KeybindsPage.qml
│   │   ├── SystemPage.qml
│   │   ├── AboutPage.qml
│   │   └── qmldir
│   └── qmldir
│
├── components/
│   ├── atoms/
│   │   ├── PillShape.qml
│   │   ├── ShellButton.qml
│   │   ├── ShellToggle.qml
│   │   ├── ShellSlider.qml
│   │   ├── ShellIcon.qml
│   │   ├── ShellText.qml
│   │   ├── SectionHeader.qml
│   │   ├── ListItem.qml
│   │   └── qmldir
│   ├── molecules/
│   │   ├── PanelContainer.qml
│   │   ├── QuickSettingTile.qml
│   │   ├── QuickSettingsGrid.qml
│   │   ├── SliderRow.qml
│   │   ├── SearchField.qml
│   │   ├── AppGridItem.qml
│   │   ├── NotificationCard.qml
│   │   ├── NavigationSidebar.qml
│   │   └── qmldir
│   ├── cards/
│   │   ├── QuickSettingsCard.qml
│   │   ├── BrightnessCard.qml
│   │   ├── VolumeCard.qml
│   │   ├── ConnectivityCard.qml
│   │   ├── PowerCard.qml
│   │   ├── MediaMiniCard.qml
│   │   └── qmldir
│   ├── layout/
│   │   ├── AnimatedSize.qml
│   │   └── qmldir
│   └── qmldir
│
├── services/
│   ├── AudioService.qml
│   ├── NetworkService.qml
│   ├── BluetoothService.qml
│   ├── NotificationService.qml
│   ├── MprisService.qml
│   ├── WallpaperService.qml
│   ├── PowerService.qml
│   └── qmldir
│
└── keybinds/
    ├── IpcHandler.qml
    └── qmldir
```

---

## 9. Implementation Order

Build in dependency order. Each phase is independently testable.

### Phase 1: Skeleton + Registry + Metrics

| Step | File | What |
|---|---|---|
| 1.1 | `shell.qml` | ShellRoot with empty Shell + SettingsWindow |
| 1.2 | `state/ExpansionRegistry.qml` | Panel registration: register(id, component, width, height), lookup(id) |
| 1.3 | `state/ExpansionManager.qml` | Lifecycle state machine (Collapsed/Opening/Expanded/Switching/Closing), works with string IDs |
| 1.4 | `state/SettingsState.qml` | isOpen, currentPage, open, close, toggle |
| 1.5 | `metrics/ShellMetrics.qml` | Shell-wide dimensions — all panel/pill/settings sizes centralized |
| 1.6 | `windows/Shell.qml` | PanelWindow, transparent, full-width top-anchored, ignores exclusion |
| 1.7 | `windows/SettingsWindow.qml` | FloatingWindow, visible bound to SettingsState, dimensions from ShellMetrics |
| 1.8 | `keybinds/IpcHandler.qml` | IPC handler routing expand/collapse calls by string ID |

**Test:** Shell launches. Transparent PanelWindow appears at top. No visible content. IPC calls `ExpansionManager.requestExpand("launcher")` etc. Lifecycle transitions occur.

### Phase 2: Pill + Expansion Surface

| Step | File | What |
|---|---|---|
| 2.1 | `pill/TopPill.qml` | Clock text in PillShape, centered, click → `requestExpand("control-center")` |
| 2.2 | `surface/ExpandedSurface.qml` | Loader, source resolved via ExpansionRegistry.lookup(ExpansionManager.activePanelId), reports contentHeight, drives lifecycle transitions |
| 2.3 | `surface/OverlayDim.qml` | Semi-transparent Rectangle, click → `requestCollapse()` (only when lifecycle === Expanded) |
| 2.4 | Wire Shell.qml | Column with TopPill + ExpandedSurface, centered, height animated, dimensions from ShellMetrics |

**Test:** Pill visible. Clicking pill triggers `Opening` lifecycle. Clicking outside triggers `Closing`. Shell height animates. No content yet (no panels registered).

### Phase 3: Atoms

| Step | File | What |
|---|---|---|
| 3.1 | `PillShape.qml` | Rounded rect with bg, border, optional blur |
| 3.2 | `ShellIcon.qml` | Icon font rendering (Material Symbols Rounded) |
| 3.3 | `ShellText.qml` | Themed text by role |
| 3.4 | `ShellButton.qml` | Clickable, press scale, hover |
| 3.5 | `ShellToggle.qml` | On/off switch |
| 3.6 | `ShellSlider.qml` | Slider with label |
| 3.7 | `SectionHeader.qml` | Divider + label |
| 3.8 | `ListItem.qml` | Row with icon + title + trailing |

**Test:** Can instantiate each atom in a test panel. All consume tokens — no hardcoded values.

### Phase 4: Molecules + Cards

| Step | File | What |
|---|---|---|
| 4.1 | `PanelContainer.qml` | PillShape wrapper + Flickable, padding from ShellMetrics |
| 4.2 | `QuickSettingTile.qml` | Square toggle tile |
| 4.3 | `QuickSettingsGrid.qml` | Flow of QuickSettingTiles |
| 4.4 | `SliderRow.qml` | Icon + label + slider |
| 4.5 | `SearchField.qml` | Text input with search icon |
| 4.6 | `AppGridItem.qml` | App icon + name |
| 4.7 | `NotificationCard.qml` | Notification display |
| 4.8 | `NavigationSidebar.qml` | Vertical nav list |
| 4.9 | `QuickSettingsCard.qml` | Card wrapper around QuickSettingsGrid |
| 4.10 | `BrightnessCard.qml` | Card with brightness SliderRow |
| 4.11 | `VolumeCard.qml` | Card with volume SliderRow |
| 4.12 | `ConnectivityCard.qml` | Card showing WiFi/BT status |
| 4.13 | `PowerCard.qml` | Card with lock/suspend/reboot/shutdown buttons |
| 4.14 | `MediaMiniCard.qml` | Card with mini media controls |

### Phase 5: First Panel — ControlCenter (composed from cards + ViewModel)

| Step | File | What |
|---|---|---|
| 5.1 | `viewmodels/ControlCenterViewModel.qml` | Aggregates toggle states, volume/brightness, connectivity summary from State |
| 5.2 | `panels/ControlCenter.qml` | PanelContainer with Column of cards, ordered by ControlCenterViewModel |
| 5.3 | Register in ExpansionRegistry | `ExpansionRegistry.register("control-center", …, ShellMetrics.controlCenterWidth, ShellMetrics.controlCenterHeight)` |
| 5.4 | Wire pill click | TopPill click → `ExpansionManager.requestExpand("control-center")` |

**Test:** Click pill → ControlCenter expands downward with cards. Click outside → collapses. Lifecycle transitions: Collapsed → Opening → Expanded → Closing → Collapsed. Height animates smoothly.

### Phase 6: State + Services (incremental)

| Step | What | Backend |
|---|---|---|
| 6.1 | `HyprlandState.qml` + wire | Quickshell.Hyprland (built-in) |
| 6.2 | `AudioState.qml` + `AudioService.qml` | PipeWire via pactl Process |
| 6.3 | `NetworkState.qml` + `NetworkService.qml` | nmcli Process |
| 6.4 | `BluetoothState.qml` + `BluetoothService.qml` | bluetoothctl Process |
| 6.5 | `NotificationState.qml` + `NotificationService.qml` | D-Bus or swaync |
| 6.6 | `MediaPlayerState.qml` + `MprisService.qml` | MPRIS2 D-Bus |
| 6.7 | `WallpaperState.qml` + `WallpaperService.qml` | swww/hyprpaper |
| 6.8 | `PowerState.qml` + `PowerService.qml` | loginctl |

Each state+service pair is implemented and tested before moving to the next.

### Phase 7: Panel ViewModels + Remaining Panels (one at a time)

| Step | ViewModel | Panel | Depends On |
|---|---|---|---|
| 7.1 | `LauncherViewModel.qml` | `Launcher.qml` | HyprlandState |
| 7.2 | — | `ThemeSwitcher.qml` | Colors.availableThemes |
| 7.3 | `WallpaperViewModel.qml` | `WallpaperSelector.qml` | WallpaperState |
| 7.4 | `NotificationViewModel.qml` | `NotificationCenter.qml` | NotificationState |
| 7.5 | `MediaViewModel.qml` | `MediaPlayer.qml` | MediaPlayerState |
| 7.6 | — | `Calendar.qml` | Qt.labs.calendar |
| 7.7 | — | `Bluetooth.qml` | BluetoothState |
| 7.8 | — | `WiFi.qml` | NetworkState |
| 7.9 | — | `Audio.qml` | AudioState |
| 7.10 | — | `PowerMenu.qml` | PowerState |

Each step: create ViewModel (if needed) → implement panel → register with ExpansionRegistry → wire into ExpandedSurface → test with keybind → verify lifecycle transitions and height animation.

### Phase 8: SettingsWindow + Settings ViewModels

| Step | File | What |
|---|---|---|
| 8.1 | `settings/SettingsTitleBar.qml` | Drag handle + close |
| 8.2 | `settings/SettingsSidebar.qml` | Page list (13 entries) |
| 8.3 | `viewmodels/settings/BarPillVm.qml` | Clock format, pill toggles |
| 8.4 | `viewmodels/settings/AppearanceVm.qml` | Font list, spacing scale |
| 8.5 | `viewmodels/settings/ThemesVm.qml` | Theme list, current, preview |
| 8.6 | `viewmodels/settings/WallpaperVm.qml` | Wallpaper list, selection |
| 8.7 | `viewmodels/settings/LauncherVm.qml` | Pinned apps, search config |
| 8.8 | `viewmodels/settings/NotificationsVm.qml` | DND, timeout, filters |
| 8.9 | `viewmodels/settings/ControlCenterVm.qml` | Card order, visibility |
| 8.10 | `viewmodels/settings/MediaVm.qml` | Default player, position |
| 8.11 | `viewmodels/settings/ClockVm.qml` | 12/24h, date format |
| 8.12 | `viewmodels/settings/MotionVm.qml` | Speed scale, spring overrides |
| 8.13 | `viewmodels/settings/KeybindsVm.qml` | Keybind list, conflicts |
| 8.14 | `viewmodels/settings/SystemVm.qml` | Power options |
| 8.15 | `settings/pages/BarPillPage.qml` | Pill config UI |
| 8.16 | `settings/pages/AppearancePage.qml` | Appearance config UI |
| 8.17 | `settings/pages/ThemesPage.qml` | Theme picker grid |
| 8.18 | `settings/pages/WallpaperPage.qml` | Wallpaper selector |
| 8.19 | `settings/pages/LauncherPage.qml` | Launcher config |
| 8.20 | `settings/pages/NotificationsPage.qml` | Notification config |
| 8.21 | `settings/pages/ControlCenterPage.qml` | CC card config (reuses cards) |
| 8.22 | `settings/pages/MediaPage.qml` | Media config |
| 8.23 | `settings/pages/ClockDatePage.qml` | Clock/date config |
| 8.24 | `settings/pages/MotionPage.qml` | Animation config |
| 8.25 | `settings/pages/KeybindsPage.qml` | Shortcut display |
| 8.26 | `settings/pages/SystemPage.qml` | System/power config |
| 8.27 | `settings/pages/AboutPage.qml` | Version info |
| 8.28 | Wire SettingsWindow.qml | TitleBar + Sidebar + Loader for pages |

### Phase 9: Polish

| Step | What |
|---|---|
| 9.1 | `mask: Region { item: shellContent }` on Shell for Hyprland rendering optimization |
| 9.2 | `HyprlandFocusGrab` on Shell for robust click-outside (gated by lifecycle) |
| 9.3 | Spring animation tuning on height transitions |
| 9.4 | Escape key handling in expanded state |
| 9.5 | Multi-monitor support (screen property on PanelWindow) |
| 9.6 | Hyprland window rules documentation |

---

## 10. Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| PanelWindow transparent area intercepts clicks meant for windows below | Users can't click through empty shell space | `mask: Region { item: shellContent }` + `WlrLayershell.keyboardFocus: None` when collapsed ensures pass-through |
| Shell height animation stutters on Wayland | Janky panel expand/collapse | Use `Behavior on implicitHeight` with SpringAnimation, not NumberAnimation. Avoid nested Behaviors. |
| Loader source swap causes blank frame | Visible flash when swapping panels | Set `Loader.asynchronous: false` for panel swaps (they're lightweight). Keep old content visible until new content's `status === Loader.Ready`. |
| FloatingWindow (Settings) doesn't get blur | No backdrop blur behind settings | Hyprland `layerrule = blur` applies to layer-shell surfaces. For FloatingWindow, add `decoration:blur:enabled = true` in hyprland.conf or use `HyprlandWindow.opacity` as fallback. |
| Keybind conflicts with Hyprland | Super+Space etc. already bound | Document required hyprland.conf keybinds. Provide a drop-in conf snippet. |
| Dynamic theme palette not available at startup | Colors default to fallback | Dynamic palette starts as Catppuccin Mocha fallback. Update via IPC when wallust completes. |
| ExpansionManager lifecycle transitions rejected during transitioning states | User rapidly pressing keybinds appears unresponsive | Transitions are fast (200–300ms). Rejected requests can be optionally queued. Log rejected calls for debugging. |
| ExpansionRegistry registration ordering | Panel registered after ExpandedSurface tries to resolve it | All panels register in their `Component.onCompleted`. ExpandedSurface only resolves when `lifecycle === Opening`. If registry lookup returns null, surface shows error state. |
| ViewModel instantiation cost | Creating ViewModels per panel/page adds overhead | ViewModels are lightweight QtObjects with no visual content. Cost is negligible vs. the panel's Item tree. Use `LazyLoader` for settings pages. |
| ShellMetrics divergence from Spacing tokens | Two sources of truth for dimensions | ShellMetrics references Spacing tokens for its values where possible. ShellMetrics is for *shell-specific layout dimensions* (pill width, panel widths); Spacing is for *component-internal spacing*. No overlap in responsibility. |
| ControlCenter card reordering | Drag-to-reorder in Settings requires persistent state | Store card order in `PersistentProperties` (Quickshell built-in). Falls back to default order on first launch. |
| Settings page count (13 pages) | Large sidebar, potential scroll | Sidebar uses compact icon+label layout. Scrollable if needed. `LazyLoader` for page content. |
| Lifecycle state machine edge cases | Rapid expand→collapse→expand during animation | Lifecycle states gate all transitions. Only `Expanded` can transition to `Closing`. Only `Collapsed` or `Expanded` can transition to `Opening`/`Switching`. Invalid transitions are no-ops. |

---

## 11. File Count Estimate

| Layer | Files | Lines (est.) |
|---|---|---|
| Tokens (frozen) | 21 | 1,839 |
| Metrics | 1 | ~60 |
| State singletons | 11 | ~900 |
| ViewModels (panel) | 5 | ~400 |
| ViewModels (settings) | 12 | ~600 |
| Windows | 2 | ~200 |
| Pill + Surface | 3 | ~150 |
| Panels | 11 | ~2,200 |
| Settings pages | 13 | ~1,300 |
| Settings chrome | 2 | ~150 |
| Atoms | 8 | ~800 |
| Molecules | 8 | ~600 |
| Cards | 6 | ~500 |
| Layout helpers | 1 | ~50 |
| Services | 7 | ~700 |
| Keybinds | 1 | ~80 |
| shell.qml | 1 | ~50 |
| qmldir files | ~16 | ~160 |
| **Total** | **~138** | **~10,789** |

---

## 12. Dependency Graph (build order)

```
tokens (FROZEN)
  │
  ├─→ metrics/ShellMetrics
  │     │
  │     ├─→ windows/Shell
  │     ├─→ windows/SettingsWindow
  │     └─→ panels/* (consume panel dimensions)
  │
  ├─→ state/ExpansionRegistry
  │     │
  │     └─→ state/ExpansionManager
  │           │
  │           ├─→ windows/Shell
  │           │     │
  │           │     ├─→ pill/TopPill
  │           │     ├─→ surface/ExpandedSurface
  │           │     │     │
  │           │     │     └─→ panels/* (resolved via ExpansionRegistry)
  │           │     └─→ surface/OverlayDim
  │           │
  │           └─→ keybinds/IpcHandler
  │
  ├─→ state/SettingsState
  │     └─→ windows/SettingsWindow
  │           └─→ settings/*
  │
  ├─→ components/atoms/*
  │     └─→ components/molecules/*
  │           ├─→ components/cards/*
  │           │     └─→ panels/ControlCenter
  │           └─→ panels/* + settings/*
  │
  ├─→ state/* (domain) + services/*
  │     └─→ viewmodels/* (read State, compute presentation)
  │           ├─→ panels/* (consume ViewModels)
  │           └─→ viewmodels/settings/* → settings/pages/*
  │
  └─→ keybinds/IpcHandler
        └─→ ExpansionManager (via string IDs)
```

**Acyclicity proof:**

Every edge in the graph follows the direction: tokens → metrics → state → services → viewmodels → UI. No node points upward.

| Potential cycle | Why it cannot exist |
|---|---|
| ViewModel → State → ViewModel | ViewModels only read State. State never references ViewModels. |
| ViewModel → Service → ViewModel | ViewModels never call Services. Services write to State, not ViewModels. |
| Panel → ViewModel → Panel | ViewModels have no reference to panels. They are instantiated objects, not singletons. |
| ExpansionManager → Panel → ExpansionManager | ExpansionManager only stores string IDs. Panels register with ExpansionRegistry. Neither references the other's code — registration is data, not import. |
| Card → Panel → Card | Cards are molecules. Panels compose cards. Cards have no import of any panel. |
| SettingsPage → ViewModel → SettingsPage | Same as Panel → ViewModel → Panel. ViewModels are instantiated by the page, not vice versa. |

**No circular dependencies. Every arrow points downward.**

---

## 13. Design System Freeze Confirmation

The following files are **frozen** and were **not modified** by this architecture review:

| File | Status |
|---|---|
| `tokens/Colors.qml` | **Frozen. Unchanged.** |
| `tokens/Theme.qml` | **Frozen. Unchanged.** |
| `tokens/Typography.qml` | **Frozen. Unchanged.** |
| `tokens/Spacing.qml` | **Frozen. Unchanged.** |
| `tokens/Radius.qml` | **Frozen. Unchanged.** |
| `tokens/Animation.qml` | **Frozen. Unchanged.** |
| `tokens/Elevation.qml` | **Frozen. Unchanged.** |
| `tokens/qmldir` | **Frozen. Unchanged.** |
| All 13 palette singletons in `tokens/palettes/` | **Frozen. Unchanged.** |

No new values were added to any token singleton. The new `ShellMetrics.qml` is a **separate file** in a **separate directory** (`metrics/`). It references Spacing tokens for its values but does not modify them. ShellMetrics is for shell-wide layout dimensions (pill width, panel widths, settings window size); the frozen Spacing/Radius/Typography/Animation/Elevation tokens remain the single source of truth for component-internal spacing, radii, typography, animation, and elevation.

**The design system remains a stable public API. Every future component must consume the frozen tokens. ShellMetrics supplements but never supplants them.**
