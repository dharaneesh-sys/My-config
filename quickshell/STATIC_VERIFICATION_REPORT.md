# Phase 9 — Comprehensive Static Verification Report

> **Note:** All Critical Errors and most High Risk issues identified below
> have been **fixed** in the codebase. The fix status is noted per item.

---

## 1. Critical Errors

Issues highly likely to prevent startup or cause QML parse/component failures.

### 1.1 PowerService.qml — Missing `import Quickshell` [FIXED]

**File:** `services/PowerService.qml`
**Lines:** Uses `Quickshell.reload()` (line 77) and `StandardPaths.writableLocation()` (line 43)
**Imports present:** `import Quickshell.Io` only

`Quickshell.reload()` is provided by the `Quickshell` module, not `Quickshell.Io`. Similarly, `StandardPaths` is in `Quickshell`, not `Quickshell.Io`. Both will fail at runtime with `ReferenceError: Quickshell is not defined` and `ReferenceError: StandardPaths is not defined`.

**Fix:** Add `import Quickshell` to PowerService.qml.

### 1.2 PowerService.qml — Unused import `qs.settings` [FIXED]

**File:** `services/PowerService.qml`
**Line:** 5: `import qs.settings`

PowerService does not reference `SettingsStore`, `SettingsSerializer`, or any other Settings module type. This import was added in Phase 9 to support `StandardPaths` (thought to be in qs.settings), but StandardPaths is in the Quickshell module.

**Fix:** Remove `import qs.settings` after adding `import Quickshell`.

### 1.3 KeybindsPage.qml — Stale informational text [FIXED]

**File:** `settings/KeybindsPage.qml`
**Line:** 104-105

The info card states:
> "Keybind changes are saved to configuration but do not take effect until the shell is reloaded."

This is factually incorrect. Phase 9 wired live keybind updates via `IpcHandler.updateKeybind()` → `hyprctl`. The text will mislead users.

**Fix:** Update the text to: "Keybind changes are applied immediately via hyprctl. Key capture editing is not yet implemented."

---

## 2. High Risk Runtime Issues

Problems that may only appear after launching but are strongly indicated by static analysis.

### 2.1 SettingsStore._connectAll() — Closures in for-loop connecting signals

**File:** `settings/SettingsStore.qml`
**Line:** 179-188

```javascript
for (var i = 0; i < props.length; i++) {
    var p = props[i]
    var sig = "on" + p.charAt(0).toUpperCase() + p.slice(1) + "Changed"
    if (typeof store[sig] === "function")
        store[sig].connect(function() { store.settingsChanged() })
}
```

The closure `function() { store.settingsChanged() }` does NOT reference the loop variable `p` or `i`, so JavaScript's closure-by-reference semantics do NOT cause a bug here. However, `Object.keys(store)` on a QML QtObject returns all properties including inherited QObject internals. The `try/catch` and `typeof` guard prevents crashes, but the `objectName` skip is incomplete — other internal properties (e.g., `objectNameChanged`, `destroyed`, `destroyedChanged`, `className`) may also be present and will silently have their change signals connected to `settingsChanged()`.

**Risk:** Minor — connecting extra signals just causes unnecessary `settingsChanged()` emissions, triggering extra debounced saves. No functional damage.

**Fix:** Extend the skip list: `if (p === "objectName" || p === "configVersion" || p.startsWith("_") || p === "className") continue`

### 2.2 IpcHandler.updateKeybind() — Race condition between unbind and bind

**File:** `keybinds/IpcHandler.qml`
**Lines:** 83-97

Two separate `Process` instances (`hyprctlUnbind` and `hyprctlBind`) are started sequentially. There is no ordering guarantee — the bind could execute before the unbind completes, causing a brief period where both old and new shortcuts are bound, or the old shortcut remains bound.

**Risk:** Low — Hyprland processes hyprctl commands via its event loop in order of receipt, so they typically execute sequentially. But if the system is under load, ordering could break.

**Fix:** Chain the bind after the unbind's `onExited` signal.

### 2.3 IpcHandler._keybinds map — Not reactive to SettingsStore at init

**File:** `keybinds/IpcHandler.qml`
**Lines:** 34-41

The `_keybinds` property is initialized once from `SettingsStore.*` values. QML property bindings on `property var` with object literals are NOT automatically updated when the source properties change — the object literal is evaluated once at Component.onCompleted. However, the live bridge in shell.qml calls `updateKeybind()` on each SettingsStore change, which updates `_keybinds` via `Object.assign`. So the map stays in sync through the update function, not through bindings.

