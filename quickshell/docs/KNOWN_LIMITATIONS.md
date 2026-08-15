# Known Limitations

> Current limitations, deferred features, and unimplemented items.
> Verified against source 2026-08-10.

---

## Key Capture UI in KeybindsPage

**Status:** Partially implemented, broken wiring
**Files:** `settings/KeybindsPage.qml`, `viewmodels/KeybindsSettingsViewModel.qml`

The Edit button toggles an editing indicator ("Press new shortcut…"). The page now has a `Keys.onPressed` handler that builds a modifier string (`CTRL + SHIFT + ...`) and calls `vm.setShortcut(editingKey, keyStr)`, but `KeybindsSettingsViewModel` does not define `setShortcut`. It only exposes per-key setters (`setLauncher()`, `setThemeSwitcher()`, etc.) that are never invoked. Key capture therefore cannot persist a keybind, and there is still no modal key-listener overlay; capture relies on page focus inside the settings window.

**Deferred because:** The ViewModel setter API and the page handler were written independently and never reconciled. A modal capture overlay plus a `setShortcut(key, value)` dispatch would complete it.

---

## File Picker for Import/Export

**Status:** Not implemented
**Files:** `viewmodels/SystemSettingsViewModel.qml`, `services/ConfigService.qml`

The "Import Settings" action calls `ConfigService.importSettings()` with no argument, but the function requires a JSON string (`importSettings(jsonString)`). There is no file picker, so import can never be driven from the UI. Export works (returns a JSON string) but has nowhere to write it.

**Deferred because:** Quickshell has no native file dialog. Options: a command-line picker, a custom QML file browser, or xdg-desktop-portal's FileChooser interface.

---

## Multi-Monitor Support

**Status:** Not implemented
**Files:** `windows/Shell.qml`, `windows/PanelSurface.qml`, `metrics/ShellMetrics.qml`

Both the pill bar and the expanded-panel surface anchor `top/left/right` on the primary monitor only. No `Screen` attached property, no per-screen instances, no monitor-selection setting. ShellMetrics uses fixed pixel dimensions that do not adapt to screen size or DPI.

**Deferred because:** Requires per-screen shell instances or repositioning, DPI-aware dimension scaling, and a monitor-selection setting.

---

## Dynamic Theme (Wallust/Pywal/Material You)

**Status:** Static fallback palette
**Files:** `tokens/palettes/Dynamic.qml`

`Dynamic` is registered as a theme but contains hardcoded Catppuccin Mocha fallback values. Runtime palette replacement from a wallpaper color extraction pipeline (wallust, pywal, material-color-utilities) is not implemented.

**Deferred because:** Requires a wallpaper change hook in WallpaperService, running the palette generator, and replacing the palette singleton's `readonly property color` values at runtime (which QML forbids without a writable proxy layer).

---

## Animated ExpansionManager Transitions

**Status:** Instant state machine; QML-driven animation
**Files:** `state/ExpansionManager.qml`, `windows/PanelSurface.qml`

`transitionMode` stays `Instant`, so the lifecycle state machine auto-advances through Opening/Expanded/Closing via `_advanceIfInstant()`. The completion callbacks (`onOpenCompleted`, `onSwitchCompleted`, `onCloseCompleted`) exist but are never called by `PanelSurface`. The actual animation path is `PanelSurface`'s `panelRect.height` binding (`isExpanded ? contentHeight : 0`, with a `Behavior on height` routed through `MotionConfig.duration()`). An `Animated` transition mode would need PanelSurface to invoke the completion callbacks when its Behaviors finish.

**Deferred because:** Requires wiring animation-end signals back into the lifecycle state machine, plus careful coordination with the panel content loader.

---

## Collapse Duration vs Expand Duration

**Status:** Both persisted, neither consumed
**Properties:** `SettingsStore.expandDuration`, `SettingsStore.collapseDuration`

Both properties exist, are exposed in the Motion settings page, and are persisted, but no runtime consumer reads them. `PanelSurface` animates panel height with `MotionConfig.duration(Motion.duration.slow)`, and `MotionConfig` does not wire `expandDuration`/`collapseDuration`. Note: `shell.qml` carries a stale comment claiming "ExpandedSurface reads SettingsStore.animationsEnabled, .expandDuration, .collapseDuration directly"; that component no longer exists, and `PanelSurface` reads neither property.

