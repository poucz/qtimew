import QtQuick 2.15

Item {
    id: root

    DummyEntry{
        id:s
    }

    BaseView{
        anchors.fill:parent
        timew: s.entries
    }

}
