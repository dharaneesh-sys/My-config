import QtQuick
import QtQuick.Shapes

import qs.tokens
import qs.metrics
import qs.state
import qs.settings
import qs.motion
import qs.components.atoms

Item {
    id: pillPanel

    // ═══════════════════════════════════════════════════════════════
    //  PillPanel — the pill bar (collapsed state only)
    //
    //  Split architecture (Wave 2):
    //  • The pill is a PERMANENT, fixed-size bar with a strut. It never
    //    morphs or expands — its height is constant so tiling windows
    //    are pushed by exactly the pill height, never the panel height.
    //  • Expanded panels live in a SEPARATE window (PanelSurface) that
    //    floats above tiling windows below the pill.
    //  • Surface geometry has no expanded-state bindings. The notch⇄pill
    //    toggle morphs size (OutBack) with a brief squash; the only other
    //    motion is the press-scale.
    // ═══════════════════════════════════════════════════════════════

    // ── Public API ─────────────────────────────────────────────────
    /** Opaque/clickable region — Shell binds its mask to this. */
    readonly property alias surface: surface
    /** The active visual is used by the layer-shell input mask. */
    readonly property Item maskItem: noticeVisible ? noticeSurface : (ShellMetrics.notchEnabled ? notchSurface : surface)

    // ── Pill notification bridge ──────────────────────────────────
    // Volume, brightness, and desktop notifications share one small OSD.
    // Keeping the state here means the pill itself is the only animated
    // surface: no extra popup window and no compositor geometry churn.
    property bool noticeActive: false
    property bool noticeReady: false
    property string noticeIcon: "notifications"
    property string noticeTitle: ""
    property string noticeBody: ""
    property real noticeValue: -1
    readonly property bool noticeVisible: noticeActive && !ExpansionManager.isExpanded
    // The expanded form settles below the top edge instead of touching it.
    property real noticeDrop: noticeVisible ? 14 : 0
    readonly property bool panelOpening: ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Opening
    readonly property bool panelClosing: ExpansionManager.lifecycle === ExpansionManager.Lifecycle.Closing

    function showNotice(icon, title, body, value) {
        noticeIcon = icon
        noticeTitle = title
        noticeBody = body || ""
        noticeValue = value === undefined ? -1 : value
        noticeActive = true
        noticeDismiss.restart()
    }

    // ── Visibility ─────────────────────────────────────────────────
    // Hidden only when the clock is disabled. The pill is the only
    // always-visible chrome — it is not tied to expansion state anymore.
    visible: SettingsStore.clockShowInPill || noticeActive
    // Expanded panels take the pill's visual position. Keep the pill item
    // alive for the permanent layer-shell strut, but fade its chrome out.
    opacity: ExpansionManager.isExpanded ? 0.0 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: MotionConfig.duration(Motion.duration.fast)
            easing.type: Motion.easing.standard
        }
    }

    // ── Size — pill vs Apple notch ─────────────────────────────────
    // Notch: 200×32 flat-top, pill: 136×48 capsule. Every panel uses the
    // same bar, so toggling notchEnabled flips all panels except SettingsWindow.
    width:  ShellMetrics.notchEnabled ? ShellMetrics.notchWidth : ShellMetrics.pillWidth
    height: ShellMetrics.notchEnabled ? ShellMetrics.notchHeight : ShellMetrics.pillHeight

    // ── Notch⇄pill morph ───────────────────────────────────────────
    // Dynamic-Island style: size springs between the two geometries while a
    // short squash-and-release sells the shape change. morphing is transient —
    // it clears as soon as the size animation settles.
    property bool morphing: false
    scale: morphing ? 0.96 : 1.0

    Behavior on width {
        NumberAnimation {
            duration: MotionConfig.duration(220)
            easing.type: Easing.OutBack
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: MotionConfig.duration(220)
            easing.type: Easing.OutBack
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: MotionConfig.duration(150)
            easing.type: Motion.easing.standard
        }
    }

    Timer {
        id: morphReset
        // 0 when animations are disabled → squash releases instantly.
        interval: MotionConfig.duration(220)
        onTriggered: pillPanel.morphing = false
    }

    Connections {
        target: ShellMetrics
        function onNotchEnabledChanged() {
            pillPanel.morphing = true
            morphReset.restart()
        }
    }

    // ── The pill surface ───────────────────────────────────────────
    // ── Pill surface (capsule) — hidden in notch mode ───────────
    Rectangle {
        id: surface
        visible: !ShellMetrics.notchEnabled
        anchors.fill: parent

        // Solid matte pill (no glass transparency) — accent border in game mode
        color: Colors.pillBg
        radius: ShellMetrics.pillCornerRadius
        border.width: 0
        border.color: "transparent"
        clip: true
        opacity: pillPanel.noticeVisible ? 0.0 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: MotionConfig.duration(Motion.duration.fast)
                easing.type: Motion.easing.standard
            }
        }

        // The pill briefly compresses before it pours into PanelSurface.
        // This is a one-shot interaction response, not an idle animation.
        scale: pillToggle.pressed ? 0.96 : (pillPanel.panelOpening ? 0.92 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: MotionConfig.duration(Motion.duration.micro)
                easing.type: Motion.easing.standard
            }
        }

        // Game mode indicator — small accent dot when active (Hyprland-only)
        Rectangle {
            visible: GameModeState.active && !ShellMetrics.notchEnabled
            width: 8; height: 8; radius: 4
            color: Colors.accent
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1
            border.color: Colors.pillBg
        }

        // ── Clock — the ONLY pill content (reads ClockState) ──────
        Text {
            id: clockLabel
            visible: !ShellMetrics.notchEnabled
            anchors.centerIn: parent
            text: ClockState.showSeconds ? ClockState.timeSeconds : ClockState.time
            color: Colors.pillFg
            font.family:    Typography.clock.family
            font.pixelSize: Typography.clock.size
            font.weight: ShellMetrics.notchEnabled ? Font.DemiBold : Typography.clock.weight
            font.letterSpacing: ShellMetrics.notchEnabled ? 0.3 : 0
            font.capitalization: ShellMetrics.notchEnabled ? Font.SmallCaps : Font.MixedCase
        }

        // ── Toggle: opens the control center ───────────────────────
        // requestExpand handles the toggle-off case when the same
        // panel is already open.
        MouseArea {
            id: pillToggle
            anchors.fill: parent
            hoverEnabled: true
            enabled: !ExpansionManager.isExpanded
            cursorShape: Qt.PointingHandCursor
            onClicked: ExpansionManager.requestExpand("control-center")
        }
    }


    // ── Notch surface (Apple flat-top) — visible only in notch mode ───
    // True notch: flat top edge at y=0, only bottom corners rounded (12px).
    // Uses Shape/Path for per-corner radius — Rectangle radius would round all 4.
    Shape {
        id: notchSurface
        visible: ShellMetrics.notchEnabled
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        antialiasing: true

        ShapePath {
            fillColor: Colors.pillBg
            strokeColor: "transparent"
            strokeWidth: 0
            // Flat top, rounded bottom — Apple MacBook notch
            PathMove { x: 0; y: 0 }
            PathLine { x: ShellMetrics.notchWidth; y: 0 }
            PathLine { x: ShellMetrics.notchWidth; y: ShellMetrics.notchHeight - ShellMetrics.notchCornerRadius }
            PathArc {
                x: ShellMetrics.notchWidth - ShellMetrics.notchCornerRadius
                y: ShellMetrics.notchHeight
                radiusX: ShellMetrics.notchCornerRadius
                radiusY: ShellMetrics.notchCornerRadius
                direction: PathArc.Clockwise
            }
            PathLine { x: ShellMetrics.notchCornerRadius; y: ShellMetrics.notchHeight }
            PathArc {
                x: 0
                y: ShellMetrics.notchHeight - ShellMetrics.notchCornerRadius
                radiusX: ShellMetrics.notchCornerRadius
                radiusY: ShellMetrics.notchCornerRadius
            }
            PathLine { x: 0; y: 0 }
        }

        // Clock centered in notch (hardware style — tight tracking, semibold, small caps)
        Text {
            anchors.centerIn: parent
            text: ClockState.showSeconds ? ClockState.timeSeconds : ClockState.time
            color: Colors.pillFg
            font.family: Typography.clock.family
            font.pixelSize: Typography.clock.size
            font.weight: Font.DemiBold
            font.letterSpacing: 0.3
            font.capitalization: Font.SmallCaps
            visible: !pillPanel.noticeVisible
        }

        // Game mode badge for notch — subtle accent when active
        ShellIcon {
            visible: GameModeState.active && ShellMetrics.notchEnabled
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            name: "sports_esports"
            iconSize: 16
            iconColor: Colors.accent
            filled: true
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            enabled: !ExpansionManager.isExpanded
            cursorShape: Qt.PointingHandCursor
            onClicked: ExpansionManager.requestExpand("control-center")
        }
    }

    // A thin accent ring gives the open gesture its water-drop ripple without
    // a shader, blur, or continuously running animation.
    Rectangle {
        id: openingRipple
        anchors.centerIn: surface
        width: pillPanel.panelOpening ? surface.width * 1.48 : surface.width
        height: pillPanel.panelOpening ? surface.height * 2.05 : surface.height
        radius: height / 2
        color: "transparent"
        border.width: 1
        border.color: Colors.accent
        opacity: GameModeState.active ? 0 : (pillPanel.panelOpening ? 0.32 : 0.0)
        visible: opacity > 0

        Behavior on width { NumberAnimation { duration: MotionConfig.duration(150); easing.type: Easing.OutCubic } }
        Behavior on height { NumberAnimation { duration: MotionConfig.duration(150); easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: MotionConfig.duration(130); easing.type: Easing.OutCubic } }
    }

    // This starts at the pill's exact centre and expands sideways.  It is
    // deliberately a single NumberAnimation (rather than a spring) so rapid
    // media-key repeats cannot accumulate jitter.
    Rectangle {
        id: noticeSurface
        z: 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: pillPanel.noticeDrop
        width: pillPanel.noticeVisible ? Math.max(300, ShellMetrics.pillWidth) : ShellMetrics.pillWidth
        height: pillPanel.noticeVisible ? Math.max(56, ShellMetrics.pillHeight) : ShellMetrics.pillHeight
        radius: height / 2
        color: Colors.pillBg
        border.width: Elevation.pill.borderWidth
        border.color: Colors.pillBorder
        opacity: pillPanel.noticeVisible ? 1.0 : 0.0
        visible: opacity > 0
        clip: true

        Behavior on width {
            NumberAnimation { duration: MotionConfig.duration(Motion.duration.medium); easing.type: Motion.easing.decelerate }
        }
        Behavior on height {
            NumberAnimation { duration: MotionConfig.duration(Motion.duration.fast); easing.type: Motion.easing.standard }
        }
        Behavior on opacity {
            NumberAnimation { duration: MotionConfig.duration(Motion.duration.fast); easing.type: Motion.easing.standard }
        }
        Behavior on anchors.verticalCenterOffset {
            NumberAnimation { duration: MotionConfig.duration(Motion.duration.medium); easing.type: Motion.easing.decelerate }
        }

        Row {
            id: noticeRow
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 16
            spacing: 10

            ShellIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: pillPanel.noticeIcon
                iconSize: 22
                iconColor: Colors.accent
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - noticeRow.spacing - 22 - (pillPanel.noticeValue >= 0 ? 66 : 0)
                spacing: 1

                Text {
                    width: parent.width
                    text: pillPanel.noticeTitle
                    color: Colors.pillFg
                    font.family: Typography.body.family
                    font.pixelSize: Typography.body.size
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    visible: pillPanel.noticeBody.length > 0
                    text: pillPanel.noticeBody
                    color: Colors.fgMuted
                    font.family: Typography.caption.family
                    font.pixelSize: Typography.caption.size
                    elide: Text.ElideRight
                }
            }

            Column {
                visible: pillPanel.noticeValue >= 0
                width: 56
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    width: parent.width
                    text: Math.round(pillPanel.noticeValue * 100) + "%"
                    horizontalAlignment: Text.AlignRight
                    color: Colors.pillFg
                    font.family: Typography.caption.family
                    font.pixelSize: Typography.caption.size
                }
                Rectangle {
                    width: parent.width
                    height: 3
                    radius: height / 2
                    color: Colors.sliderTrack
                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, pillPanel.noticeValue))
                        height: parent.height
                        radius: parent.radius
                        color: Colors.sliderFill
                    }
                }
            }
        }
    }

    Timer {
        id: noticeDismiss
        interval: Motion.notification.autoDismiss
        repeat: false
        onTriggered: pillPanel.noticeActive = false
    }

    Connections {
        target: AudioState
        function onVolumeChanged() {
            if (!pillPanel.noticeReady) return
            pillPanel.showNotice(AudioState.muted ? "volume_off" : "volume_up",
                                 AudioState.muted ? "Sound muted" : "Volume",
                                 "", AudioState.muted ? 0 : AudioState.volume)
        }
        function onMutedChanged() {
            if (!pillPanel.noticeReady) return
            pillPanel.showNotice(AudioState.muted ? "volume_off" : "volume_up",
                                 AudioState.muted ? "Sound muted" : "Volume",
                                 "", AudioState.muted ? 0 : AudioState.volume)
        }
    }

    Connections {
        target: BrightnessState
        function onBrightnessChanged() {
            if (!pillPanel.noticeReady) return
            pillPanel.showNotice("brightness_high", "Brightness", "", BrightnessState.brightness)
        }
    }

    Connections {
        target: NotificationState
        function onNotificationsChanged() {
            if (!pillPanel.noticeReady || !NotificationState._syncComplete) return
            if (NotificationState.notifications.length === 0) return
            var notification = NotificationState.notifications[0]
            pillPanel.showNotice("notifications", notification.title || notification.appName || "Notification",
                                 notification.body || notification.appName || "", -1)
        }
    }

    Component.onCompleted: Qt.callLater(function() { pillPanel.noticeReady = true })
}
