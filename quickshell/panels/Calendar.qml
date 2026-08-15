import QtQuick

import qs.tokens
import qs.metrics
import qs.components.molecules
import qs.viewmodels
import qs.components.atoms

Item {
    id: calendar

    // ═══════════════════════════════════════════════════════════════
    //  Calendar — PURE VIEW
    //
    //  Date/time display panel.
    //  Only binds properties and emits user actions through ViewModel.
    // ═══════════════════════════════════════════════════════════════

    CalendarViewModel { id: vm }

    width: parent ? parent.width : ShellMetrics.calendarWidth
    implicitHeight: contentColumn.height

    Column {
        id: contentColumn
        width: parent.width
        spacing: Spacing.panel.gap

        PanelHeader {
            width: parent.width
            title: "Calendar"
            iconName: "calendar_today"
        }

        // Date display
        ShellText {
            width: parent.width
            text: vm.dateLong
            role: ShellText.Role.Title
            textColor: Colors.fg
            horizontalAlignment: Text.AlignHCenter
        }

        // Day of week
        ShellText {
            width: parent.width
            text: vm.dayOfWeek
            role: ShellText.Role.Subheading
            textColor: Colors.accent
            horizontalAlignment: Text.AlignHCenter
        }

        // Time
        ShellText {
            width: parent.width
            text: vm.time
            role: ShellText.Role.Heading
            textColor: Colors.fg
            horizontalAlignment: Text.AlignHCenter
        }

        // Settings toggles
        ToggleRow {
            width: parent.width
            iconName: "schedule"
            title: "24-hour format"
            checked: vm.use24h
            onToggled: vm.toggle24h()
        }

        ToggleRow {
            width: parent.width
            iconName: "timer"
            title: "Show seconds"
            checked: vm.showSeconds
            onToggled: vm.toggleSeconds()
        }

        Item { width: parent.width; height: Spacing.xs }
    }
}
