import QtQuick 2.0
import Ubuntu.Components 0.1

Page {
    title: ""
    visible: false
    tools: ToolbarItems {

        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: Qt.resolvedUrl("../resources/images/trash.png")

            onTriggered: {
                model.remove(index)
                stack.push(home)
            }
        }
        locked: true
        opened: true
    }

    property real index

    // Page content
    Column {
        TextArea {
            id: memoryArea
            textFormat: TextEdit.RichText
        }
    }

    property Memory memory;

    function setMemory(str) {
        memoryArea.text = str
    }

    function fill (mem) {
        memory = mem
        title = mem.title
    }

}
