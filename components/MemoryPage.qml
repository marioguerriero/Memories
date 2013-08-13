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
                editing = true
                dateField.text = date.text
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

                        // Photos
                        var photos = ""
                        for(var n = 0; n < photoEditGrid.children.length; n++) {
                            var photo_path = photoEditGrid.children[n].source
                            if(photo_path)
                                photos += photo_path + "||"
                        }
                        var component = Qt.createComponent("Memory.qml")
                        var new_memory = component.createObject(toolbar,
                                                          { "title": memory.title,
                                                            "tags" : "tags.text",
                                                            "description": memoryArea.text,
                                                            "date": dateField.text,
                                                            "location": locationField.text,
                                                            "weather": "",
                                                            "photos": photos
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
            width: parent.width
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
            visible: !memoryArea.readOnly
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

        // Photos
        Component {
            id: photoDialog

            Dialog {
                id: dialogue
                title: i18n.tr("Add a Photo")
                text: i18n.tr("Locate the photo file.")

                property string folderPath: "/home"
                property string file: ""

                onFileChanged: {
                    var path = folderPath + file

                    var component = Qt.createComponent("PhotoItem.qml")
                    var params = {
                        "source": path
                    }
                    var shape = component.createObject(photoEditGrid, params)

                    photoEditGrid.children.append += shape

                    PopupUtils.close(dialogue)
                }

                Label {
                    id: folder
                    text: folderPath + file
                }

                ListView {
                    clip: true
                    height: units.gu(30)
                    FolderListModel {
                        id: folderModel
                        folder: folderPath
                        showDotAndDotDot: true
                    }

                    Component {
                        id: fileDelegate
                        ListItem.Standard {
                            text: fileName
                            onClicked: {
                                var split = folder.text.split("/")
                                if(fileName == "..") {
                                    if(split.length > 2) {
                                        for(var i = 1, newFolder = ""; i < split.length - 1; i++) {
                                            newFolder = newFolder + "/" + split[i]
                                        }
                                    } else {
                                        newFolder = "/"
                                    }
                                } else if(fileName == ".") {
                                    newFolder = "/"
                                }else {
                                    if(folder.text != "/") newFolder = folder.text + "/" + fileName
                                    else newFolder = "/" + fileName
                                }
                                if(folderModel.isFolder(index)) {
                                    folderPath = newFolder
                                    file = "";
                                } else {
                                    if(fileName.split(".").pop() === "png") {
                                        file = "/" + fileName
                                        PopupUtils.close(dialogue)
                                    }
                                }
                            }
                        }
                    }

                    model: folderModel
                    delegate: fileDelegate
                }
                Button {
                    text: i18n.tr("Cancel")
                    onClicked: PopupUtils.close(dialogue)
                }
            }
        }

        Grid {
            id: photoEditGrid
            objectName: "photoEditGrid"
            columns: (mainView.width - units.gu(4)) / units.gu(8) - 1
            spacing: 12
            visible: !memoryArea.readOnly
            Button {
                id: photoButton
                width: units.gu(8)
                height: units.gu(8)
                objectName: "LocationField"
                iconSource: "../resources/images/import-image.png"
                onClicked: {
                    PopupUtils.open(photoDialog)
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
                        locationField.text = text
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
            //visible: (text != "") && !editing
            visible: false // for now
        }
        TextField {
            id: weatherField
            placeholderText: "Weather Conditions..."
            visible: false // for now
            //visible: !memoryArea.readOnly
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

        date.text = memory.date
        title = memory.title
        memoryArea.text = memory.description
        location.text = memory.location
        weather.text = memory.weather
        // Clean photo views
        photoViewGrid.children = ""
        for(var k = photoEditGrid.children.length; k > 1 ; k--)
            photoEditGrid.children[k-1].destroy()
        // Append photos
        var photo_list = memory.photos.split("||")
        for(var i = 0; i < photo_list.length; i++) {
            if(photo_list[i] == "")
                return
            var component = Qt.createComponent("PhotoItem.qml")
            var params = {
                "source": photo_list[i]
            }
            // Add to photoViewGrid...
            var shape = component.createObject(photoViewGrid, params)
            photoViewGrid.children.append += shape
            // ...and to photoEditGrid both
            shape = component.createObject(photoEditGrid, params)
            photoEditGrid.children.append += shape
        }
    }

}
