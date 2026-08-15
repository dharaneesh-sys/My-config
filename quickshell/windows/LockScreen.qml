import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

import qs.state
import qs.tokens

// A compositor-backed session lock.  Authentication starts only after the
// compositor confirms that every screen is covered, so input is never sent to
// a PAM conversation before the lock surface can receive the keyboard.
WlSessionLock {
    id: lockScreen

    property string pendingResponse: ""
    property string authError: ""
    property int attemptSerial: 0
    property bool authenticationStarted: false
    readonly property string userName: Quickshell.env("USER") || "User"

    function requestLock() {
        if (locked) return
        console.info("LockScreen: requesting session lock")
        authError = ""
        pendingResponse = ""
        attemptSerial = 0
        authenticationStarted = false
        locked = true
    }

    function beginAuthentication() {
        if (!locked || !secure || authenticationStarted || pam.active) return
        authenticationStarted = pam.start()
        console.info("LockScreen: PAM start=" + authenticationStarted)
        if (!authenticationStarted)
            authError = "Unable to start authentication"
    }

    function flushPendingResponse() {
        if (!pam.active || !pam.responseRequired || pendingResponse.length === 0) return
        var response = pendingResponse
        pendingResponse = ""
        pam.respond(response)
    }

    function submitPassword(password) {
        if (password.length === 0) return
        console.info("LockScreen: password submitted; prompt=" + pam.responseRequired)
        authError = ""
        pendingResponse = password
        beginAuthentication()
        flushPendingResponse()
    }

    onSecureChanged: {
        console.info("LockScreen: secure=" + secure)
        if (secure) beginAuthentication()
    }

    PamContext {
        id: pam
        // Keep the established local Hyprlock password policy.
        config: "hyprlock"
        user: lockScreen.userName

        // PAM can publish a prompt before or after `responseRequired` changes.
        // Handle both notifications so Enter always reaches the active prompt.
        onResponseRequiredChanged: lockScreen.flushPendingResponse()
        onPamMessage: {
            console.info("LockScreen: PAM prompt; responseRequired=" + responseRequired)
            lockScreen.flushPendingResponse()
        }

        onCompleted: function(result) {
            console.info("LockScreen: PAM completed=" + PamResult.toString(result))
            if (result === PamResult.Success) {
                lockScreen.authError = ""
                lockScreen.locked = false
                return
            }

            lockScreen.pendingResponse = ""
            lockScreen.authenticationStarted = false
            lockScreen.attemptSerial += 1
            lockScreen.authError = result === PamResult.MaxTries
                ? "Too many attempts. Please wait a moment."
                : "Incorrect password"
        }

        onError: function(error) {
            console.warn("LockScreen: PAM error=" + error)
            lockScreen.pendingResponse = ""
            lockScreen.authenticationStarted = false
            lockScreen.attemptSerial += 1
            lockScreen.authError = "Authentication is unavailable"
        }
    }

    WlSessionLockSurface {
        id: lockSurface
        color: Colors.bg

        Image {
            anchors.fill: parent
            source: WallpaperState.currentWallpaperUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            scale: 1.035
            transformOrigin: Item.Center
        }

        // The opaque surface preserves a secure lock; these layers provide the
        // familiar macOS dimmed-wallpaper depth without compositor translucency.
        Rectangle { anchors.fill: parent; color: "#8a07101b" }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#15000000" }
                GradientStop { position: 0.48; color: "#26000000" }
                GradientStop { position: 1.0; color: "#78000000" }
            }
        }

        FocusScope {
            id: lockFocus
            anchors.fill: parent
            focus: true

            // A session-lock surface owns the keyboard. This fallback makes
            // Return submit even if a compositor briefly shifts item focus
            // during the lock transition; TextInput still handles ordinary
            // typing and its own Return first.
            Keys.onReturnPressed: function(event) {
                lockScreen.submitPassword(passwordField.text)
                event.accepted = true
            }
            Keys.onEnterPressed: function(event) {
                lockScreen.submitPassword(passwordField.text)
                event.accepted = true
            }

            Column {
                id: lockContent
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: -Math.min(28, lockSurface.height * 0.03)
                }
                width: Math.min(348, parent.width - 44)
                spacing: 10

                Text {
                    width: parent.width
                    text: ClockState.dayOfWeek + ", " + ClockState.dateLong
                    color: "#e8edf3"
                    font.family: Typography.families.primary
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    width: parent.width
                    text: ClockState.time
                    color: "#f7f7f9"
                    font.family: Typography.families.primary
                    font.pixelSize: Math.min(86, Math.max(58, lockSurface.width * 0.062))
                    font.weight: Font.Light
                    horizontalAlignment: Text.AlignHCenter
                }

                Item { width: 1; height: 34 }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 58
                    height: width
                    radius: width / 2
                    color: "#9cffffff"
                    border.width: 1
                    border.color: "#70ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: "person"
                        color: "#eef2f6"
                        font.family: Typography.families.icons
                        font.pixelSize: 30
                    }
                }

                Text {
                    width: parent.width
                    text: lockScreen.userName
                    color: "#ffffff"
                    font.family: Typography.families.primary
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignHCenter
                }

                Item { width: 1; height: 6 }

                Rectangle {
                    id: passwordShell
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 258
                    height: 42
                    radius: height / 2
                    color: "#5c111721"
                    border.width: passwordField.activeFocus ? 2 : 1
                    border.color: passwordField.activeFocus ? "#d9ffffff" : "#55ffffff"

                    Behavior on border.color { ColorAnimation { duration: 130 } }

                    TextInput {
                        id: passwordField
                        anchors {
                            left: parent.left
                            leftMargin: 18
                            right: submitIcon.left
                            rightMargin: 12
                            verticalCenter: parent.verticalCenter
                        }
                        focus: true
                        echoMode: TextInput.Password
                        color: "white"
                        font.family: Typography.families.primary
                        font.pixelSize: 16
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: false
                        onAccepted: lockScreen.submitPassword(text)
                        onTextChanged: if (lockScreen.authError !== "") lockScreen.authError = ""
                        onActiveFocusChanged: if (!activeFocus && lockScreen.locked) forceActiveFocus()
                        onFocusChanged: if (focus) cursorPosition = text.length
                    }

                    Text {
                        anchors.left: passwordField.left
                        anchors.verticalCenter: parent.verticalCenter
                        visible: passwordField.text.length === 0
                        text: "Password"
                        color: "#b9ffffff"
                        font.family: Typography.families.primary
                        font.pixelSize: 15
                    }

                    Text {
                        id: submitIcon
                        anchors { right: parent.right; rightMargin: 15; verticalCenter: parent.verticalCenter }
                        text: "arrow_forward"
                        color: "#f3f5f8"
                        font.family: Typography.families.icons
                        font.pixelSize: 20
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: function(mouse) {
                            passwordField.forceActiveFocus()
                            if (mouse.x >= parent.width - 54)
                                lockScreen.submitPassword(passwordField.text)
                        }
                    }
                }

                Text {
                    width: parent.width
                    height: 19
                    text: lockScreen.authError !== "" ? lockScreen.authError
                        : (pam.active && !pam.responseRequired ? "Verifying…" : "Press Return to unlock")
                    color: lockScreen.authError !== "" ? "#ffd6d6" : "#d9e0e8"
                    font.family: Typography.families.primary
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Connections {
                target: lockScreen
                function onAttemptSerialChanged() {
                    passwordField.clear()
                    passwordField.forceActiveFocus()
                }
            }
        }

        Timer {
            interval: 1
            running: true
            repeat: false
            onTriggered: {
                lockFocus.forceActiveFocus()
                passwordField.forceActiveFocus()
                lockScreen.beginAuthentication()
            }
        }
    }
}
