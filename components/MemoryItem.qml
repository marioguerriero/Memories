import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

ListItem.Standard {
    id: item
    text: "Memory"
    progression: true

    // Properties for the Memory itself
    property string title
    property string description
    property string date
    property string location
    property string weather
    property int index: 1

    onClicked: {
        memoryPage.title = text
        memoryPage.index = index
        stack.push(memoryPage);
        memoryPage.fill(memory)
    }

    property Memory memory;

    function fill (mem) {
        item.text = mem.title
        memory = mem
    }
}
