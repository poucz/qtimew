import QtQuick
import "qml/"

Window {
    id: mainWindow
    required property var timew

    width: 640
    height: 480
    visible: true
    title: qsTr("QTimeWarrior")


    BaseView{
        timew: mainWindow.timew
        anchors.fill:parent
    }
}
