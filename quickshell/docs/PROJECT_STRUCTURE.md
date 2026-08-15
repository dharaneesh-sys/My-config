# Project Structure

> Complete directory tree with descriptions.

---

```
shell/
│
├── shell.qml                          # ShellRoot entry point
│                                      # - Creates Shell + PanelSurface + SettingsWindow
│                                      # - Registers MaterialSymbolsRounded font
│                                      # - Instantiates 5 services (Brightness, Wallpaper,
│                                      #   Theme, Power, Config)
│                                      # - Eager NotificationState reference (owns
│                                      #   org.freedesktop.Notifications from startup)
│                                      # - Live SettingsStore→Runtime bridge
│                                      # - HyprlandFocusGrab + 50ms collapse timer
│                                      # - Registers 11 panels with ExpansionRegistry
│
├── docs/                              # Developer documentation
│
├── tokens/                            # FROZEN design system
│   ├── qmldir                         #   Module Tokens
│   ├── Colors.qml                     #   Semantic color roles + theme switching
│   ├── Typography.qml                 #   Font families + text style presets
│   ├── Spacing.qml                    #   Spatial measurements (unit-based)
│   ├── Radius.qml                     #   Corner radii (unit-based)
│   ├── Motion.qml                     #   Durations, easings, spring configs (FROZEN)
│   ├── Elevation.qml                  #   Shadow levels, z-ordering, blur/overlay
│   ├── Theme.qml                      #   Theme orchestration (switching, metadata)
│   └── palettes/                      #   13 palette singletons
│       ├── Ariadne.qml
│       ├── CatppuccinMacchiato.qml
│       ├── CatppuccinMocha.qml
│       ├── Dracula.qml
│       ├── Dynamic.qml                #     Seeded with Catppuccin Mocha fallback
│       ├── Everforest.qml
│       ├── Gruvbox.qml
│       ├── Nightfox.qml
│       ├── Noir.qml
│       ├── Nord.qml
│       ├── RosePine.qml
│       ├── SolarizedDark.qml
│       └── TokyoNight.qml
│
├── metrics/                           # Layout dimensions (live from SettingsStore)
│   ├── qmldir                         #   Module Metrics
│   └── ShellMetrics.qml              #   Pill/panel/window dimensions
│
├── motion/                            # Runtime animation override layer
│   ├── qmldir                         #   Module Motion
│   └── MotionConfig.qml              #   animationsEnabled, speedFactor, duration(), spring
│
├── state/                             # Reactive State singletons
│   ├── qmldir                         #   Module State
│   ├── ExpansionRegistry.qml         #   Panel registration (string IDs)
│   ├── ExpansionManager.qml          #   5-state lifecycle machine
│   ├── SettingsState.qml             #   Settings window navigation
│   ├── AudioState.qml                #   Native Pipewire binding
│   ├── BrightnessState.qml           #   Written by BrightnessService
│   ├── BatteryState.qml              #   Native UPower binding
│   ├── BluetoothState.qml            #   Native BlueZ binding
│   ├── NetworkState.qml              #   Native NetworkManager binding
│   ├── MediaState.qml                #   Native Mpris binding
│   ├── WallpaperState.qml            #   Written by WallpaperService
│   ├── ThemeState.qml                #   Written by ThemeService
│   ├── LauncherState.qml             #   Native DesktopEntries binding
│   ├── NotificationState.qml         #   Native NotificationServer binding
│   ├── ClockState.qml                #   Native SystemClock binding
│   ├── PowerState.qml                #   Written by PowerService
│   └── IconRegistry.qml              #   Desktop-entry icon index (find)
│
├── services/                          # Service singletons (OS IPC)
│   ├── qmldir                         #   Module Services
│   ├── BrightnessService.qml         #   brightnessctl
│   ├── WallpaperService.qml          #   awww + shared ~/.cache/wallpaper state
│   ├── ThemeService.qml              #   theme-list / theme-switcher scripts
│   ├── PowerService.qml              #   loginctl + systemctl + xdg-open + Quickshell
│   └── ConfigService.qml             #   JSON load/save/migrate (FileView + JsonAdapter)
│
├── viewmodels/                        # Presentation adapters
│   ├── qmldir                         #   Module Viewmodels
│   ├── ControlCenterViewModel.qml    #   Panel VMs (read State)
│   ├── LauncherViewModel.qml
│   ├── ThemeSwitcherViewModel.qml
│   ├── WallpaperSelectorViewModel.qml
│   ├── NotificationCenterViewModel.qml
│   ├── MediaPlayerViewModel.qml
│   ├── CalendarViewModel.qml
│   ├── BluetoothViewModel.qml
│   ├── WiFiViewModel.qml
│   ├── AudioViewModel.qml
│   ├── PowerMenuViewModel.qml
│   ├── AppearanceViewModel.qml       #   Settings VMs (read SettingsStore)
│   ├── BarAndPillViewModel.qml
│   ├── MotionViewModel.qml
│   ├── ControlCenterSettingsViewModel.qml
│   ├── LauncherSettingsViewModel.qml
│   ├── NotificationSettingsViewModel.qml
│   ├── ClockDateSettingsViewModel.qml
│   ├── MediaSettingsViewModel.qml
│   ├── KeybindsSettingsViewModel.qml
│   ├── AboutViewModel.qml
│   └── SystemSettingsViewModel.qml   #   (also reads PowerState)
│
├── components/                        # Reusable UI components
│   ├── qmldir                         #   Module Components
│   ├── PillPanel.qml                 #   The collapsed pill bar (clock + notice OSD)
│   │
│   ├── atoms/                        #   FROZEN primitive components
│   │   ├── qmldir                     #     Module Atoms
│   │   ├── PillShape.qml
│   │   ├── ShellIcon.qml
│   │   ├── ShellText.qml
│   │   ├── AppIcon.qml
│   │   ├── ShellButton.qml
│   │   ├── ShellToggle.qml
│   │   ├── ShellSlider.qml
│   │   ├── SmoothSlider.qml
│   │   ├── SectionHeader.qml
│   │   └── ListItem.qml
│   │
│   └── molecules/                    #   FROZEN composite components
│       ├── qmldir                     #     Module Molecules
│       ├── PanelHeader.qml
│       ├── SearchBar.qml
│       ├── QuickToggle.qml
│       ├── SliderRow.qml
│       ├── SmoothSliderRow.qml
│       ├── ToggleRow.qml
│       ├── ButtonRow.qml
│       ├── SettingRow.qml
│       ├── SettingsCard.qml
│       ├── ThemeCard.qml
│       ├── WallpaperCard.qml
│       ├── MediaMiniCard.qml
│       ├── NotificationCard.qml
│       ├── AppRow.qml
│       ├── QuickSettingsGrid.qml
│       ├── QuickSettingsGridModel.qml
│       ├── DynamicBatteryWidget.qml
│       └── PowerActionsRow.qml
│
├── panels/                            # Expandable panels (pure views)
│   ├── qmldir                         #   Module Panels
│   ├── ControlCenter.qml
│   ├── Launcher.qml
│   ├── ThemeSwitcher.qml
│   ├── WallpaperSelector.qml
│   ├── NotificationCenter.qml
│   ├── MediaPlayer.qml
│   ├── Calendar.qml
│   ├── Bluetooth.qml
│   ├── WiFi.qml
│   ├── Audio.qml
│   └── PowerMenu.qml
│
├── settings/                          # Settings window components
│   ├── qmldir                         #   Module Settings
│   ├── SettingsStore.qml             #   64 persistent properties (singleton)
│   ├── SettingsSerializer.qml        #   JSON ↔ Store (singleton)
│   ├── SettingsRouter.qml           #   Navigation controller
│   ├── SettingsSidebar.qml           #   Vertical nav rail
│   ├── SettingsStack.qml            #   StackLayout with lazy Loaders
│   ├── SettingsPage.qml             #   Page router (13 routes)
│   ├── SettingsPageHeader.qml       #   Title + subtitle
│   ├── SettingsSearch.qml           #   Search field
│   ├── SettingsPlaceholderPage.qml  #   Fallback page
│   ├── AppearancePage.qml
│   ├── ThemePage.qml
│   ├── WallpaperPage.qml
│   ├── BarAndPillPage.qml
│   ├── MotionPage.qml
│   ├── ControlCenterPage.qml
│   ├── LauncherPage.qml
│   ├── NotificationPage.qml
│   ├── ClockDatePage.qml
│   ├── MediaPage.qml
│   ├── KeybindsPage.qml
│   ├── SystemPage.qml
│   └── AboutPage.qml
│
├── windows/                           # Top-level windows
│   ├── qmldir                         #   Module Windows
│   ├── Shell.qml                     #   PanelWindow (pill bar, permanent strut)
│   ├── PanelSurface.qml              #   PanelWindow (floating expanded panel)
│   ├── SettingsWindow.qml            #   FloatingWindow (sidebar + pages)
│   └── LockScreen.qml                #   WlSessionLock + PAM (WIP, NOT wired)
│
└── keybinds/                          # IPC routing
    ├── qmldir                         #   Module Keybinds
    └── IpcHandler.qml               #   Hyprland IPC + dynamic keybinds
```