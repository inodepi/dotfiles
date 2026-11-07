import QtQuick
import QtQuick.Window

// Static wallpaper replacement for the Qylock video background.
// Keeps the same Loader API as the original theme so Main.qml is untouched.
Item {
    id: root
    readonly property real s: Screen.height / 768
    anchors.fill: parent

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
    }
}
