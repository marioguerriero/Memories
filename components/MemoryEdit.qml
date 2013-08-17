import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Page {
    id: memoryEditPage
    title: i18n.tr("New Memory")

    function setTitle(text) {
        var string = text
        var title = ""
        var length = string.length
        var pixel = 1 // The approximative size of each character
        var dif = mainView.width / (length*pixel) + units.gu(1) // -1 as it is for spacing

        for(var n = 0; n < string.length; n++) {
            if(dif < length && n >= dif)
                title = string.substring(0, dif-2) + "..."
            else
                title = string
        }
        memoryEditPage.title = title
    }

    visible: false

    // Some functions
    function clear() {
        editing = false
        setTitle(i18n.tr("New Memory"))
        titleField.text = ""
        dateField.setCurrentDate()
        descriptionArea.text = ""
        tagsField.text = ""
        locationField.text = ""
        //weatherField.text = ""
        photoGrid.clean()
    }

    property Memory memory
    property bool editing: false
    function setMemory(mem) {
        clear()
        memory = mem
        editing = true
        titleField.text = memory.title
        setTitle(i18n.tr("Editing: ") + titleField.text)
        dateField.text = memory.date
        descriptionArea.text = memory.description
        tagsField.text = memory.tags
        locationField.text = memory.location
        //weatherField.text = memory.weather
        photoGrid.addPhotos(memory.photos)
    }

    // Toolbar
    ToolbarItems {
        id: toolbar
        property int index: 0
        ToolbarButton {
            id: clearButton
            text: i18n.tr("Clear")
            iconSource: icon("back")

            onTriggered: {
                memoryEditPage.clear()
            }
        }

        ToolbarButton {
            id: saveButton
            text: i18n.tr("Save")
            iconSource: icon("save")

            onTriggered: {
                if (!enabled) return;

                // If editing
                var index
                if(editing) {
                    for(var i = 0; i < model.count; i++) {
                        var item = model.get(i).mem
                        if(item === memoryEditPage.memory) {
                            index = i
                            memoryEditPage.memory.remove()
                        }
                    }
                }

                var component = Qt.createComponent("Memory.qml")

                // Date
                var dt = dateField.text
                if(dt == "" || dt == null)
                    dt = Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")

                // Photos
                var photos = ""
                for(var i = 0; i < photoContainer.children.length; i++) {
                    var photo_path = photoContainer.children[i].source
                    print(photo_path)
                    if(photo_path)
                        photos += photo_path + "||"
                }

                var memory = component.createObject(toolbar,
                                                {   "title": titleField.text,
                                                    "tags" : tagsField.text,
                                                    "description": descriptionArea.displayText,
                                                    "date": dt,
                                                    "location": locationField.text,
                                                    "weather": "",
                                                    "photos": photos
                                                })
                model.append ({
                                  "mem": memory
                              })
                if(editing)
                    model.move(model.count-1, index, 1)
                memoryEditPage.clear()
                stack.push(home);
            }
            enabled: false
        }

        locked: true
        opened: true
    }

    // Page content
    Column {
        id: col
        spacing: units.gu(1)
        anchors {
            margins: units.gu(2)
            fill: parent
        }

        TextField {
            id: dateField
            objectName: "dateField"
            anchors.left: parent.left
            anchors.right: parent.right
            text: Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")
            placeholderText: i18n.tr("Date...")
            function setCurrentDate () {
                text = Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")
            }
        }

        TextField {
            id: titleField
            objectName: "titleField"
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Title...")
            onTextChanged: {
                saveButton.enabled = (text != "")
            }
        }

        TextArea {
            id: descriptionArea
            objectName: "descriptionArea"
            placeholderText: i18n.tr("Memory...")
            autoSize: true
            maximumLineCount: 5
            anchors.left: parent.left
            anchors.right: parent.right
            textFormat: TextEdit.AutoText
        }

        TextField {
            id: tagsField
            objectName: "tagsField"
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Tags... (separed by a comma)")
        }

        // Photos
        Component {
            id: photoSelectDialog

            Dialog {
                id: dialogue
                title: i18n.tr("Add a Photo")
                text: i18n.tr("Locate the photo file.")

                property string folderPath: "/home"
                property string file: ""

                onFileChanged: {
                    var path = folderPath + file
                    photoGrid.addPhotos(path)
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
                                    if(fileName.split(".").pop() === "png"
                                            || fileName.split(".").pop() === "jpg") {
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
                    text: i18n.tr("Take from Camera")
                    onClicked: {

                    }
                }
                Button {
                    text: i18n.tr("Cancel")
                    onClicked: PopupUtils.close(dialogue)
                }
            }
        }

        Rectangle {
            id: photoContainer
            width: parent.width
            height: units.gu(8)
            color: "transparent"
            default property alias children : photoGrid.children

            Grid {
                id: photoGrid
                objectName: "photoGrid"
                columns: (mainView.width - units.gu(4)) / units.gu(8) - 1
                spacing: 12
                Button {
                    id: photoButton
                    width: units.gu(8)
                    height: units.gu(8)
                    objectName: "LocationField"
                    iconSource: "../resources/images/import-image.png"
                    onClicked: {
                        PopupUtils.open(photoSelectDialog)
                    }
                }
                function addPhotos(photos) {
                    var photo_list = photos.split("||")
                    for(var i = 0; i < photo_list.length; i++) {
                        if(photo_list[i] == "")
                            return
                        var component = Qt.createComponent("./PhotoItem.qml")
                        var params = {
                            "source": photo_list[i],
                        }
                        // Add to photoViewGrid...
                        var shape = component.createObject(photoGrid, params)
                        photoGrid.children.append += shape
                    }
                }
                function clean() {
                    for(var k = photoGrid.children.length; k > 1 ; k--)
                        photoGrid.children[k-1].destroy()
                }
            }

            TextField {
                id: locationField
                objectName: "LocationField"
                anchors.top: photoGrid.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.topMargin: units.gu(1)
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

            ListView {
                id: listView;
                objectName: "SearchResultList"
                visible: false
                clip: true
                height: units.gu(35)
                width: parent.width
                anchors.top: locationField.bottom
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

        // Location
        WorkerScript {
            id: searchWorker
            objectName: "searchWorker"
            source: "./WeatherApi.js"
            onMessage: {
                if(!messageObject.error) {
                    listView.visible = true
                    messageObject.result.locations.forEach(function(loc) {
                        citiesModel.append(loc);
                        //noCityError.visible = false
                    });
                } else {
                    console.log(messageObject.error.msg + " / " + messageObject.error.request.url)
                }
                if (!citiesModel.count) {
                    // DO NOTHING!
                }
            }
        }

        ListModel {
            id: citiesModel
            objectName: "citiesModel"
        }
    }
    tools: toolbar

}
