import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1

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
                editing = true
                locationField.text = location.text
                weatherFiled.text = weather.text
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

        ToolbarButton {
            id: saveButton
            text: i18n.tr("Save")
            iconSource: icon("save")
            visible: editing
            onTriggered: {
                for (var i = 0; i < model.count; i++) {
                    var item = model.get(i).mem
                    if (item === memory) {
                        memory.remove()
                        print(memoryArea.text)
                        var component = Qt.createComponent("Memory.qml")
                        var new_memory = component.createObject(toolbar,
                                                          { "title": memory.title,
                                                            "tags" : "tags.text",
                                                            "description": memoryArea.text,
                                                            "date": "date.text",
                                                            "location": locationField.text,
                                                            "weather": "watherField.text"
                                                           })
                        model.append ({
                                          "mem": new_memory
                                      })
                        model.move(model.count-1, i, 1)
                        memory = new_memory
                        editing = false
                        return
                    }
                }
            }
        }

        locked: true
        opened: true
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
                color: UbuntuColors.warmGrey
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

        TextArea {
            id: memoryArea
            anchors.right: parent.right
            anchors.left: parent.left
            textFormat: TextEdit.RichText
            readOnly: !editing
            visible: (length > 0) && (text != "") || editing
        }

        Label {
            id: location
            visible: (text != "") && !editing
        }
        TextField {
            id: locationField
            placeholderText: "Location..."
            visible: !memoryArea.readOnly // EH? :S it works!
        }

        Label {
            id: weather
            visible: (text != "") && !editing
        }
        TextField {
            id: weatherFiled
            placeholderText: "Weather Conditions..."
            visible: !memoryArea.readOnly // EH? :S it works!
        }
    }

    property Memory memory;

    onMemoryChanged: {
        if(memory == null)
            return;

        title = memory.title
        memoryArea.text = memory.description
        location.text = memory.location
        weather.text = memory.weather
    }

}
