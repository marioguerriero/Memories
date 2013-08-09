import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    title: ""
    visible: false
    tools: ToolbarItems {

        ToolbarButton {
            text: i18n.tr("Edit")
            iconSource: icon("edit")

            onTriggered: {
                model.remove(memory.index)
                stack.push(home)
            }
        }

        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")

            onTriggered: {
                model.remove(memory.index)
                stack.clear()
                stack.push(home)
            }
        }

        locked: true
        opened: true
    }

    property real index

    // Page content
    Column {
        id: col
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        TextArea {
            id: memoryArea
            anchors.right: parent.right
            anchors.left: parent.left
            textFormat: TextEdit.RichText
            readOnly: true
        }

        ListItem.Standard {
            id: locationItem
            icon: Qt.resolvedUrl("../resources/images/location.png")
            visible: false
        }

        ListItem.Standard {
            id: weatherItem
            icon: Qt.resolvedUrl("../resources/images/sun.png")
            visible: false
        }
    }

    property Memory memory;

    onMemoryChanged: {
        title = memory.title
        memoryArea.text = memory.description

        locationItem.text = memory.location
        locationItem.visible = (locationItem.text != "")

        weatherItem.text = memory.weather
        weatherItem.visible = (weatherItem.text != "")
    }

}
