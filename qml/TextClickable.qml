import QtQuick 2.15


Text {
    id: root
    signal doubleClick()

    MouseArea {
        id: startMouse
        anchors.fill: parent
        hoverEnabled: true
        onDoubleClicked: {
            root.doubleClick()
        }
    }
}
