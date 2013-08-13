import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.MultiValue {
    id: item
    progression: true

    onClicked: {
        memoryPage.memory = memory
        stack.push(memoryPage);
    }

    property Memory memory;

    onMemoryChanged: {
        if(!memory)
            return
        item.text = memory.title
        values = [ memory.date, memory.location ]
    }
}
