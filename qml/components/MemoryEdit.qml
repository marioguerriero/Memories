import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Page {
    id: memoryEditPage
    title: i18n.tr("New Memory")

    function setTitle(text) {
        if (text.length > parent.width / units.gu(2)) {
            text = text.substring(0, parent.width / units.gu(2.3));
            text += "...";
        }
        memoryEditPage.title = text
    }

    visible: false

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: tools
                locked: true
                opened: true
            }

            PropertyChanges {
                target: parent
                anchors.bottomMargin: units.gu(-2)
            }
        }

    ]

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
        photoLayout.photos = []
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
        photoLayout.photos = memory.photos
    }

    function addPhoto(path) {
        photoLayout.addPhoto(path)

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
                var model = homePage.model
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
                /*var photos = ""
                for(var i = 0; i < photoLayout.photos.length; i++) {
                    var photo_path = photoLayout.photos[i]
                    if(photo_path)
                        photos += photo_path + "||"
                }*/

                var memory = component.createObject(toolbar,
                                                {   "title": titleField.text,
                                                    "tags" : tagsField.text,
                                                    "description": descriptionArea.text,
                                                    "date": dt,
                                                    "location": locationField.text,
                                                    "weather": "",
                                                    "photos": photoLayout.photos
                                                })
                model.append ({
                                  "mem": memory
                              })
                if(editing)
                    model.move(model.count-1, index, 1)

                stack.push(homePage);
                memoryEditPage.clear()
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
            //autoSize: true
            maximumLineCount: 5
            anchors.left: parent.left
            anchors.right: parent.right
        }

        Rectangle {
            id: rect
            width: descriptionArea.width
            height: 0
            color: "transparent"
            visible: descriptionArea.highlighted

            // Animate on visible changed
            ParallelAnimation {
                id: animateShow
                NumberAnimation {
                    target: rect;
                    properties: "height";
                    from: 0
                    to: units.gu(4)
                    duration: UbuntuAnimation.FastDuration
                }
            }
            onVisibleChanged: animateShow.start()

            Row {
                spacing: units.gu(1)
                Button {
                    height: parent.height
                    width: units.gu(4)
                    iconSource: image("bold.png")
                    onClicked: {
                        var open = "<b>"
                        var close = "</b>"
                        descriptionArea.insert(descriptionArea.cursorPosition, open + close)
                        descriptionArea.cursorPosition -= close.length
                    }
                }
                Button {
                    height: units.gu(4)
                    width: units.gu(4)
                    iconSource: image("italic.png")
                    onClicked: {
                        var open = "<i>"
                        var close = "</i>"
                        descriptionArea.insert(descriptionArea.cursorPosition, open + close)
                        descriptionArea.cursorPosition -= close.length
                    }
                }
                Button {
                    height: units.gu(4)
                    width: units.gu(4)
                    iconSource: image("underline.png")
                    onClicked: {
                        var open = "<u>"
                        var close = "</u>"
                        descriptionArea.insert(descriptionArea.cursorPosition, open + close)
                        descriptionArea.cursorPosition -= close.length
                    }
                }
                Button {
                    height: units.gu(4)
                    width: units.gu(4)
                    iconSource: image("substring.png")
                    onClicked: {
                        var open = "<sub>"
                        var close = "</sub>"
                        descriptionArea.insert(descriptionArea.cursorPosition, open + close)
                        descriptionArea.cursorPosition -= close.length
                    }
                }
                Button {
                    height: units.gu(4)
                    width: units.gu(4)
                    iconSource: image("supstring.png")
                    onClicked: {
                        var open = "<sup>"
                        var close = "</sup>"
                        descriptionArea.insert(descriptionArea.cursorPosition, open + close)
                        descriptionArea.cursorPosition -= close.length
                    }
                }
            }
        }

        TextField {
            id: tagsField
            objectName: "tagsField"
            anchors.left: parent.left
            anchors.right: parent.right
            placeholderText: i18n.tr("Tags... (separed by a comma)")
        }

        // Photos
        Rectangle {
            id: photoContainer
            width: parent.width
            height: units.gu(8)
            color: "transparent"

            PhotoLayout {
                id: photoLayout
                editable: true
            }

            TextField {
                id: locationField
                objectName: "LocationField"
                anchors.top: photoLayout.bottom
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
