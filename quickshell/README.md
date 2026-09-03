# Quickshell Shell for Hyprland

A modular Quickshell status bar and shell for Hyprland. The shell renders a
permanent pill-shaped bar on the monitor, expands a floating surface for
widget panels such as the launcher and control center, and exposes a separate
settings window. Everything is driven by a small IPC surface so keybinds and
scripts can talk to it directly. The config runs under `quickshell-git` 0.3.0
from the AUR.

This README is the entry point. The `docs/` directory holds the deep dives
(architecture, services, panels, settings, themes, keybinds, testing, known
limitations).

## Requirements

- Hyprland or another wlroots compositor
- `quickshell-git` 0.3.0 from the AUR
- Material Symbols Rounded font, family `MaterialSymbolsRounded`, registered
  with Qt via a `FontLoader` in `shell.qml`

## Getting Started

Run the shell from the config root:

```sh
cd ~/.config/quickshell
quickshell
```

The shell runs as a single instance. Settings live in
`~/.config/quickshell/settings.json`, read and persisted by `ConfigService`.

The display is a single monitor, `eDP-1`, at logical 1440x900 and scale 1.33.
Exactly three top-level windows are instantiated in `shell.qml`:

| Window | Type | Behavior |
|---|---|---|
| `Shell` | PanelWindow | Permanent pill strip, `exclusionMode` Normal, which reserves a strut |
| `PanelSurface` | PanelWindow | Always-mapped floating layer above windows; visibility controlled by a mask `Region{item: panelRect}` |
| `SettingsWindow` | FloatingWindow | Visible while `SettingsState.isOpen` |

The layer surfaces are static by design. Expansion happens inside QML: the
`panelRect` height and the mask change, the window geometry never does. A
`windows/LockScreen.qml` exists but is not wired into `shell.qml`; the IPC
`lock` function runs `hyprlock` instead.

## Module Map

Each QML module ships its own `qmldir`.

| Module | Purpose |
|---|---|
| `qs.tokens` | Frozen design system: 7 token files plus 13 palettes |
| `qs.metrics` | `ShellMetrics`, layout dimensions read live from `SettingsStore` |
| `qs.motion` | `MotionConfig`, the runtime animation override layer |
| `qs.state` | 16 reactive singletons holding state and expansion |
| `qs.services` | 5 services that talk to the OS |
| `qs.viewmodels` | 22 viewmodels, presentation adapters between state and UI |
| `qs.components` | Root `PillPanel` plus 10 atoms and 18 molecules |
| `qs.panels` | 12 expandable panel views |
| `qs.settings` | `SettingsStore` (63 properties), serializer, router, sidebar, stack, pages |
| `qs.windows` | 4 files: `Shell`, `PanelSurface`, `SettingsWindow`, `LockScreen` |
| `qs.keybinds` | `IpcHandler`, the IPC surface |

State singletons in `qs.state`: `ExpansionRegistry`, `ExpansionManager`,
`SettingsState`, `IconRegistry`, `AudioState`, `BatteryState`,
`BluetoothState`, `NetworkState`, `MediaState`, `NotificationState`,
`ClockState`, `LauncherState`, `ThemeState`, `WallpaperState`, `PowerState`,
`BrightnessState`.

The 5 services are:

| Service | Backend |
|---|---|
| `BrightnessService` | `brightnessctl` |
| `ConfigService` | JSON at `~/.config/quickshell/settings.json`, 500 ms save debounce, atomic tmp + mv write, schema migration to v1 |
| `PowerService` | `loginctl`, plus reload/quit |
| `ThemeService` | theme switching |
| `WallpaperService` | wallpaper backend `awww` |

Media, audio, network, bluetooth, battery, and notifications come from native
Quickshell bindings inside `qs.state`, not from services. Services write to
state singletons; panels only read state and never import services.

## Panels

Twelve panels are registered in `shell.qml` with approximate sizes. "Full"
width means the live `panelMaxWidth` value, around 500; the panel surface
itself is 600 high.

