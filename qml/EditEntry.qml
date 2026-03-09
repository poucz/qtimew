import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    property var onAcceptedCallback: null

    property var itemId
    property var start
    property var end
    property alias annotation : annotationField.text
    property var tags

    width: 500
    height: 400
    standardButtons: Dialog.Ok | Dialog.Cancel

    // Pomocná funkce pro uložení změn zpět do objektu
    function updateEntry(isStart, dateStr, timeStr) {
        let fullString = dateStr + "T" + timeStr;
        let d = new Date(fullString);
        if (!isNaN(d.getTime())) {
            if (isStart) root.start = d;
            else root.end = d;
        }
    }

    function addTag(newTagStr) {
        let newTagName = newTagStr.trim();
        if (newTagName !== "" && !root.tags.includes(newTagName)) {
            // Vytvoříme úplně nové pole [původní tagy + nový]
            root.tags = [...root.tags, newTagName];
        }
    }

    function removeTag(index) {
        let copy = [...root.tags]; // Vytvoří mělkou kopii pole
        copy.splice(index, 1);      // Odstraní prvek na daném indexu
        root.tags = copy;           // Přiřadí nové pole zpět
    }

    Pane {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

            Text{
                text: "id:"+root.itemId
                color: "red"
            }

            // Mřížka pro Start a Stop
            GridLayout {
                columns: 2
                columnSpacing: 30
                rowSpacing: 10
                Layout.alignment: Qt.AlignTop

                // --- 1. ŘÁDEK: NADPISY ---
                Label {
                    text: "START"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#555"
                }
                Label {
                    text: "STOP"
                    font.bold: true
                    font.pixelSize: 14
                    color: "#555"
                }

                // --- 2. ŘÁDEK: DATUM ---
                TextField {
                    id: startDate
                    placeholderText: "yyyy-MM-dd"
                    text: Qt.formatDateTime(root.start, "yyyy-MM-dd")
                    Layout.fillWidth: true
                    onEditingFinished: root.updateEntry(true, text, startTime.text)
                }
                TextField {
                    id: endDate
                    placeholderText: "yyyy-MM-dd"
                    text: Qt.formatDateTime(root.end, "yyyy-MM-dd")
                    Layout.fillWidth: true
                    onEditingFinished: root.updateEntry(false, text, endTime.text)
                }

                // --- 3. ŘÁDEK: ČAS ---
                TextField {
                    id: startTime
                    placeholderText: "HH:mm:ss"
                    text: Qt.formatDateTime(root.start, "HH:mm:ss")
                    Layout.fillWidth: true
                    onEditingFinished: root.updateEntry(true, startDate.text, text)
                }
                TextField {
                    id: endTime
                    placeholderText: "HH:mm:ss"
                    text: Qt.formatDateTime(root.end, "HH:mm:ss")
                    Layout.fillWidth: true
                    onEditingFinished: root.updateEntry(false, endDate.text, text)
                }
            }

            Label { text: "Tagy"; font.pixelSize: 12; color: "#888" }

            TagsViewer{
                model: root.tags
                Layout.fillWidth: true
                spacing: 8
                onTagRemoved: (index) => root.removeTag(index)
                onTagAdded: (newTag) => root.addTag(newTag)
            }

            // --- SEKCIE ANOTACE ---
            TextArea {
                id: annotationField
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Zadejte poznámku..."
                //text: root.annotation
                color:"blue"
                wrapMode: TextArea.Wrap
                background: Rectangle {
                    border.color: parent.activeFocus ? "#3498db" : "#ccc"
                    radius: 4
                }
            }
        }
    }



    onAccepted: {
        var callback = root.onAcceptedCallback;
        if (typeof callback === "function") {
            //callback(time);
            Qt.callLater(onAcceptedCallback);
        }
        console.log("Uloženo! ID:", root.itemId)
    }

    onRejected: {
        console.log("Změny zrušeny.")
    }
}
