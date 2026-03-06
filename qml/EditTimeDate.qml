import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: dialog

    property var onAcceptedCallback: null

    // Tvoje definované vlastnosti
    property int itemID: 42
    property string time: "12:30:00"


    //property var currentEntry: null
    //property string targetRole


    title: "Detail položky #" + itemID
    modal: true
    anchors.centerIn: parent
    standardButtons: Dialog.Ok | Dialog.Cancel

    // Hlavní obsah dialogu
    ColumnLayout {
        spacing: 20
        width: parent.width

        RowLayout {
            spacing: 10
            Label {
                text: "ID položky:"
                font.bold: true
            }
            Label {
                text: dialog.itemID.toString()
            }
        }

        RowLayout {
            spacing: 10
            Label {
                text: "Čas:"
                font.bold: true
            }
            TextField {
                id: timeInput
                text: dialog.time
                placeholderText: "HH:MM:SS"
                inputMask: "99:99:99" // Pomůže udržet formát HH:MM:SS

                onTextChanged: {
                    // Volitelně: aktualizovat vlastnost za běhu
                    dialog.time = text
                }
            }
        }
    }

    // Logika tlačítek
    onAccepted: {
        var callback = dialog.onAcceptedCallback;
        if (typeof callback === "function") {
            //callback(time);
            Qt.callLater(onAcceptedCallback, time);
        }
        console.log("Uloženo! ID:", itemID, "Čas:", time)
    }

    onRejected: {
        console.log("Změny zrušeny.")
    }
}
