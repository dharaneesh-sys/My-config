import QtQuick
import QtQuick.Layouts

import qs.tokens
import qs.components.atoms
import qs.state

import Quickshell

Item {
    id: root
    
    implicitHeight: 56
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth
    
    RowLayout {
        anchors.fill: parent
        spacing: Spacing.sm
        
        PowerTile {
            Layout.fillWidth: true
            iconName: "lock"
            label: "Lock"
            action: function() {
                ExpansionManager.requestCollapse()
                Quickshell.execDetached(["sh", "-c", "pidof hyprlock >/dev/null || exec hyprlock"])
            }
        }
        PowerTile {
            Layout.fillWidth: true
            iconName: "logout"
            label: "Logout"
            requiresConfirm: true
            action: function() {
                ExpansionManager.requestCollapse()
                Quickshell.execDetached(["hyprctl", "dispatch", "exit"])
            }
        }
        PowerTile {
            Layout.fillWidth: true
            iconName: "bedtime"
            label: "Sleep"
            action: function() {
                ExpansionManager.requestCollapse()
                Quickshell.execDetached(["systemctl", "suspend"])
            }
        }
        PowerTile {
            Layout.fillWidth: true
            iconName: "restart_alt"
            label: "Restart"
            requiresConfirm: true
            action: function() {
                ExpansionManager.requestCollapse()
                Quickshell.execDetached(["systemctl", "reboot"])
            }
        }
        PowerTile {
            Layout.fillWidth: true
            iconName: "power_settings_new"
            label: "Power off"
            requiresConfirm: true
            action: function() {
                ExpansionManager.requestCollapse()
                Quickshell.execDetached(["systemctl", "poweroff"])
            }
        }
    }
    
    component PowerTile : Rectangle {
        property string iconName: ""
        property string label: ""
        property bool requiresConfirm: false
        property var action: null
        
        property bool _confirmState: false
        
        height: 48
        radius: Radius.sm
        color: _confirmState ? Colors.error
                             : (ma.containsMouse ? Colors.surfaceRaised
                                                : Colors.surface)
        
        Behavior on color {
            ColorAnimation { duration: Motion.duration.fast }
        }
        
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2
            ShellIcon {
                Layout.alignment: Qt.AlignHCenter
                name: _confirmState ? "warning" : iconName
                iconSize: 20
                iconColor: _confirmState ? Colors.fgOnAccent : Colors.fg
            }
            ShellText {
                Layout.alignment: Qt.AlignHCenter
                text: _confirmState ? "Confirm?" : label
                role: ShellText.Role.Caption
                textColor: _confirmState ? Colors.fgOnAccent : Colors.fg
                font.pixelSize: 10
            }
        }
        
        Timer {
            id: confirmTimer
            interval: 3000
            onTriggered: _confirmState = false
        }
        
        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            onClicked: {
                if (requiresConfirm) {
                    if (!_confirmState) {
                        _confirmState = true
                        confirmTimer.start()
                    } else {
                        _confirmState = false
                        confirmTimer.stop()
                        if (action) action()
                    }
                } else {
                    if (action) action()
                }
            }
        }
    }
}
