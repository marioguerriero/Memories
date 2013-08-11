import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1

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
            }
        }

        ToolbarButton {
            id: saveButton
            text: i18n.tr("Save")
            iconSource: icon("save")

            onTriggered: {
                if (!enabled) return;
                var component = Qt.createComponent("Memory.qml")
                var dt = date.text
                if(dt == "" || dt == null)
                    dt = Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")
                var memory = component.createObject(toolbar,
                                                {   "title": title.text,
                                                    "tags" : tags.text,
                                                    "description": description.text,
                                                    "date": dt,
                                                    "location": locationString.text,
                                                    "weather": "",
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
            id: locationString
            objectName: "LocationField"
            anchors.left: parent.left
            anchors.right: parent.right
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

        ListModel {
            id: citiesModel
        }

        Rectangle {
            width: parent.width
            height: units.gu(52)
            color: "transparent"
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
                        locationString.text = text
                        //clear()
                    }
                }
                Scrollbar {
                    flickableItem: listView;
                    align: Qt.AlignTrailing;
                }
            }
        }
    }
    tools: toolbar

}
