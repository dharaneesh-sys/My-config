# Testing

> Complete runtime QA checklist for the Quickshell desktop shell.

---

## Window Model (Wave 2)

The shell runs exactly three layer surfaces:

| Surface | Type | Behavior |
|---|---|---|
| Shell | PanelWindow | Permanent pill strip, constant height, owns the exclusive strut. Masked to the pill pixels. |
| PanelSurface | PanelWindow | Full-width floating strip, **always mapped**. Holds the expanded panel. ExclusionMode.Ignore, aboveWindows. |
| SettingsWindow | FloatingWindow | Floating settings UI. Position managed by the compositor. |

Panel expansion is QML-driven: the inner `panelRect` height springs 0 → content while the window geometry stays stable (`pillTopMargin + panelSurfaceHeight`). Collapse never unmaps the surface; the `Region` mask tracks `panelRect`, so a collapsed panel is fully transparent and passes input through.

---

## 1. Startup

| # | Test | Steps | Expected |
|---|---|---|---|
| 1.1 | Shell loads | Launch Quickshell | Shell window (pill strip) appears at top of screen |
| 1.2 | Pill visible | Observe top of screen | Clock pill centered, showing time |
| 1.3 | Settings window hidden | Check after startup | Settings window not visible |
| 1.4 | Config loaded | Check console output | `ConfigService: loaded from <path>` and `SettingsSerializer: applied N settings from config` |
| 1.5 | Panels registered | Check console output | `Shell: registered 12 panels` |
| 1.6 | Persisted theme applied | Observe shell colors | Colors match `SettingsStore.theme` (currently "rose-pine") |
| 1.7 | Services started | Check console output | 5 services (BrightnessService, WallpaperService, ThemeService, PowerService, ConfigService), no per-service errors |
| 1.8 | No QML warnings | Check console output | Zero `qrc:` or `ReferenceError` messages |

---

## 2. Expansion

| # | Test | Steps | Expected |
|---|---|---|---|
| 2.1 | Pill click expands CC | Click the pill | ControlCenter panel appears below the pill |
| 2.2 | Same pill click collapses | Click pill again | CC collapses, pill only |
| 2.3 | Click outside collapses | Expand CC, click desktop | Panel collapses via HyprlandFocusGrab (click-outside), after ~50ms delay |
| 2.4 | Focus loss collapses | Expand CC, activate another window | CC collapses |
| 2.5 | Panel switching | Expand launcher, then expand CC | Launcher collapses, CC expands |
| 2.6 | Invalid transition rejected | Rapidly click pill 5x | No crash, final state correct |
| 2.7 | Mask passes input through | Expand CC, click the (collapsed) transparent strip | Click reaches the window below; no stray panel surface intercepts |
| 2.8 | Escape collapses | Expand panel, press Escape | Panel collapses (WindowShortcut + Keys handler) |

---

## 3. Panels

| # | Test | Steps | Expected |
|---|---|---|---|
| 3.1 | Launcher loads | Super+Space | Search bar + app list visible |
| 3.2 | ThemeSwitcher loads | Super+T | Theme grid with 13 cards |
| 3.3 | WallpaperSelector loads | Super+W | Wallpaper grid or empty state |
| 3.4 | NotificationCenter loads | Super+N | Notification list visible |
| 3.5 | MediaPlayer loads | Super+M | Media controls visible |
| 3.6 | ControlCenter loads | Click pill | Quick toggles + sliders visible |
| 3.7 | Calendar loads | Programmatic expand | Calendar grid visible |
| 3.8 | Bluetooth loads | Programmatic expand | Bluetooth panel visible |
| 3.9 | WiFi loads | Programmatic expand | WiFi list visible |
| 3.10 | Audio loads | Programmatic expand | Audio sliders visible |
| 3.11 | PowerMenu loads | Programmatic expand | Lock/Suspend/Reboot/Shutdown visible |
| 3.12 | No panel imports State | Static: `grep "import qs.state" panels/*.qml` | Zero results |
| 3.13 | No panel imports Services | Static: `grep "import qs.services" panels/*.qml` | Zero results |
| 3.14 | Clipboard loads | Programmatic expand | Search bar + empty/loading placeholder visible |

