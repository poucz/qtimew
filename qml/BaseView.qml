pragma ComponentBehavior: Bound
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "Functions.js" as Functions

Pane {
    id: root
    required property var timew

    width: 500 // Zvětšil jsem šířku, aby se tabulka vešla
    height: 300


    EditEntry{
        id:editEntry
    }

    Component {
        id: nameDelegate
        Rectangle { // Rectangle je lepší jako základ pro barvu pozadí
            id: elemental
            width: ListView.view.width
            height: mainLayout.implicitHeight + 10

            // Zebra efekt - střídání barev řádků
            color: index % 2 === 0 ? palette.window  : palette.midlight
            border.color: palette.light
            border.width: 0.5

            required property int index

            required property var model

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true // Důležité pro detekci najetí bez kliknutí
                ToolTip {
                    visible: hoverArea.containsMouse && elemental.model.annotation !== ""
                    delay: 100 // Zobrazí se po půl sekundě (aby neblikal při rychlém přejetí)

                    contentItem: Text {
                        text: elemental.model.annotation
                        color: palette.text
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap // Dlouhé poznámky se zalomí
                    }
                    background: Rectangle {
                        color: palette.window
                        border.color: palette.text
                        border.width: 1
                        radius: 4
                    }
                }
            }//mousearea

            RowLayout {
                id: mainLayout
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                MyText {
                    text: elemental.model.id
                    Layout.preferredWidth: 40
                    font.bold: true
                    color: palette.placeholderText
                }

                MyText {
                    // Zobrazení pouze času (HH:mm:ss)
                    text: Qt.formatDateTime(elemental.model.start, "hh:mm:ss")
                    Layout.preferredWidth: 70
                }

                MyText {
                    text: Qt.formatDateTime(elemental.model.end, "hh:mm:ss")
                    Layout.preferredWidth: 70
                }

                MyText {
                    //text: f.formatDuration(elemental.duration)
                    text: Functions.formatDuration(elemental.model.duration)
                    Layout.preferredWidth: 50
                }

                TagsViewer{
                    model: elemental.model.tags
                    Layout.fillWidth: true
                    onTagRemoved: (index,tag) => root.timew.delTag(elemental.model.id,tag)
                    onTagAdded: (newTag) => root.timew.addTag(elemental.model.id,newTag)
                }

                // NOVÝ KONTEJNER PRO TLAČÍTKA (Seskupení do jedné "buňky")
                Row {
                    spacing: 5 // Mezera mezi ikonkami uvnitř buňky
                    Layout.alignment: Qt.AlignRight
                    Layout.fillWidth: false

                    MyText {
                        text: "ⓘ"
                        visible: elemental.model.annotation !== ""
                        color: "#999"
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Button {
                        text: "✎"
                        width: 24 // Pevná šířka pro lepší klikatelnost
                        palette.buttonText: "#999"
                        background: Rectangle { color: "transparent" }
                        onClicked: {
                            editEntry.itemId = elemental.model.id
                            editEntry.start = elemental.model.start
                            editEntry.end = elemental.model.end
                            editEntry.annotation = elemental.model.annotation
                            editEntry.tags = elemental.model.tags
                            editEntry.onAcceptedCallback = function() {
                                root.timew.modifyEntry(editEntry.itemId, editEntry.start, editEntry.end, editEntry.tags, editEntry.annotation)
                            }
                            editEntry.open()
                        }
                    }
                    TextClickable {
                        text: "×"
                        font.pixelSize: 18
                        //color: "red"
                        color: containsMouse ? "red" : palette.placeholderText
                        onClicked:root.timew.removeItem(elemental.model.id)
                    }
                }//ROW

            }//RowLayout
        }
    }



    RowLayout{
        id: menu
        implicitWidth: parent.width

        Button {
            id:btn_start;
            enabled:!root.timew.running;
            text: "Start";
            font.bold: true;
            Layout.preferredWidth: 140
            onClicked:{
                root.timew.running=true
            }
        }

        Button {
            id:btn_stop;
            enabled:root.timew.running;
            text: "Stop";
            font.bold: true;
            Layout.preferredWidth:  140
            onClicked:{
                root.timew.running=false
            }
        }

        MyTextField{
            placeholderText:"filtr start time"
            background: Rectangle{
                color: palette.alternateBase
                border.color:palette.light
            }
        }

        MyTextField{
            placeholderText:"filtr end time"
            background: Rectangle{
                color: palette.alternateBase
                border.color:palette.light
            }
        }


        TagsViewer{
            Layout.fillWidth: true
            model: root.timew.tagsFiltr //root.timew.tags
            onTagAdded: (tag) =>{
                console.log("Add tag: "+tag)
                var arr = root.timew.tagsFiltr.slice()
                arr.push(tag)
                root.timew.tagsFiltr = arr
            }
            onTagRemoved: (i, tag) => {
                var arr = root.timew.tagsFiltr.slice()
                arr.splice(i, 1)
                root.timew.tagsFiltr = arr
            }

        }
    }



    // 3. ZOBRAZENÍ
    ListView {
        id: mainList
        anchors.top: menu.bottom
        anchors.topMargin:10
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
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
            color: palette.midlight

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 15

                MyText { text: "ID"; font.bold: true; Layout.preferredWidth: 40 }
                MyText { text: "Start"; font.bold: true; Layout.preferredWidth: 70 }
                MyText { text: "Konec"; font.bold: true; Layout.preferredWidth: 70 }
                MyText { text: "Trvání"; font.bold: true; Layout.preferredWidth: 50 }
                MyText { text: "Tagy"; font.bold: true; Layout.fillWidth: true }
                MyText { text: "-"; font.bold: true; Layout.preferredWidth: 30 }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: palette.light
            }
        }
    }
}