| Panel | Width x Height |
|---|---|
| launcher | full (about 500) x 520 |
| control-center | 340 x 520 |
| theme-switcher | 300 x 260 |
| wallpaper-selector | 680 x 520 |
| notification-center | full (about 500) x 520 |
| media-player | 340 x 300 |
| calendar | 340 x 400 |
| bluetooth | 340 x 420 |
| wifi | full (about 500) x 420 |
| audio | 340 x 300 |
| power-menu | 280 x 260 |
| clipboard | full (about 500) x 520 |

## Keybinds

Default bindings in the Hyprland `binds.lua`:

| Binding | Action |
|---|---|
| Super+Space | expand launcher |
| Super+M | expand media-player |
| Super+Shift+M | lock |
| Super+N | expand notification-center |
| Super+W | expandWallpapers theme |
| Super+T | expand theme-switcher |
| Super+I | expand control-center |
| Super+Shift+I | expandWallpapers all |
| Super+Comma | settingsToggle |
| Super+Escape | collapse |
| Super+V | expand clipboard |

## IPC

The IPC target is named `shell`. List the surface and inspect functions with:

```sh
quickshell ipc show
```

Nine functions are exposed:

| Function | Arguments |
|---|---|
| `expand` | `panelId` |
| `collapse` | none |
| `lock` | none |
| `expandWallpapers` | `"theme"` or `"all"` |
| `settingsOpen` | `pageId` |
| `settingsClose` | none |
| `settingsToggle` | none |
| `themeNext` | none |
| `themePrevious` | none |

Drive the shell from scripts or Hyprland binds:

```sh
quickshell ipc call shell expand launcher
quickshell ipc call shell settingsToggle
quickshell ipc call shell lock
quickshell ipc call shell collapse
```

`quickshell ipc call shell collapse` exits 0.

## Customization

- Runtime settings live in `settings.json`; the schema is `SettingsStore` in
  `qs.settings`. Live defaults include theme `"rose-pine"`, wallpaper backend
  `"awww"`, `blurEnabled` false, `shellOpacity` about 0.44, `pillWidth` about
  123, `pillHeight` about 31.5, `panelMaxWidth` about 500.6,
  `panelCornerRadius` 16, `pillCornerRadius` 48, `expandDuration` 290,
  `collapseDuration` 289, `notificationTimeout` 5000,
  `notificationPosition` `"top-right"`, `launcherMaxResults` 7, and the six
  keybind settings matching the defaults above, with `settingsPageId`
`"bar-pill"`. The file holds 63 keys total, matching the 63
   `SettingsStore` properties (including the window-state entries
   `settingsX`, `settingsY`, `settingsW`, `settingsH`, and
   `settingsPageId`).
- Theming goes through the tokens and palettes in `qs.tokens`. There are 13
  palettes: ariadne, catppuccin-macchiato, catppuccin-mocha, dracula,
  dynamic, everforest, gruvbox, nightfox, noir, nord, rose-pine (labeled
  "Rosé Pine"), solarized-dark, and tokyo-night. The colors token default
  enum is tokyo-night, but the live theme is rose-pine.
- Tokens are FROZEN; do not rename them. Note that `tokens/Motion.qml` is the
  renamed `Animation.qml` token.

For depth, read the docs: `docs/ARCHITECTURE.md`, `docs/SERVICES.md`,
`docs/PANELS.md`, `docs/SETTINGS.md`, `docs/THEMES.md`, `docs/KEYBINDS.md`,
`docs/TESTING.md`, `docs/KNOWN_LIMITATIONS.md`.

## Development and Testing

Tests live in `tests/` and run under `quickshell` with the `-s` test surface:

- `tests/M0-motionconfig.qml`
- `tests/M1-pillpanel.qml`
- `tests/M2-wave2.qml`
- `tests/panels/TestPanel.qml`

`MotionConfig` in `qs.motion` is the runtime animation override layer. It
exposes `animationsEnabled`, `speedFactor` (clamped to
`max(0.25, 1 / max(0.25, animationSpeed))`), a `duration()` that scales
durations or returns 0, and `spring{stiffness, damping, mass, epsilon}`.
