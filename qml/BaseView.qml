pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "Functions.js" as Functions

Item {
    id: root
    required property var timew

    width: 500 // Zvětšil jsem šířku, aby se tabulka vešla
    height: 300


    EditTimeDate {
        id: editTimeDateDialog
    }

    EditEntry{
        id:editEntry
    }

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

            required property var model

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true // Důležité pro detekci najetí bez kliknutí
                ToolTip {
                    visible: hoverArea.containsMouse && elemental.model.annotation !== ""
                    delay: 500 // Zobrazí se po půl sekundě (aby neblikal při rychlém přejetí)

                    contentItem: Text {
                        text: elemental.model.annotation
                        color: "white"
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap // Dlouhé poznámky se zalomí
                    }
                    background: Rectangle {
                        color: "#333"
                        radius: 4
                    }
                }
            }//mousearea

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                Text {
                    text: elemental.model.id
                    Layout.preferredWidth: 40
                    font.bold: true
                    color: "#666"
                }

                TextClickable {
                    // Zobrazení pouze času (HH:mm:ss)
                    text: Qt.formatDateTime(elemental.model.start, "hh:mm:ss")
                    Layout.preferredWidth: 70
                    onDoubleClick:{
                        editTimeDateDialog.onAcceptedCallback = function(newTime) {
                            elemental.model.start = newTime
                        }
                        editTimeDateDialog.itemID=elemental.model.id
                        editTimeDateDialog.time=Qt.formatDateTime(elemental.model.start, "hh:mm:ss")
                        editTimeDateDialog.open()
                    }
                }

                TextClickable {
                    text: Qt.formatDateTime(elemental.model.end, "hh:mm:ss")
                    Layout.preferredWidth: 70
                    onDoubleClick:{
                        editEntry.itemId    =elemental.model.id
                        editEntry.start     =elemental.model.start
                        editEntry.end       =elemental.model.end
                        editEntry.annotation=elemental.model.annotation
                        editEntry.tags      =elemental.model.tags
                        editEntry.onAcceptedCallback = function() {
                            console.log("Budu menit id:"+editEntry.itemID)
                            elemental.model.start       = editEntry.start
                            elemental.model.end         = editEntry.end
                            elemental.model.tags        = editEntry.tags
                            elemental.model.annotation  = editEntry.annotation
                            //modifyEntry
                        }
                        editEntry.open()


                        /*editTimeDateDialog.onAcceptedCallback = function(newTime) {
                            elemental.model.end = newTime
                        }
                        editTimeDateDialog.itemID=elemental.model.id
                        editTimeDateDialog.time=Qt.formatDateTime(elemental.model.end, "hh:mm:ss")
                        editTimeDateDialog.open()*/
                    }
                }

                Text {
                    //text: f.formatDuration(elemental.duration)
                    text: Functions.formatDuration(elemental.model.duration)
                    Layout.preferredWidth: 50
                }

                TextClickable {
                    text: elemental.model.tags.join(", ")
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    color: "#0078d7" // Modrá pro tagy
                    onDoubleClick:{
                        console.log(" Double click")
                    }
                }

                Text {
                    text: "ⓘ"
                    visible: elemental.model.annotation !== ""
                    color: "#999"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 10
                }//TEXT
                Button {
                    text: "X"
                    palette.buttonText: "red"
                    //font.pixelSize: 12
                    background:Rectangle{color:"white"}
                    Layout.alignment: Qt.AlignRight
                    Layout.preferredWidth: 10
                    onClicked:{
                        console.log("Mažu id: "+elemental.model.id)
                        root.timew.removeItem(elemental.model.id)
                    }
                }//TEXT
            }//RowLayout
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
                Text { text: "Trvání"; font.bold: true; Layout.preferredWidth: 50 }
                Text { text: "Tagy"; font.bold: true; Layout.fillWidth: true }
                Text { text: "-"; font.bold: true; Layout.preferredWidth: 30 }
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
