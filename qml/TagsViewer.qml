import QtQuick 2.15
import QtQuick.Controls 2.15
pragma ComponentBehavior: Bound

Flow {
    id: root

    //! Definuj šířku pokud chceš
    //width:400

    property var model: []
    property var suggest: []


    property var filteredSuggest: [] //interni promenna


    // Signály pro komunikaci s nadřazeným prvkem
    signal tagAdded(string newTag)
    signal tagRemoved(int index, string tag)

    property color item_background: palette.alternateBase//"#f0f0f0"
    property color text_color: palette.text//"#333"

    spacing: 8
    //rowSpacing: 8




    Repeater {
        model: root.model

        delegate: Rectangle {
            id: tagRect
            required property var modelData
            required property var index
            implicitWidth: tagContent.width + 20
            implicitHeight: 30
            color: root.item_background
            border.color: palette.light
            radius: 15

            Row {
                id: tagContent
                anchors.centerIn: parent
                spacing: 6
                leftPadding: 8
                rightPadding: 8
                height: parent.height

                MyText {
                    text: tagRect.modelData
                    font.pixelSize: 13
                    color: root.text_color
                    height: parent.height
                    verticalAlignment: Text.AlignVCenter
                }

                // Křížek pro smazání
                TextClickable {
                    text: "×"
                    font.pixelSize: 18
                    font.bold: true
                    height: parent.height
                    color: containsMouse ? "red" : palette.placeholderText
                    verticalAlignment: Text.AlignVCenter
                    onClicked: root.tagRemoved(tagRect.index, tagRect.modelData)
                }
            }
        }
    }


    // Vstup pro nový tag
    TextField {
        id: input
        placeholderText: "+ přidat..."
        font.pixelSize: 13
        implicitWidth: 100
        implicitHeight: 30
        color: palette.windowText

        background: Rectangle {
            color: root.item_background
            border.color: input.activeFocus ? "#3498db" : palette.light
            border.width: input.activeFocus ? 2 : 1
            radius: 15
        }

        onTextChanged: {
            const t = text.trim().toLowerCase()
            if (t === "") {
                root.filteredSuggest = root.suggest
                return
            }
            root.filteredSuggest = root.suggest.filter(s => s.toLowerCase().includes(t))
        }

        onAccepted: {
            if (text.trim() !== "") {
                root.tagAdded(text.trim())
                text = ""
                root.filteredSuggest = []
            }
        }

        // Přidej do TextField
        onActiveFocusChanged: {
            if (!activeFocus) root.filteredSuggest = []
        }
        Keys.onEscapePressed: root.forceActiveFocus()




        ListView {
            id: suggestList
            //visible: root.filteredSuggest.length > 0
            model: root.filteredSuggest
            //model: root.suggest
            width: input.width
            height: Math.min(contentHeight, 250)
            clip: true
            z: 100

            anchors.top: input.bottom
            anchors.left: input.left
            anchors.margins: 4
            spacing:5

            delegate: Rectangle {
                id: tag_str
                required property var modelData
                width: parent.width
                height: 28
                radius:30
                //color: containsMouse ? palette.highlight : root.item_background

                TextClickable {
                    text: tag_str.modelData
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    //color: containsMouse ? palette.highlightedText : palette.windowText
                    color: containsMouse ? "red":"green"
                    onClicked:{
                        root.tagAdded(tag_str.modelData)
                        input.text = ""
                        root.filteredSuggest = []
                    }
                }
            }

            ScrollBar.vertical: ScrollBar { }
        }
    }
}
