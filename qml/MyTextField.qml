import QtQuick 2.15
import QtQuick.Controls 2.15

TextField {
    id:root
    signal clicked()

    MouseArea {
           anchors.fill: parent
           onClicked: root.clicked()
    }
}
