import QtQuick
import QtQuick.Layouts

import qs.tokens
import qs.components.atoms

Item {
    id: root

    property bool hasBattery: false
    property string iconName: "battery_full"
    property real percentage: 0
    property bool charging: false

    implicitHeight: Spacing.listItem.height
    implicitWidth: parent ? parent.width : Spacing.panel.minWidth
    visible: hasBattery

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Spacing.listItem.paddingH
        anchors.rightMargin: Spacing.listItem.paddingH
        spacing: Spacing.listItem.gap

        ShellIcon {
            name: root.iconName
            iconSize: Spacing.listItem.iconSize
            iconColor: Colors.fgMuted
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                ShellText {
                    text: "Battery"
                    role: ShellText.Role.Body
                    textColor: Colors.fg
                }
                Item { Layout.fillWidth: true }
                ShellText {
                    text: Math.round(root.percentage) + "%"
                    role: ShellText.Role.Caption
                    textColor: Colors.fgMuted
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: height / 2
                color: Colors.sliderTrack

                Rectangle {
                    width: parent.width * (Math.max(0, Math.min(100, root.percentage)) / 100)
                    height: parent.height
                    radius: height / 2
                    color: {
                        if (root.percentage >= 50) return Colors.success // Green
                        if (root.percentage >= 15) return Colors.warning // Amber
                        return Colors.error // Red
                    }
                    
                    Behavior on width {
                        NumberAnimation { duration: Motion.duration.medium; easing.type: Motion.easing.standard }
                    }
                }
            }
            
            ShellText {
                visible: root.charging
                text: "Charging"
                role: ShellText.Role.Caption
                textColor: Colors.success
                font.pixelSize: 10
            }
        }
    }
}
