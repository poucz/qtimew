import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    required property var timew

    width: 200
    height: 300



    Component {
        id: nameDelegate
        Item {
            id: elemental
            width: parent.width
            height: 40

            required property int index
            required property string id
            required property var start
            required property var end
            required property var tags

            Row {
                anchors.centerIn: parent
                spacing: 10
                Text { text: elemental.id}
                Text { text: elemental.start.toString()}
                Text { text: elemental.end.toString()}
                Text { text: elemental.tags.join(", ")}
            }
        }
    }

    // 3. ZOBRAZENÍ
    ListView {
        anchors.fill: parent
        model: root.timew
        delegate: nameDelegate
        highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
        focus: true
    }
}
