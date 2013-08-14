import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Page {
    id: page
    title: ""
    visible: false

    property bool editing: false
    onParentNodeChanged: {
        editing = false
    }

    tools: ToolbarItems {

        ToolbarButton {
            text: i18n.tr("Edit")
            iconSource: icon("edit")
            visible: !editing

            onTriggered: {
                memoryEditPage.setMemory(memory)
                stack.push(memoryEditPage);
            }
        }

        ToolbarButton {
            text: i18n.tr("Cancel")
            iconSource: icon("cancel")
            visible: editing

            onTriggered: {
                editing = false
            }
        }

        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")

            onTriggered: {
                onClicked: PopupUtils.open(dialog)
            }
        }

        locked: false
        opened: false
    }

    // Delete dialog
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: "Delete"
            text: "Are you sure you want to delete this memory?"
            Button {
                text: "Cancel"
                color: UbuntuColors.orange
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                text: "Delete"
                color: UbuntuColors.orange
                onClicked: {
                    PopupUtils.close(dialogue)
                    memory.remove()
                    stack.clear()
                    stack.push(home)
                }
            }
        }
    }

    // Page content
    Column {
        id: col
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        UbuntuShape {
            id: dateShape
            objectName: "dateShape"
            width: parent.width
            height: 35
            visible: !editing

            property alias text : label.text

            Label {
                id: label
                anchors.centerIn: parent
            }
        }

        TextArea {
            id: memoryArea
            anchors.right: parent.right
            anchors.left: parent.left
            textFormat: TextEdit.RichText
            readOnly: !editing
            visible: (length > 0) && (text != "") || editing
        }

        Label {
            id: tags
            visible: (text != "") && !editing
        }

        Label {
            id: location
            visible: (text != "") && !editing
        }

        Label {
            id: weather
            //visible: (text != "") && !editing
            visible: false // for now
        }

        // Photos
        Grid {
            id: photoViewGrid
            objectName: "photoViewGrid"
            columns: (mainView.width - units.gu(4)) / units.gu(8) - 1
            spacing: 12
            visible: memoryArea.readOnly
        }
    }

    property Memory memory;

    onMemoryChanged: {
        if(memory == null)
            return;

        dateShape.text = memory.date
        title = memory.title
        memoryArea.text = memory.description
        tags.text = memory.tags
        location.text = memory.location
        weather.text = memory.weather
        // Clean photo views
        photoViewGrid.children = ""
        // Append photos
        var photo_list = memory.photos.split("||")
        for(var i = 0; i < photo_list.length; i++) {
            if(photo_list[i] == "")
                return
            var component = Qt.createComponent("PhotoItem.qml")
            var params = {
                "source": photo_list[i],
            }
            // Add to photoViewGrid...
            var shape = component.createObject(photoViewGrid, params)
            photoViewGrid.children.append += shape
        }
    }

}
