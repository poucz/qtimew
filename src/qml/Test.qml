import QtQuick 2.15
import QtQuick.Controls

Pane {
    id: root



    DummyEntry{
        id:s

    }

    BaseView{
        anchors.fill:parent
        timew: s.entries
    }//*/



/*    Button{
        onClicked:{
            edit.open()
        }
    }
    EditEntry{
        id:edit
        anchors.centerIn:parent
        //anchors.fill:parent
        itemId:s.entries[0].id
        start:s.entries[0].start
        end:s.entries[0].end
        annotation:s.entries[0].annotation
        tags:s.entries[0].tags
    }
    Component.onCompleted:edit.open()
    */
}
