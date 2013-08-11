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
                weatherField.text = weather.text
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
                                                            "weather": ""
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

        UbuntuShape {
            id: date
            width: 150
            height: 35
            visible: !editing

            property alias text : label.text

            Label {
                id: label
                anchors.centerIn: parent
                color: UbuntuColors.orange
            }
        }
        TextField {
            id: dateField
            anchors.right: parent.right
            anchors.left: parent.left
            text: date.text
            placeholderText: "Date..."
            visible: !memoryArea.readOnly // EH? :S it works!
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
        // Location
        WorkerScript {
            id: searchWorker
            source: "./WeatherApi.js"
            onMessage: {
                if(!messageObject.error) {
                    listView.visible = true
                    messageObject.result.locations.forEach(function(loc) {
                        citiesModel.append(loc);
                        //noCityError.visible = false
                    });
                } else {
                    console.log(messageObject.error.msg+" / "+messageObject.error.request.url)
                }
                if (!citiesModel.count) {
                    // DO NOTHING!
                }
            }
        }

        TextField {
            id: locationField
            objectName: "LocationField"
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !memoryArea.readOnly
            text: location.text
            placeholderText: i18n.tr("Location...")
            hasClearButton: true
            onTextChanged: {
                citiesModel.clear();
                searchWorker.sendMessage({
                    action: "searchByName",
                    params: {name:locationField.text, units:"metric"}
                })
            }
        }

        ListModel {
            id: citiesModel
        }

        Rectangle {
            width: parent.width
            height: units.gu(52)
            color: "transparent"
            visible: !memoryArea.readOnly
            ListView {
                id: listView;
                objectName: "SearchResultList"
                visible: false
                clip: true
                anchors.fill: parent
                model:  citiesModel
                delegate: ListItem.Standard {
                    objectName: "searchResult" + index
                    text: i18n.tr(name)+((country) ? ', '+i18n.tr(country): '');
                    progression: true;
                    onClicked: {
                        //var location = citiesModel.get(index)
                        //locationManager.addLocation(location)
                        //mainView.newLocationAdded(location)
                        //locationManagerSheet.addLocation(location)
                        //PopupUtils.close(addLocationSheet)
                        //pageStack.pop()
                        locationField.text = text
                        //clear()
                    }
                }
                Scrollbar {
                    flickableItem: listView;
                    align: Qt.AlignTrailing;
                }
            }
        }

        Label {
            id: weather
            visible: (text != "") && !editing
        }
        TextField {
            id: weatherField
            placeholderText: "Weather Conditions..."
            visible: !memoryArea.readOnly // EH? :S it works!
        }
    }

    property Memory memory;

    onMemoryChanged: {
        if(memory == null)
            return;

        date.text = memory.date
        title = memory.title
        memoryArea.text = memory.description
        location.text = memory.location
        weather.text = memory.weather
    }

}
