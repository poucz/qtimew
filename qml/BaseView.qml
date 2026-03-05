pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    required property var timew

    width: 500 // Zvětšil jsem šířku, aby se tabulka vešla
    height: 300

    Component {
        id: nameDelegate
        Rectangle { // Rectangle je lepší jako základ pro barvu pozadí
            id: elemental
            width: ListView.view.width
            height: 40

            // Zebra efekt - střídání barev řádků
            color: index % 2 === 0 ? "white" : "#f9f9f9"
            border.color: "#eeeeee"
            border.width: 0.5

            required property int index
            required property string id
            required property var start
            required property var end
            required property var tags

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                Text {
                    text: elemental.id
                    Layout.preferredWidth: 40
                    font.bold: true
                    color: "#666"
                }

                Text {
                    // Zobrazení pouze času (HH:mm:ss)
                    text: Qt.formatDateTime(elemental.start, "hh:mm:ss")
                    Layout.preferredWidth: 70
                }

                Text {
                    text: Qt.formatDateTime(elemental.end, "hh:mm:ss")
                    Layout.preferredWidth: 70
                }

                Text {
                    text: Array.isArray(elemental.tags) ? elemental.tags.join(", ") : ""
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: "#0078d7" // Modrá pro tagy
                }
            }
        }
    }

    // 3. ZOBRAZENÍ
    ListView {
        id: mainList
        anchors.fill: parent
        model: root.timew
        delegate: nameDelegate
        highlight: Rectangle { color: "lightsteelblue"; opacity: 0.3 }
        focus: true
        clip: true

        // Přidání hlavičky tabulky, která zůstává nahoře
        headerPositioning: ListView.OverlayHeader
        header: Rectangle {
            z: 2
            width: mainList.width
            height: 35
            color: "#eeeeee"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                Text { text: "ID"; font.bold: true; Layout.preferredWidth: 40 }
                Text { text: "Start"; font.bold: true; Layout.preferredWidth: 70 }
                Text { text: "Konec"; font.bold: true; Layout.preferredWidth: 70 }
                Text { text: "Tagy"; font.bold: true; Layout.fillWidth: true }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#ccc"
            }
        }
    }
}
