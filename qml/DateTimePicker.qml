import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property date value: new Date()
    signal accepted(date dateTime)
    signal cleared()

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    function daysInMonth(month, year) {
        return new Date(year, month, 0).getDate()
    }

    // Interní pracovní hodnoty
    property int _day:    value.getDate()
    property int _month:  value.getMonth() + 1
    property int _year:   value.getFullYear()
    property int _hour:   value.getHours()
    property int _minute: value.getMinutes()

    property var monthNames: ["Jan","Feb","Mar","Apr","May","Jun",
                               "Jul","Aug","Sep","Oct","Nov","Dec"]
    property var dayNames:   ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    function previewText() {
        var d = new Date(_year, _month - 1, _day, _hour, _minute)
        return dayNames[d.getDay()] + ", " + monthNames[_month-1] + " " + _day + ", " + _year
             + "  " + (_hour < 10 ? "0"+_hour : _hour) + ":" + (_minute < 10 ? "0"+_minute : _minute)
    }


    Component.onCompleted:picker.open()

    Row {
        id: row
        spacing: 4

        // Textové zobrazení
        TextField {
            id: display
            implicitWidth: 145
            implicitHeight: 32
            text: Qt.formatDateTime(root.value, "dd.MM.yyyy HH:mm")
            font.pixelSize: 13
            color: display.valid ? palette.windowText : "#e03e3e"
            property bool valid: true

            background: Rectangle {
                color: palette.alternateBase
                border.color: display.activeFocus
                    ? (display.valid ? "#3498db" : "#e03e3e")
                    : (display.valid ? palette.light : "#e03e3e")
                border.width: display.activeFocus ? 2 : 1
                radius: 6
                Behavior on border.color { ColorAnimation { duration: 150 } }
            }

            onAccepted: {
                var d = new Date(text.replace(
                    /(\d+)\.(\d+)\.(\d+) (\d+):(\d+)/,
                    "$3-$2-$1T$4:$5"
                ))
                if (!isNaN(d.getTime())) {
                    display.valid = true
                    root.value = d
                    root.accepted(d)
                } else {
                    display.valid = false
                }
            }

            Keys.onEscapePressed: {
                display.valid = true
                text = Qt.formatDateTime(root.value, "dd.MM.yyyy HH:mm")
                root.forceActiveFocus()
            }
            onActiveFocusChanged: if (!activeFocus) display.valid = true
        }

        Button {
            text: "📅"
            implicitWidth: 32
            implicitHeight: 32
            background: Rectangle {
                color: parent.pressed ? palette.mid : palette.alternateBase
                border.color: palette.light
                radius: 6
                Behavior on color { ColorAnimation { duration: 100 } }
            }
            onClicked: {
                root._day    = root.value.getDate()
                root._month  = root.value.getMonth() + 1
                root._year   = root.value.getFullYear()
                root._hour   = root.value.getHours()
                root._minute = root.value.getMinutes()
                picker.open()
            }
        }
    }

    // ── POPUP ──────────────────────────────────────────────
    Popup {
        id: picker
        parent: Overlay.overlay
        modal: true
        padding: 0
        width: 340

        background:Rectangle{
            color: palette.light
            border.color:palette.placeholderText
            radius:20
        }

        function reposition() {
            var pos = display.mapToItem(null, 0, display.height + 6)
            x = pos.x
            y = pos.y
        }
        onOpened: reposition()


        contentItem: Column {
            spacing: 0

            // ── Hlavička ──
            Item {
                width: parent.width
                height: 36
                //color: palette.window
                //radius: 8

                // Titulek
                Text {
                    anchors.centerIn: parent
                    text: "Set Date & Time"
                    font.pixelSize: 13
                    font.bold: false
                    color: palette.windowText
                }

                // Zavřít
                TextClickable {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: "×"
                    font.pixelSize: 18
                    color: "#e03e3e"

                    onClicked: picker.close()
                }
            }

            // Náhled datumu
            Item {
                width: parent.width
                height: 36

                Text {
                    anchors.centerIn: parent
                    text: root.previewText()
                    font.pixelSize: 14
                    font.bold: true
                    color: "#e03e3e"
                }
            }

            // Oddělovač
            Rectangle { width: parent.width; height: 1; color: palette.placeholderText }

            // ── Sloupce s +/hodnota/- ──
            Item {
                width: parent.width
                height: 110

                Row {
                    anchors.centerIn: parent
                    spacing: 0

                    // Komponenta jednoho sloupce
                    component SpinCol : Column {
                        id: col
                        required property string label
                        required property int colValue
                        required property int colMin
                        required property int colMax
                        signal colChanged(int v)

                        property bool isMonth: false

                        width: 60
                        spacing: 0

                        // +
                        Rectangle {
                            width: parent.width
                            height: 32
                            color: plus.containsMouse ? "green" : palette.light
                            Behavior on color { ColorAnimation { duration: 80 } }

                            TextClickable {
                                id: plus
                                anchors.fill:parent
                                text: "+"
                                font.pixelSize: 20
                                color: palette.text
                                onClicked: {
                                    var v = col.colValue + 1
                                    if (v > col.colMax) v = col.colMin
                                    col.colChanged(v)
                                }
                            }
                        }

                        // Hodnota
                        Rectangle {
                            width: parent.width
                            height: 36
                            color: palette.light

                            Text {
                                anchors.centerIn: parent
                                //text: col.isMonth
                                //    ? root.monthNames[col.colValue - 1]
                                //    : (col.colValue < 10 ? "0" + col.colValue : "" + col.colValue)
                                text: (col.colValue < 10 ? "0" + col.colValue : "" + col.colValue)
                                font.pixelSize: 16
                                font.bold: false
                                color: palette.highlightedText
                            }
                        }

                        // -
                        Rectangle {
                            width: parent.width
                            height: 32
                            color: minus.containsMouse ? "green" :palette.light
                            Behavior on color { ColorAnimation { duration: 80 } }

                            TextClickable {
                                id: minus
                                anchors.fill:parent
                                //anchors.centerIn: parent
                                text: "-"
                                font.pixelSize: 20
                                color: palette.text
                                onClicked: {
                                    var v = col.colValue - 1
                                    if (v < col.colMin) v = col.colMax
                                    col.colChanged(v)
                                }
                            }
                        }
                    }

                    // Den
                    SpinCol {
                        label: "Day"
                        colValue: root._day
                        colMin: 1
                        colMax: root.daysInMonth(root._month, root._year)
                        onColChanged: (v) => root._day = v
                    }

                    Rectangle { width: 1; height: 100; color: "#eee"; anchors.verticalCenter: parent.verticalCenter }

                    // Měsíc
                    SpinCol {
                        label: "Month"
                        colValue: root._month
                        colMin: 1
                        colMax: 12
                        isMonth: true
                        onColChanged: (v) => {
                            root._month = v
                            // Oprav den pokud přesahuje
                            var maxD = root.daysInMonth(v, root._year)
                            if (root._day > maxD) root._day = maxD
                        }
                    }

                    Rectangle { width: 1; height: 100; color: "#eee"; anchors.verticalCenter: parent.verticalCenter }

                    // Rok
                    SpinCol {
                        label: "Year"
                        colValue: root._year
                        colMin: 2000
                        colMax: 2100
                        onColChanged: (v) => root._year = v
                    }

                    Rectangle { width: 1; height: 100; color: "#eee"; anchors.verticalCenter: parent.verticalCenter }

                    // Hodiny
                    SpinCol {
                        label: "Hour"
                        colValue: root._hour
                        colMin: 0
                        colMax: 23
                        onColChanged: (v) => root._hour = v
                    }

                    Rectangle { width: 1; height: 100; color: "#eee"; anchors.verticalCenter: parent.verticalCenter }

                    // Minuty
                    SpinCol {
                        label: "Min"
                        colValue: root._minute
                        colMin: 0
                        colMax: 59
                        onColChanged: (v) => root._minute = v
                    }
                }
            }

            Rectangle { width: parent.width; height: 1; color: palette.placeholderText }

            // ── Tlačítka Set / Clear ──
            Row {
                width: parent.width
                height: 48
                spacing: 0

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: set_text.containsMouse ? "#c0392b" : "#e03e3e"
                    Behavior on color { ColorAnimation { duration: 100 } }
                    radius: 0

                    // Zaoblení jen vlevo dole
                    Rectangle { width: parent.width/2; height: 8; color: parent.color; anchors.bottom: parent.bottom; anchors.left: parent.left }
                    Rectangle { width: 8; height: parent.height/2; color: parent.color; anchors.bottom: parent.bottom; anchors.left: parent.left }

                    TextClickable {
                        id: set_text
                        anchors.centerIn: parent
                        text: "Set"
                        color: "white"
                        font.pixelSize: 15
                        font.bold: true
                        onClicked:{
                            var d = new Date(root._year, root._month - 1, root._day, root._hour, root._minute)
                            root.value = d
                            display.text = Qt.formatDateTime(d, "dd.MM.yyyy HH:mm")
                            display.valid = true
                            root.accepted(d)
                            picker.close()
                        }
                    }
                }

                Rectangle {
                    width: parent.width / 2
                    height: parent.height
                    color: clear_text.containsMouse ? "#c0392b" : "#e03e3e"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    // Zaoblení jen vpravo dole
                    Rectangle { width: parent.width/2; height: 8; color: parent.color; anchors.bottom: parent.bottom; anchors.right: parent.right }
                    Rectangle { width: 8; height: parent.height/2; color: parent.color; anchors.bottom: parent.bottom; anchors.right: parent.right }

                    TextClickable{
                        id: clear_text
                        anchors.centerIn: parent
                        text: "Clear"
                        color: "white"
                        font.pixelSize: 15
                        font.bold: true
                        onClicked:{
                            root.cleared()
                            picker.close()
                        }
                    }
                }
            }
        }
    }
}