Panels read State singletons only. Services write to State; panels never touch Services.

---

## 4. Settings

| # | Test | Steps | Expected |
|---|---|---|---|
| 4.1 | Open settings | Super+Comma | Settings window appears |
| 4.2 | Close settings | Click ✕ button | Settings window hides |
| 4.3 | Navigate sidebar | Click each sidebar icon | Correct page loads |
| 4.4 | All 13 pages load | Navigate to each page | No QML errors, content visible |
| 4.5 | Appearance page | Toggle blur | Blur setting updates |
| 4.6 | Theme page | Click a theme card | Theme changes immediately |
| 4.7 | Bar & Pill page | Drag pill width slider | Pill resizes in real-time |
| 4.8 | Motion page | Toggle animations | Panel expand animations toggle (via MotionConfig gate) |
| 4.9 | Keybinds page | Click Edit button | Editing indicator appears |
| 4.10 | System page | Click "Export Settings" | JSON exported (check console) |
| 4.11 | About page | Navigate to About | Version, theme, credits visible |

---

## 5. Persistence

| # | Test | Steps | Expected |
|---|---|---|---|
| 5.1 | Settings save | Change any setting, wait 1s | `settings.json` updated on disk |
| 5.2 | Settings survive restart | Change theme, restart shell | Theme persists |
| 5.3 | Reset to defaults | Click "Reset to Defaults" | All 58 persisted properties restore to defaults; the 5 window-state entries (size/page) are left untouched |
| 5.4 | Debounce works | Rapidly change a slider | Only one save after 500ms of silence |
| 5.5 | Atomic write | Check disk during save | No partial `.json` file left after save completes (FileView atomicWrites) |
| 5.6 | Import settings | Import valid JSON | Properties apply, shell updates |
| 5.7 | Export settings | Export settings | Valid JSON with all 63 known keys |

---

## 6. Services

| # | Test | Steps | Expected |
|---|---|---|---|
| 6.1 | Audio volume read | Open CC | Volume slider shows current system volume |
| 6.2 | Audio volume set | Drag volume slider | System volume changes |
| 6.3 | Brightness read | Open CC | Brightness slider shows current level |
| 6.4 | Brightness set | Drag brightness slider | Screen brightness changes |
| 6.5 | Battery status | Open CC (on laptop) | Battery percentage visible |
| 6.6 | WiFi status | Open WiFi panel | Current network shown |
| 6.7 | Media status | Open Media panel with player running | Track info, play/pause work |
| 6.8 | Clock tick | Observe pill for 2s | Time updates every second |
| 6.9 | Wallpaper set | Select wallpaper in selector | Desktop wallpaper changes (awww backend) |
| 6.10 | Service failure graceful | Kill brightnessctl (BrightnessService backend), open CC | No crash, default values shown |

---

## 7. Keybinds

| # | Test | Steps | Expected |
|---|---|---|---|
| 7.1 | Super+Space | Press Super+Space | Launcher expands |
| 7.2 | Super+T | Press Super+T | ThemeSwitcher expands |
| 7.3 | Super+W | Press Super+W | WallpaperSelector expands |
| 7.4 | Super+N | Press Super+N | NotificationCenter expands |
| 7.5 | Super+M | Press Super+M | MediaPlayer expands |
| 7.6 | Super+Comma | Press Super+Comma | Settings window toggles |
| 7.7 | Escape | Expand panel, press Escape | Panel collapses |
| 7.8 | Dynamic rebind | Change keybind in settings | Old shortcut stops, new shortcut works |
| 7.9 | Keybind persists | Change keybind, restart | New keybind still active |
| 7.10 | Super+V | Press Super+V | Clipboard panel expands |

---

## 8. Multi-Monitor

