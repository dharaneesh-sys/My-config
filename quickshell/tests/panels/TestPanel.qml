import QtQuick

// Test fixture for M1-pillpanel.qml.
// Content-driven height contract: the panel declares its natural
// height via implicitHeight (not height), which PillPanel reads to
// size the expanded surface.
Item {
    width: parent ? parent.width : 340
    implicitHeight: 360
}