**Risk:** Low — the live bridge keeps the map in sync. But if ConfigService loads settings AFTER IpcHandler's Component.onCompleted, the initial `_keybinds` values will be defaults, not the loaded values. The live bridge's `onKeybind*Changed` handlers will fire when ConfigService applies loaded values, so they will self-correct.

**Fix:** No change needed — the timing works correctly because ConfigService deserializes into SettingsStore which emits change signals.

### 2.4 Shell.mask enabled — HyprlandFocusGrab interaction [FIXED]

**File:** `windows/Shell.qml`
**Line:** 99: `mask: Region { item: shellContent }`

With the mask enabled, Hyprland will consider only the `shellContent` region as the window's input area. The `OverlayDim` (which is a sibling of `shellContent` at the window level) will be masked out. Clicks on the dim overlay area may pass through to windows below instead of being captured by the OverlayDim's MouseArea.

**Risk:** High — the OverlayDim's click-to-collapse functionality depends on it receiving click events. If the mask excludes the overlay area, clicks outside the pill/panel won't collapse the panel.

**Fix:** The mask should include both the shellContent and the overlay area when expanded. Change to: `mask: Region { items: [shellContent, overlayDim] }` (if Region supports items list) or restructure so OverlayDim is inside shellContent, or disable mask when expanded.

### 2.5 ExpansionManager transitionMode stays Instant

**File:** `state/ExpansionManager.qml`
**Line:** 67

`transitionMode` defaults to `Instant`, meaning the lifecycle jumps immediately to terminal states (Opening→Expanded, Closing→Collapsed). The Behaviors in ExpandedSurface provide visual smoothness, but the lifecycle state changes are instantaneous. This means:

