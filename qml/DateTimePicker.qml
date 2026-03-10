import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 380
    height: 320

    // --- Public API ---
    property var selectedDate: new Date(2014, 6, 9, 12, 0)  // July 9, 2014 12:00 PM

    // Internal state
    property int viewYear:  selectedDate.getFullYear()
    property int viewMonth: selectedDate.getMonth()   // 0-based

    readonly property var monthNames: [
        "January","February","March","April","May","June",
        "July","August","September","October","November","December"
    ]
    readonly property var dayNames: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

    // Time slots every 30 minutes
    property var timeSlots: {
        var slots = []
        for (var h = 0; h < 24; h++) {
            for (var m = 0; m < 60; m += 30) {
                var mm = m === 0 ? "00" : "30"
                slots.push({ hour: h, minute: m, label: h + ":" + mm })
            }
        }
        return slots
    }

    function selectedTimeIndex() {
        var sh = selectedDate.getHours()
        var sm = selectedDate.getMinutes() < 30 ? 0 : 30
        for (var i = 0; i < timeSlots.length; i++) {
            if (timeSlots[i].hour === sh && timeSlots[i].minute === sm) return i
        }
        return 0
    }

    function firstDayOfMonth() {
        return new Date(viewYear, viewMonth, 1).getDay()
    }
    function daysInMonth(y, m) {
        return new Date(y, m + 1, 0).getDate()
    }

    function formatHeader() {
        var d  = selectedDate
        var mo = d.getMonth() + 1
        var dy = d.getDate()
        var yr = d.getFullYear()
        var h  = d.getHours()
        var mi = d.getMinutes()
        var mm = mi < 10 ? "0" + mi : mi
        return dy + "/" + mo + "/" + yr + " " + h + ":" + mm
    }

    // ── Outer border ──────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: palette.window
        border.color: palette.mid
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Top text input bar ─────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 32
                color: palette.base
                border.color: palette.mid
                border.width: 1

                RowLayout {
                    anchors { fill: parent; margins: 1 }
                    spacing: 0

                    TextField {
                        id: headerField
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.formatHeader()
                        font.pixelSize: 13
                        color: palette.text
                        leftPadding: 6
                        background: Rectangle { color: palette.base }
                        readOnly: true
                    }

                    Rectangle {
                        width: 30
                        Layout.fillHeight: true
                        color: palette.button
                        border.color: palette.mid
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "📅"
                            font.pixelSize: 14
                        }
                    }
                }
            }

            // ── Calendar + Time side-by-side ───────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // ── Calendar panel ─────────────────────────────────────────
                Rectangle {
                    Layout.fillHeight: true
                    width: 270
                    color: palette.base

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Month navigation header
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: palette.highlight

                            RowLayout {
                                anchors { fill: parent; leftMargin: 4; rightMargin: 4 }

                                // Prev month button
                                Rectangle {
                                    width: 22; height: 22
                                    color: prevHover.containsMouse ? palette.midlight : "transparent"
                                    radius: 3
                                    Text {
                                        anchors.centerIn: parent
                                        text: "◄"
                                        color: palette.highlightedText
                                        font.pixelSize: 11
                                    }
                                    MouseArea {
                                        id: prevHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (root.viewMonth === 0) { root.viewMonth = 11; root.viewYear-- }
                                            else root.viewMonth--
                                        }
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: root.monthNames[root.viewMonth] + " " + root.viewYear
                                    color: palette.highlightedText
                                    font { pixelSize: 14; bold: true }
                                }

                                // Next month button
                                Rectangle {
                                    width: 22; height: 22
                                    color: nextHover.containsMouse ? palette.midlight : "transparent"
                                    radius: 3
                                    Text {
                                        anchors.centerIn: parent
                                        text: "►"
                                        color: palette.highlightedText
                                        font.pixelSize: 11
                                    }
                                    MouseArea {
                                        id: nextHover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (root.viewMonth === 11) { root.viewMonth = 0; root.viewYear++ }
                                            else root.viewMonth++
                                        }
                                    }
                                }
                            }
                        }

                        // Day-of-week header row
                        Row {
                            Layout.fillWidth: true
                            height: 24

                            Repeater {
                                model: root.dayNames
                                delegate: Rectangle {
                                    width: 270 / 7
                                    height: 24
                                    color: palette.base
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData
                                        font { pixelSize: 11; bold: true }
                                        color: palette.windowText
                                    }
                                }
                            }
                        }

                        // Day grid (6 rows × 7 cols)
                        GridView {
                            id: dayGrid
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            cellWidth:  270 / 7
                            cellHeight: 28
                            interactive: false

                            model: {
                                var cells = []
                                var fd = root.firstDayOfMonth()
                                var dim = root.daysInMonth(root.viewYear, root.viewMonth)
                                var prevDim = root.daysInMonth(
                                    root.viewMonth === 0 ? root.viewYear - 1 : root.viewYear,
                                    root.viewMonth === 0 ? 11 : root.viewMonth - 1)
                                for (var i = 0; i < fd; i++)
                                    cells.push({ day: prevDim - fd + 1 + i, cur: false })
                                for (var d = 1; d <= dim; d++)
                                    cells.push({ day: d, cur: true })
                                var tail = 42 - cells.length
                                for (var t = 1; t <= tail; t++)
                                    cells.push({ day: t, cur: false })
                                return cells
                            }

                            delegate: Rectangle {
                                width:  dayGrid.cellWidth
                                height: dayGrid.cellHeight

                                property bool isSelected: modelData.cur &&
                                    modelData.day === root.selectedDate.getDate() &&
                                    root.viewMonth  === root.selectedDate.getMonth() &&
                                    root.viewYear   === root.selectedDate.getFullYear()

                                color: isSelected                               ? palette.highlight
                                     : cellHover.containsMouse && modelData.cur ? palette.midlight
                                     : palette.base
                                radius: 2

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.day
                                    font.pixelSize: 12
                                    font.bold: isSelected
                                    color: isSelected     ? palette.highlightedText
                                         : !modelData.cur ? palette.mid
                                         : palette.text
                                }

                                MouseArea {
                                    id: cellHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: modelData.cur
                                    onClicked: {
                                        var nd = new Date(root.selectedDate)
                                        nd.setFullYear(root.viewYear)
                                        nd.setMonth(root.viewMonth)
                                        nd.setDate(modelData.day)
                                        root.selectedDate = nd
                                    }
                                }
                            }
                        }

                        // Bottom buttons: Today / Now
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: palette.window
                            border.color: palette.mid
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                Button {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: "Today"
                                    flat: true
                                    font.pixelSize: 12
                                    onClicked: {
                                        var now = new Date()
                                        root.viewYear  = now.getFullYear()
                                        root.viewMonth = now.getMonth()
                                        var nd = new Date(root.selectedDate)
                                        nd.setFullYear(now.getFullYear())
                                        nd.setMonth(now.getMonth())
                                        nd.setDate(now.getDate())
                                        root.selectedDate = nd
                                    }
                                }

                                Rectangle { width: 1; Layout.fillHeight: true; color: palette.mid }

                                Button {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    text: "Now"
                                    flat: true
                                    font.pixelSize: 12
                                    onClicked: {
                                        var now = new Date()
                                        var nd = new Date(root.selectedDate)
                                        nd.setHours(now.getHours())
                                        nd.setMinutes(now.getMinutes())
                                        root.selectedDate = nd
                                        timeList.positionViewAtIndex(root.selectedTimeIndex(), ListView.Center)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Vertical divider ───────────────────────────────────────
                Rectangle { width: 1; Layout.fillHeight: true; color: palette.mid }

                // ── Time panel ─────────────────────────────────────────────
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: palette.base

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // "Time" header
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: palette.highlight
                            Text {
                                anchors.centerIn: parent
                                text: "Time"
                                color: palette.highlightedText
                                font { pixelSize: 14; bold: true }
                            }
                        }

                        // Time list
                        ListView {
                            id: timeList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: root.timeSlots

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AlwaysOn
                                width: 12
                            }

                            Component.onCompleted: {
                                timeList.positionViewAtIndex(root.selectedTimeIndex(), ListView.Center)
                            }

                            delegate: Rectangle {
                                width: timeList.width
                                height: 26

                                property bool isSelected:
                                    modelData.hour   === root.selectedDate.getHours() &&
                                    modelData.minute === (root.selectedDate.getMinutes() < 30 ? 0 : 30)

                                color: isSelected              ? palette.highlight
                                     : timeHover.containsMouse ? palette.midlight
                                     : palette.base

                                Text {
                                    anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 8 }
                                    text: modelData.label
                                    font.pixelSize: 12
                                    color: isSelected ? palette.highlightedText : palette.text
                                }

                                MouseArea {
                                    id: timeHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        var nd = new Date(root.selectedDate)
                                        nd.setHours(modelData.hour)
                                        nd.setMinutes(modelData.minute)
                                        root.selectedDate = nd
                                    }
                                }
                            }
                        }

                        // "Done" button
                        Rectangle {
                            Layout.fillWidth: true
                            height: 30
                            color: palette.window
                            border.color: palette.mid
                            border.width: 1

                            Button {
                                anchors.fill: parent
                                text: "Done"
                                flat: true
                                font.pixelSize: 12
                                onClicked: {
                                    console.log("Selected:", root.formatHeader())
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
