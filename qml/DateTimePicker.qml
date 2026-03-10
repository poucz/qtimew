import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property date value: new Date()
    signal accepted(date dateTime)

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 4

        // Textové zobrazení
        TextField {
            id: display
            implicitWidth: 130
            implicitHeight: 30
            text: Qt.formatDateTime(root.value, "dd.MM.yyyy HH:mm")
            font.pixelSize: 13
            color: palette.windowText

            background: Rectangle {
                color: palette.alternateBase
                border.color: display.activeFocus ? "#3498db" : palette.light
                border.width: display.activeFocus ? 2 : 1
                radius: 6
            }

            // Ruční zadání
            onAccepted: {
                var d = new Date(text.replace(
                    /(\d+)\.(\d+)\.(\d+) (\d+):(\d+)/,
                    "$3-$2-$1T$4:$5"
                ))
                if (!isNaN(d)) {
                    root.value = d
                    root.accepted(d)
                } else {
                    text = Qt.formatDateTime(root.value, "dd.MM.yyyy HH:mm")
                }
            }

            Keys.onEscapePressed: root.forceActiveFocus()
        }

        // Tlačítko pro popup
        Button {
            text: "📅"
            implicitWidth: 30
            implicitHeight: 30
            background: Rectangle {
                color: palette.alternateBase
                border.color: palette.light
                radius: 6
            }
            onClicked: picker.open()
        }
    }

    // Popup picker
    Popup {
        id: picker
        parent: Overlay.overlay
        modal: true
        padding: 12

        function reposition() {
            var pos = display.mapToItem(null, 0, display.height + 4)
            x = pos.x
            y = pos.y
        }
        onOpened: reposition()

        background: Rectangle {
            color: palette.window
            border.color: palette.light
            radius: 8
        }

        contentItem: ColumnLayout {
            spacing: 10

            // --- DATUM ---
            RowLayout {
                spacing: 6

                // Den
                SpinBox {
                    id: dayBox
                    from: 1; to: 31
                    value: root.value.getDate()
                    implicitWidth: 70
                }
                MyText { text: "." }

                // Měsíc
                SpinBox {
                    id: monthBox
                    from: 1; to: 12
                    value: root.value.getMonth() + 1
                    implicitWidth: 70
                }
                MyText { text: "." }

                // Rok
                SpinBox {
                    id: yearBox
                    from: 2000; to: 2100
                    value: root.value.getFullYear()
                    implicitWidth: 90
                    editable: true
                }
            }

            // --- ČAS ---
            RowLayout {
                spacing: 6

                SpinBox {
                    id: hourBox
                    from: 0; to: 23
                    value: root.value.getHours()
                    implicitWidth: 70
                    textFromValue: function(v) { return v < 10 ? "0"+v : v }
                }
                MyText { text: ":" }
                SpinBox {
                    id: minuteBox
                    from: 0; to: 59
                    value: root.value.getMinutes()
                    implicitWidth: 70
                    textFromValue: function(v) { return v < 10 ? "0"+v : v }
                }
            }

            // --- Tlačítka ---
            RowLayout {
                Button {
                    text: "OK"
                    Layout.fillWidth: true
                    onClicked: {
                        var d = new Date(
                            yearBox.value,
                            monthBox.value - 1,
                            dayBox.value,
                            hourBox.value,
                            minuteBox.value
                        )
                        root.value = d
                        root.accepted(d)
                        display.text = Qt.formatDateTime(d, "dd.MM.yyyy HH:mm")
                        picker.close()
                    }
                }
                Button {
                    text: "Zrušit"
                    Layout.fillWidth: true
                    onClicked: picker.close()
                }
            }
        }
    }
}
