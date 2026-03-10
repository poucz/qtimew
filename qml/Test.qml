import QtQuick 2.15
import QtQuick.Controls

Pane {
    id: root


    // V ApplicationWindow nebo hlavním Rectangle
    MouseArea {
        anchors.fill: parent
        z: -1  // pod vším ostatním
        onPressed: function(mouse) {
            forceActiveFocus()
            mouse.accepted = false
        }
    }


    DummyEntry{
        id:s
    }

    /*BaseView{
        anchors.fill:parent
        timew: s.entries
    }//*/


    TagsViewer{
        model:s.entries[0].tags
        suggest:s.entries[0].tags
    }

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