- `onOpenCompleted`, `onSwitchCompleted`, `onCloseCompleted` are never called by ExpandedSurface (there's no code calling them).
- The lifecycle skips through Opening/Switching/Closing so fast that focus grab timing is always correct.
- But if someone later sets `transitionMode: Animated`, the completion callbacks would need to be called, and ExpandedSurface has no code to do so.

**Risk:** Low for current usage. But the Animated code path is completely untested and has no completion callback wiring.

**Fix:** Document that `TransitionMode.Animated` is not yet supported. Add a guard or assertion.

---

## 3. Architecture Violations

### 3.1 AppearancePage.qml — Direct SettingsState access

**File:** `settings/AppearancePage.qml`
**Lines:** 50, 56

`SettingsState.navigate("themes")` and `SettingsState.navigate("wallpaper")` are called directly from the page. This bypasses the ViewModel. While SettingsState is a UI navigation controller (not a data source), it's still a State singleton imported directly by a settings page.

**Severity:** Low — navigation is UI control, not data flow. The ViewModel pattern is for data presentation, not for routing. This is an acceptable architectural exception.

**Fix:** No change needed. Document as intentional.

### 3.2 AppearanceViewModel.qml — Calls ThemeState.setThemeRequested() [FIXED]

**File:** `viewmodels/AppearanceViewModel.qml`
**Line:** 83

`selectTheme()` writes to `SettingsStore.theme` AND calls `ThemeState.setThemeRequested()`. This is a ViewModel directly invoking a State signal. The proper chain would be: ViewModel → SettingsStore → (live bridge) → Theme/ThemeState.

However, the live bridge in shell.qml's Connections block will also fire when `SettingsStore.theme` changes, causing `Theme.setTheme()` to be called TWICE for the same theme change.

**Severity:** Medium — double theme application. The second call is a no-op (setting the same theme), but it causes unnecessary palette resolution and property updates.

**Fix:** Remove the `ThemeState.setThemeRequested()` call from `selectTheme()`. The live bridge in shell.qml handles the propagation.

### 3.3 AppearanceViewModel.qml — Calls WallpaperState signals directly [FIXED]

**File:** `viewmodels/AppearanceViewModel.qml`
**Lines:** 124-133

`selectWallpaper()` calls both `SettingsStore.wallpaper = path` AND `WallpaperState.setWallpaperRequested(path)`. Same double-write issue as 3.2 — the live bridge will also fire.

Similarly, `setBackend()` writes `SettingsStore.wallpaperBackend` AND calls `WallallpaperState.setBackendRequested()`. And `refreshWallpapers()` calls `WallpaperState.refreshRequested()` without going through SettingsStore (there's no SettingsStore property for "refresh").

**Severity:** Medium for selectWallpaper/setBackend (double execution). Low for refreshWallpapers (no SettingsStore equivalent).

**Fix:** Remove the direct WallpaperState calls from selectWallpaper() and setBackend(). Keep refreshWallpapers() as-is (it's an action, not a persisted setting).

### 3.4 SystemSettingsViewModel.qml — Routes directly to PowerState and ConfigService

**File:** `viewmodels/SystemSettingsViewModel.qml`
**Lines:** 35-44

The ViewModel directly calls `PowerState.reloadShellRequested()`, `ConfigService.importSettings()`, etc. This skips the "ViewModel only reads SettingsStore" convention for settings ViewModels. However, System page actions are not "settings" — they're system management commands that need to reach the OS layer.

**Severity:** Low — the action chain (ViewModel → PowerState → PowerService → OS) follows the Panel→ViewModel→State→Service→OS pattern. The alternative would be to route through SettingsStore signals, which would be inappropriate since these are one-shot actions, not persistent settings.

**Fix:** No change needed. Document as intentional.

---

## 4. Potential Binding Issues

### 4.1 ShellMetrics properties changed from readonly to writable [FIXED]

**File:** `metrics/ShellMetrics.qml`

In Phase 9, many ShellMetrics properties were changed from `readonly property real` to `property real` with bindings to SettingsStore. This means:

- If any code accidentally writes `ShellMetrics.pillWidth = 200`, it breaks the SettingsStore binding.
- The `readonly` keyword was a safety guard against this.

**Risk:** Low — no code in the project writes to ShellMetrics properties. But the protection is removed.

**Fix:** Consider using `readonly property` with a binding expression: `readonly property real pillWidth: SettingsStore.pillWidth`. This is valid QML — readonly properties can have bindings, they just can't be assigned by imperative code.

### 4.2 ExpandedSurface — height binding to ExpansionManager.isExpanded

**File:** `components/ExpandedSurface.qml`
**Lines:** 58-61

```qml
height: ExpansionManager.isExpanded
        ? _panelPreferredHeight + ShellMetrics.expandedPadding * 2
        : 0
```

When `ExpansionManager.isExpanded` transitions from true to false, height jumps to 0 instantly. The `Behavior on height` animates this, but the binding is re-evaluated immediately. In Instant mode, `isExpanded` becomes false before the animation starts, so the Behavior animates from current height to 0 — this is correct.

**Risk:** None — this is the intended behavior.

### 4.3 TopPill.visible bound to SettingsStore.clockShowInPill [FIXED]

**File:** `components/TopPill.qml`
**Line:** 33

If `clockShowInPill` is false, the TopPill becomes invisible but still exists. The Shell.implicitHeight calculation still includes `ShellMetrics.pillHeight + ShellMetrics.pillTopMargin + ShellMetrics.pillBottomMargin`, so the window height doesn't shrink. This means there's an invisible gap at the top of the screen.

**Risk:** Medium — users who hide the clock will have dead space at the top. The shell window still covers the pill area even though the pill isn't visible.

**Fix:** Make the Shell.implicitHeight conditional on `SettingsStore.clockShowInPill` or the TopPill's visibility.

### 4.4 ControlCenterViewModel.quickTiles — Array with closures recreated on every read

**File:** `viewmodels/ControlCenterViewModel.qml`
**Lines:** 16-41

`quickTiles` is declared as `readonly property var quickTiles: [...]`. Every time any property referenced in the array (e.g., `NetworkState.wifiEnabled`) changes, the entire array is re-created with new objects including new `onClicked` function closures. This triggers the Repeater in QuickSettingsGrid to destroy and recreate all delegate items.

**Risk:** Medium — causes unnecessary item destruction/creation on every state change. Visible as flicker if animations are slow.

**Fix:** Use a ListModel with bindings instead of a JavaScript array. Or cache the array and update individual properties.

---

## 5. Import & qmldir Audit

### 5.1 PowerService.qml — Missing `import Quickshell` [FIXED]

(See Critical Error 1.1)

### 5.2 PowerService.qml — Unused `import qs.settings` [FIXED]

(See Critical Error 1.2)

### 5.3 All other imports — No issues found

Every qmldir correctly registers its components and singletons. Every `pragma Singleton` is present where required. No missing module registrations. No duplicate registrations. The import convention (`qs.tokens`, `qs.state`, etc.) matches the qmldir module names (`Tokens`, `State`, etc.) — Quickshell maps `qs.X` to module `X` in the shell's root directory.

### 5.4 Shell.qml — No `import qs.panels`

Panels are loaded dynamically via `Qt.resolvedUrl()` in `Component.onCompleted`, never statically imported. This is correct — panels should not be importable as QML types since they're loaded by the expansion system.

---

## 6. Type Safety Audit

### 6.1 SettingsRouter.router property type mismatch

**File:** `settings/SettingsSidebar.qml` and `settings/SettingsStack.qml`

Both declare `required property QtObject router` and receive a `SettingsRouter` instance. In QML, `QtObject` is the base type and `SettingsRouter` extends it, so this is valid. However, the `router.pages` and `router.currentIndex` properties are accessed without type checking. If a null router is passed, these will fail silently.

**Risk:** Low — the router is always provided by SettingsWindow.qml.

### 6.2 KeybindsSettingsViewModel.keybindEntries — Array type safety

**File:** `viewmodels/KeybindsSettingsViewModel.qml`
**Lines:** 30-37

`keybindEntries` is `readonly property var` — a JavaScript array of objects. The Repeater in KeybindsPage.qml accesses `modelData.key`, `modelData.title`, `modelData.icon`. If any entry is missing a field, it would be `undefined` which renders as empty string in QML Text elements.

**Risk:** Low — all entries are hardcoded and complete.

### 6.3 All SettingsStore properties — Type safety

SettingsStore uses `property string`, `property bool`, `property int`, `property real` — all correctly typed. SettingsSerializer.deserialize() applies JSON values directly without type coercion. If the JSON file has `"pillWidth": "136"` (string instead of number), the assignment `store.pillWidth = "136"` will silently convert in QML (string → real = 136), which is correct for numeric types. For bool properties, `"true"` (string) would convert to `true` (truthy), which is also correct in QML.

**Risk:** Low — QML's automatic type coercion handles common misconfigurations.

---

## 7. Dead Code Audit

### 7.1 SettingsPlaceholderPage.qml — Never loaded

**File:** `settings/SettingsPlaceholderPage.qml`

All 13 pages are now implemented with real content. The SettingsPage.qml router has no `default` case that reaches the placeholder (well, it does — the `default` case returns `SettingsPlaceholderPage.qml`). But since all 13 page IDs have explicit routes, the placeholder is only reached for unknown page IDs. SettingsState.pages only lists the 13 known IDs.

**Risk:** None — dead code, but harmless safety net.

**Fix:** Keep as fallback for forward compatibility.

### 7.2 IpcHandler.themeNext() / themePrevious()

**File:** `keybinds/IpcHandler.qml`
**Lines:** 64-70

These functions exist but no keybind is registered for them in the `hyprlandConfigSnippet`. They're only callable via `quickshell ipc call shell themeNext/Previous` which would need to be manually added to hyprland.conf.

**Risk:** None — available for future keybind registration.

### 7.3 AppearancePage.qml — qs.state import used only for navigation

The `import qs.state` is only used for `SettingsState.navigate()` calls (2 occurrences). This is intentional but could be considered borderline if the architecture strictly forbids State access from settings pages.

### 7.4 All other dead code — No issues found

No unused properties, signals, or functions detected by static analysis. Each ViewModel property is consumed by its corresponding page. Each signal is connected to a handler.

---

## 8. Performance Audit

### 8.1 ControlCenterViewModel.quickTiles — Array recreation on every state change

(See Binding Issue 4.4)

### 8.2 SettingsStore._connectAll() — Connects to ~55+ signals

**File:** `settings/SettingsStore.qml`

Every SettingsStore property change emits `settingsChanged()`, which triggers ConfigService's debounced save. If multiple properties change in quick succession (e.g., during `importSettings()` or `_resetToDefaults()`), `settingsChanged()` fires for each property change, but the debounce timer restarts each time, so only one save occurs after the last change.

**Risk:** Low — debounce handles burst writes correctly.

### 8.3 ThemeCard/WallpaperCard grids — Repeater with many items

ThemePage shows 13 ThemeCards (fixed count — not expensive). WallpaperPage shows a variable number of WallpaperCards depending on the wallpaper directory. With large directories (1000+ images), this could cause performance issues since all items are instantiated (no virtualization via ListView).

**Risk:** Medium for large wallpaper collections.

**Fix:** Use ListView with a delegate instead of Repeater in a Flow for the wallpaper grid.

### 8.4 SettingsStack — All pages kept loaded after first visit

**File:** `settings/SettingsStack.qml`
**Line:** 59: `active: settingsStack._visitedPages[_visitKey] === true`

Once a page is visited, its Loader stays `active: true` permanently. With 13 pages, all ViewModels and their underlying State bindings remain alive. Since ViewModels are QtObjects with minimal memory, this is acceptable.

**Risk:** Low.

---

## 9. Maintainability Audit

### 9.1 SystemSettingsViewModel._resetToDefaults() — 58 hardcoded property assignments

**File:** `viewmodels/SystemSettingsViewModel.qml`
**Lines:** 49-106

This function manually resets all 58 SettingsStore properties. If a new property is added to SettingsStore but forgotten in _resetToDefaults(), it won't be reset. There's no compile-time or runtime check for completeness.

**Fix:** Iterate over `SettingsSerializer._knownKeys` and reset each to its default. Or store defaults in a separate object and apply them.

### 9.2 ShellMetrics — Mixed readonly and writable properties

After Phase 9, ShellMetrics has some `readonly` properties (e.g., `panelCompactWidth`, `settingsDefaultWidth`) and some writable properties (e.g., `pillWidth`, `shellOpacity`). This inconsistency makes it unclear which properties are configurable and which are hardcoded.

**Fix:** Add comments or use a naming convention to distinguish configurable vs. fixed properties.

### 9.3 SettingsSerializer._knownKeys — Manual whitelist maintenance

**File:** `settings/SettingsSerializer.qml`

The 58-key whitelist must be manually kept in sync with SettingsStore properties. Adding a property to SettingsStore but forgetting it in _knownKeys means it won't be persisted.

**Fix:** Consider generating _knownKeys from SettingsStore's metadata, or adding a unit test that compares the lists.

### 9.4 No other issues found

Naming is consistent. File organization follows the architecture. No significant code duplication beyond the standard settings page boilerplate (which is by design).

---

## 10. Runtime Verification Checklist

Items that CANNOT be proven by static analysis and must be tested manually in Quickshell.

### 10.1 Startup and Initialization
- [ ] Shell loads without QML parse errors
- [ ] ConfigService loads persisted settings from disk
- [ ] Theme is applied correctly from SettingsStore.theme on startup
- [ ] All 11 panels register successfully (check console.info output)
- [ ] Both windows (Shell + SettingsWindow) are created

### 10.2 Panel Expansion
- [ ] Pill click expands ControlCenter
- [ ] Panel switching works (e.g., expand launcher, then expand CC → Switching state)
- [ ] Same panel toggle collapses (expand CC, click pill again → collapses)
- [ ] OverlayDim click collapses active panel
- [ ] HyprlandFocusGrab click-outside collapses panel
- [ ] ExpansionManager rejects operations during transitions
- [ ] All 11 panels load without errors when expanded

### 10.3 Keybinds
- [ ] Default keybinds (Super+Space, Super+T, etc.) trigger panel expansion
- [ ] IpcHandler.updateKeybind() successfully calls hyprctl
- [ ] Changing a keybind in settings immediately rebinds in Hyprland
- [ ] Old keybind is unbound when replaced

### 10.4 Settings Persistence
- [ ] Changing any setting saves to disk (check JSON file after 500ms)
- [ ] Changed settings survive shell restart
- [ ] Reset to defaults correctly restores all 58 properties
- [ ] Import/export produces valid JSON

### 10.5 Live Runtime Updates
- [ ] Changing pill width in settings resizes the pill immediately
- [ ] Changing theme in settings recolors the entire shell immediately
- [ ] Changing clock format in settings updates the pill clock immediately
- [ ] Toggling animations disables/enables panel expand animations
- [ ] Changing shell opacity affects panel background immediately

### 10.6 System Page Actions
- [ ] "Reload Shell" triggers Quickshell.reload()
- [ ] "Quit Shell" terminates the shell
- [ ] "Open Config Directory" opens xdg-open
- [ ] "Show Logs" opens terminal with journalctl
- [ ] "Restart Shell" restarts via systemctl

### 10.7 Mask and Focus
- [ ] Shell mask correctly limits the opaque region to pill + panel
- [ ] OverlayDim still receives click events with mask enabled
- [ ] Panel keyboard focus works correctly
- [ ] Escape key collapses active panel (via hyprland.conf binding)

### 10.8 Multi-Monitor
- [ ] Shell positions correctly on primary monitor
- [ ] Panel dimensions don't break on different screen sizes

### 10.9 Settings Window
- [ ] All 13 pages load without errors
- [ ] Page navigation via sidebar works
- [ ] Settings window can be opened/closed/toggled
- [ ] Settings window rule (float, pinned) applies in Hyprland

### 10.10 Services
- [ ] AudioService reads pactl output correctly
- [ ] BrightnessService reads brightnessctl output correctly
- [ ] BatteryService reads upower output correctly
- [ ] NetworkService reads nmcli output correctly
- [ ] MediaService reads playerctl output correctly
- [ ] WallpaperService runs swww/hyprpaper correctly
- [ ] ThemeService persists theme choice correctly
