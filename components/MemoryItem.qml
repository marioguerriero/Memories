import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Standard {
    id: item
    text: "Memory"
    progression: true

    onClicked: {
        stack.push(newMemory);
        newMemory.title = memory.title;
    }

    property Memory memory;

    function fill (mem) {
        item.text = mem.title
        memory = mem
    }
}
