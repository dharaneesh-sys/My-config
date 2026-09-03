-- ################
-- ## AUTOSTART ###
-- ################
-- Single ordered handler — portal → clipboard → wallpaper → polkit → idle → shell
-- Ghostty daemon is handled by its systemd unit (graphical-session.target)
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-hyprland")
    hl.exec_cmd("/usr/lib/xdg-desktop-portal-gtk")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("kdeconnectd")
    hl.exec_cmd("~/.local/bin/restore-session")
    hl.exec_cmd("hyprpm reload")
    hl.exec_cmd("~/.config/hypr/scripts/quickshell-watchdog.sh")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("handy --start-hidden")
    hl.exec_cmd("[workspace 1 ] brave")
    hl.exec_cmd("[workspace 2 silent] ghostty")
end)
