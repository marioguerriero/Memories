import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Page {
    id: newMemoryPage
    title: i18n.tr("New Memory")
    visible: false

    // Some functions
    function clear() {
        title.text = ""
        description.text = ""
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
                newMemoryPage.clear()
                PopupUtils.open(photo)
            }
        }

        ToolbarButton {
            id: saveButton
            text: i18n.tr("Save")
            iconSource: icon("save")

            onTriggered: {
                if (!enabled) return;
                var component = Qt.createComponent("Memory.qml")

                // Date
                var dt = date.text
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
                                                {   "title": title.text,
                                                    "tags" : tags.text,
                                                    "description": description.text,
                                                    "date": dt,
                                                    "location": locationString.text,
                                                    "weather": "",
                                                    "photos": photos
                                                })
                model.append ({
                                  "mem": memory
                              })
                newMemoryPage.clear()
                stack.push(home);
            }
            enabled: false
        }

        locked: false
        opened: false
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
            id: date
            anchors.left: parent.left
            anchors.right: parent.right
            text: Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")
            placeholderText: i18n.tr("Date...")
        }

        TextField {
            id: title
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Title...")
            onTextChanged: {
                saveButton.enabled = (text != "")
            }
        }

        TextField {
            id: tags
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Tags...")
            visible: false
        }

        TextArea {
            id: description
            placeholderText: "Memory"
            autoSize: true
            maximumLineCount: 5
            anchors.left: parent.left
            anchors.right: parent.right
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
                        "source": path,
                        "editing": true,
                    }

                    var shape = component.createObject(photoGrid, params)

                    photoContainer.children.append += shape

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
                        PopupUtils.open(photoDialog)
                    }
                }
            }

            TextField {
                id: locationString
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
                        params: {name:locationString.text, units:"metric"}
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
                anchors.top: locationString.bottom
                model:  citiesModel
                delegate: ListItem.Standard {
                    objectName: "searchResult" + index
                    text: i18n.tr(name)+((country) ? ', '+i18n.tr(country): '');
                    progression: true;
                    onClicked: {
                        locationString.text = text
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
                    console.log(messageObject.error.msg+" / "+messageObject.error.request.url)
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
