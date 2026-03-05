import QtQuick 2.15


QtObject {
    property list<QtObject> entries: [
        QtObject {
            property int id: 1
            property date start: "2024-05-20T10:00:00" // Formát ISO 8601
            property date end: "2024-05-20T10:00:00" // Formát ISO 8601
            property var tags: ["°C"]
            property string annotation: "Toto teda nevim"
            property int duration: 12547
        },
        QtObject {
            property int id: 2
            property date start: "2024-05-20T10:00:00" // Formát ISO 8601
            property date end: "2024-05-20T10:00:00" // Formát ISO 8601
            property var tags: ["°C", "pg", "Interiér"]
            property string annotation: ""
            property int duration: 0
        },
        QtObject {
            property int id: 2
            property date start: "2024-05-20T10:00:00" // Formát ISO 8601
            property date end: "2024-05-20T10:00:00" // Formát ISO 8601
            property var tags: ["°C", "pg", "Interiér"]
            property string annotation: ""
            property int duration: 129
        }
    ]
}
