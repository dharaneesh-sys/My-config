import QtQuick
import Quickshell
import qs.settings
import qs.motion

// Wave 0 M0 acceptance test (plan §E): MotionConfig.duration() scaling and
// spring tracking, run headless through the real quickshell engine.
// Exit code 0 = pass. Run via: quickshell -p <harness-dir>
ShellRoot {
    id: root

    Component.onCompleted: {
        // defer exit until the event loop + engine quit wiring are live;
        // direct Qt.exit in onCompleted does NOT propagate the exit code
        exitTimer.start()
    }

    Timer {
        id: exitTimer
        interval: 1

        onTriggered: {
            // snapshot the SettingsStore values we are about to mutate so the
            // live settings file is untouched (restored before exit)
            var snapSpeed = SettingsStore.animationSpeed
            var snapEnabled = SettingsStore.animationsEnabled
            var snapStiffness = SettingsStore.springStiffness
            var snapDamping = SettingsStore.springDamping

            var ok = true
            var checks = []

            function check(name, cond) {
                checks.push(name + "=" + cond)
                if (!cond) ok = false
            }

            // duration() scales by inverse of animationSpeed
            SettingsStore.animationSpeed = 2.0
            check("dur@2.0==150", MotionConfig.duration(300) === 150)

            SettingsStore.animationSpeed = 0.5
            check("dur@0.5==600", MotionConfig.duration(300) === 600)

            // disabled => 0 regardless of speed
            SettingsStore.animationsEnabled = false
            SettingsStore.animationSpeed = 1.0
            check("dur@disabled==0", MotionConfig.duration(300) === 0)

            // spring tracks SettingsStore live
            SettingsStore.animationsEnabled = true
            SettingsStore.springStiffness = 2.5
            SettingsStore.springDamping = 0.4
            check("spring.stiffness==2.5", MotionConfig.spring.stiffness === 2.5)
            check("spring.damping==0.4", MotionConfig.spring.damping === 0.4)

            // restore the user's real settings values
            SettingsStore.animationSpeed = snapSpeed
            SettingsStore.animationsEnabled = snapEnabled
            SettingsStore.springStiffness = snapStiffness
            SettingsStore.springDamping = snapDamping

            for (var i = 0; i < checks.length; i++)
                console.log("M0-CHECK " + checks[i])
            console.log("M0-RESULT ok=" + ok)
            Qt.exit(ok ? 0 : 1)
        }
    }
}
