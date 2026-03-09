import QtQuick 2.15


MyText {
    id: root

    property alias containsMouse: startMouse.containsMouse

    signal doubleClick()
    signal clicked()

    MouseArea {
        id: startMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onDoubleClicked: {
            root.doubleClick()
        }
        onClicked:{
            root.clicked()
        }
    }
}