| # | Test | Steps | Expected |
|---|---|---|---|
| 8.1 | Shell on primary | Observe multi-monitor setup | Shell appears on primary monitor |
| 8.2 | Settings window position | Open settings | Window centered on primary (compositor-managed) |
| 8.3 | Panel dimensions | Expand panel on different resolution | Panel content width never exceeds `panelMaxWidth` (full-width strip clipped to content) |

---

## 9. Animations

| # | Test | Steps | Expected |
|---|---|---|---|
| 9.1 | Panel expand animation | Expand CC | Panel height springs 0 → content (~280ms token scaled by MotionConfig) |
| 9.2 | Panel collapse animation | Collapse CC | Smooth reverse animation |
| 9.3 | Corner radius | Expand panel | Panel uses `panelCornerRadius`; pill keeps `pillCornerRadius` |
| 9.4 | Content fade | Expand CC | Panel content fades/scales in; no dim overlay exists |
| 9.5 | Animations disabled | Toggle off in Motion settings | Expand/collapse is instant (MotionConfig gate) |
| 9.6 | Speed change | Set animation speed to 2.0 | Durations halve (speedFactor = 1/speed) |
| 9.7 | Theme transition | Switch theme | All colors recolor immediately |

---

## 10. Performance

| # | Test | Steps | Expected |
|---|---|---|---|
| 10.1 | Startup time | Measure time to interactive | < 2 seconds |
| 10.2 | Panel expand time | Measure CC expand | < 400ms (animation + render) |
| 10.3 | Settings page load | Navigate to unvisited page | < 100ms first load |
| 10.4 | Theme switch time | Switch theme | < 200ms for full recolor |
| 10.5 | Memory stable | Run for 5 minutes | No continuous memory growth |
| 10.6 | Service poll overhead | Monitor CPU with all services running | < 2% CPU average |
| 10.7 | Large wallpaper dir | Set wallpaper dir with 500+ images | WallpaperSelector loads without freeze |
| 10.8 | Rapid panel switching | Rapidly expand/collapse 10x | No crash, no memory leak |

---

## 11. Live Update Verification

| # | Test | Steps | Expected |
|---|---|---|---|
| 11.1 | Pill width live | Change pillWidth in settings | Pill resizes immediately (ShellMetrics binding) |
| 11.2 | Theme live | Change theme in settings | All colors update immediately |
| 11.3 | Clock format live | Toggle 24h in settings | Pill clock format changes immediately |
| 11.4 | Animations live | Toggle animations in settings | Next expand/collapse respects toggle (MotionConfig gate) |
| 11.5 | Panel corner radius live | Change panelCornerRadius in settings | Panel corners update immediately |
| 11.6 | Keybinds live | Change keybind in settings | New shortcut works immediately |
| 11.7 | Wallpaper dir live | Change wallpaper directory in settings | Wallpaper list refreshes |
| 11.8 | Settings window size | Resize the settings window, reopen | Size persists (settingsW/settingsH write-back) |
| 11.9 | Settings page persists | Open a page, close, reopen settings | Last-visited page restored (settingsPageId) |

---

## 12. Edge Cases

| # | Test | Steps | Expected |
|---|---|---|---|
| 12.1 | Empty config file | Delete settings.json, start shell | Defaults created, no crash |
| 12.2 | Corrupt config file | Write invalid JSON, start shell | Warning logged, defaults used |
| 12.3 | Unknown theme key | Set theme to "nonexistent" | Warning logged, current theme kept, no crash |
| 12.4 | No audio backend | Kill PipeWire, start shell | Audio values default, no crash |
| 12.5 | No wallpaper backend | Disable awww backend | Wallpaper features degrade gracefully, no crash |
| 12.6 | Zero pill dimensions | Set pillWidth to 0 | Shell handles without crash |
| 12.7 | Very long shortcut | Set keybind to very long string | No crash (hyprctl may reject) |
| 12.8 | Collapsed surface input | Observe PanelSurface while collapsed | Fully transparent, all input passes through (empty mask) |
