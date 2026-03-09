import QtQuick 2.15
import QtQuick.Controls 2.15
pragma ComponentBehavior: Bound

Flow {
    id: root

    //! Definuj šířku pokud chceš
    //width:400

    property var model: []

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

        // Styl vstupu
        background: Rectangle {
            color: root.item_background
            border.color: input.activeFocus ? "#3498db" : "#d0d0d0"
            border.width: input.activeFocus ? 2 : 1
            radius: 15
        }

        onAccepted: {
            if (text.trim() !== "") {
                root.tagAdded(text.trim())
                text = "" // Vyčistit po přidání
            }
        }
    }
}
