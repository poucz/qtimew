import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts


Item {
    id:root
    property var dateTime
    property bool showIcon: true


    property alias showTime: dtPicker.showTime
    property alias showdate: dtPicker.showDate

    property string dateTimeFormat:  "dd.MM.yyyy  HH:mm"



    //implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight  // ← tohle chybí



    RowLayout{
        id:row
        width:parent.width
        MyTextField{
            Layout.fillWidth: true
            text: Qt.formatDateTime(root.dateTime, root.dateTimeFormat)
            onClicked: picker.open()
        }
        TextClickable{

            //height: parent.height
            visible: root.showIcon
            text:"🗓"//"📅"
            font.pixelSize:25
            onClicked:{
                picker.open()
            }
        }
     }


    Popup {
        id: picker

        onAboutToShow: {
            var overlay = Overlay.overlay
            var rootX = root.mapToItem(overlay, 0, 0).x
            var rootY = root.mapToItem(overlay, 0, 0).y

            x = (rootX + width > overlay.width) ? overlay.width - width - rootX : 0
            y = (rootY + root.height + height > overlay.height) ? -height : root.height
        }


        width:  380
        height: 320

        padding: 0
        modal: true          // true = zbytek UI zašedne a klik mimo zavře
        focus: true           // zachytí Escape
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        // ── Obsah ─────────────────────────────────────────────────────────
        DateTimePicker {
            id: dtPicker
            anchors.fill: parent
            Component.onCompleted: selectedDate = root.dateTime
            onAccepted: {
                root.dateTime=selectedDate
                picker.close()
            }
        }
    }
}
