import QtQuick
import QtQuick.Window

// Static wallpaper background (Qylock's video loader, no QtMultimedia needed).
Item {
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