**Deferred because:** Would require either threading the two durations into `MotionConfig` or making `PanelSurface` read them directly.

---

## Persisted SettingsStore Properties Not Consumed at Runtime

**Status:** Persisted and shown in UI, not read by services
**Properties:** `audioStepPercent`, `audioShowInput`, `brightnessStepPercent`, `wifiAutoConnect`, `powerAutoSuspendMinutes`, `powerAutoScreenOffMinutes`

These SettingsStore properties are serialized, exposed in the settings UI, and reset to defaults by SystemSettingsViewModel, but no service or State singleton reads them at runtime. (Animation settings are the exception; those now flow through `MotionConfig`.)

**Deferred because:** The relevant services would need to observe SettingsStore changes or have a live bridge in `shell.qml` propagate them.

---

## Panel Blur via Hyprland Layer Rules

**Status:** Persisted but no direct effect
**Properties:** `SettingsStore.blurEnabled`, `SettingsStore.blurStrength`, `SettingsStore.panelBlur`

The settings UI exposes blur toggles, and ShellMetrics mirrors them (`panelBlurEnabled`, `panelBlurStrength`), but no window consumes those metrics. Actual blur is controlled by Hyprland: global `decoration.blur` in `~/.config/hypr/modules/decorations.lua`, plus layer rules in `~/.config/hypr/modules/windowrule.lua` (the quickshell namespace gets `no_anim = true`; no per-panel blur rule is currently present, despite a comment describing an intended `ignore_alpha`/`xray` rule). The settings toggles have no runtime effect.

**Deferred because:** Would need to push changes into Hyprland at runtime (e.g. `hyprctl keyword`) or add layer rules keyed off the settings.

---

## Notification Positioning

**Status:** Persisted but not applied
**Property:** `SettingsStore.notificationPosition`

The position setting (top/bottom, left/right) is persisted and shown in the settings UI, but notifications are rendered by Quickshell's native `NotificationServer` (hosted in `state/NotificationState.qml`) at a fixed position. `swaync` has been removed from the session, so there is no external daemon to reconfigure either.

**Deferred because:** The native NotificationServer exposes no position configuration in this Quickshell build; supporting the setting would require a custom positioned notification renderer.

---

## Large Wallpaper Directory Performance

**Status:** No virtualization
**Files:** `panels/WallpaperSelector.qml`, `settings/WallpaperPage.qml`

The wallpaper grid uses `Grid` + `Repeater`, instantiating every wallpaper card at once inside a `Flickable`. With 500+ wallpapers this freezes on first render. (A separate GTK picker, `wallpaper-app`, exists for browsing, but the in-shell panel has the same limitation.)

**Deferred because:** Would need `ListView`/`GridView` with `cacheBuffer` for virtualized rendering.

---

## AboutPage Links Not Clickable

**Status:** Display-only
**File:** `settings/AboutPage.qml`

Repository and documentation URLs are rendered as `SettingRow` subtitle text with no click handler.

**Deferred because:** Would need a link row molecule or an `onClicked` handler that opens URLs (e.g. via `xdg-open`).

---

## ConfigService.configPath Timing

**Status:** Works but fragile
**Files:** `services/ConfigService.qml`, `shell.qml`

`ConfigService.configPath` is wired as a property binding in `shell.qml`. The service's `FileView` binds its `path` to `configPath` with `preload: true`. Guards in `_onLoadFailed()` and `_pushToDisk()` (`if (configPath === "") return`) tolerate the window where the binding has not been evaluated, so the file load and first save are skipped if the path is still empty.

**Risk:** Low. The shell constructs the service with the binding before `onLoaded`/`onLoadFailed` fire, but this is a documented timing assumption.

---

## LockScreen Not Wired

**Status:** WIP, not instantiated
**File:** `windows/LockScreen.qml`

`LockScreen.qml` implements a compositor-backed lock surface: `WlSessionLock` plus a `PamContext` (Quickshell.Services.Pam, config `"hyprlock"`) with password UI. It is NOT instantiated by `shell.qml`, which creates exactly three windows (Shell, PanelSurface, SettingsWindow). The `lock` IPC function in `keybinds/IpcHandler.qml` shells out to `hyprlock` instead.

**Deferred because:** The WlSessionLock/PAM path is a work in progress; wiring it in would replace the `hyprlock` IPC path once it is stable.
