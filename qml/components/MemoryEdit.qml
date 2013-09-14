/**
 * This file is part of Memories.
 *
 * Copyright 2013 (C) Mario Guerriero <mefrio.g@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.Components.Popups 0.1
import Qt.labs.folderlistmodel 1.0

Page {
    id: memoryEditPage
    objectName: "memoryEdit"
    onWidthChanged: title = truncate(editing ? (i18n.tr("Editing: ") + memory.title) : i18n.tr("New Memory"), parent.width, units.gu(2.3))

    visible: false

    actions: [
        Action {
            text: i18n.tr("Save")
            keywords: i18n.tr("Save")
            onTriggered: save()
        },
        Action {
            text: i18n.tr("Clear")
            keywords: i18n.tr("Clear")
            onTriggered: clear()
        }
    ]

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: tools
                opened: true
                locked: true
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
        title = truncate(i18n.tr("New Memory"), parent.width, units.gu(2.3))
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
        title = truncate(i18n.tr("Editing: ") + titleField.text, parent.width, units.gu(2.3))
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
            objectName: "clearBtn"
            text: i18n.tr("Clear")
            iconSource: icon("reset")

            onTriggered: {
                memoryEditPage.clear()
            }
        }

        ToolbarButton {
            id: saveButton
            text: i18n.tr("Save")
            iconSource: icon("save")

            onTriggered: save()
            enabled: false
        }

        locked: false
        opened: false
    }

    // Page content
    Flickable {
        id: flickableView

        anchors {
            fill: parent
        }

        clip: true

        contentHeight: layout.height
        interactive: contentHeight + units.gu(5) > height

        flickableDirection: Flickable.VerticalFlick

        Grid {
            id: layout

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: units.gu(2)
                topMargin: units.gu(2)
            }

            spacing: wideAspect ? units.gu(4) : units.gu(2)
            columns: wideAspect ? 2 : 1

            Behavior on columns { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }

            Column {
                id: firstColumn
                width: wideAspect ? parent.width / 2 - units.gu(2) : parent.width

                spacing: units.gu(1)

                TextField {
                    id: titleField
                    objectName: "titleField"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: i18n.tr("Title...")
                    onTextChanged: {
                        saveButton.enabled = (text != "")
                    }

                    InverseMouseArea {
                        onClicked: {
                            memoryEditPage.forceActiveFocus()
                            parent.focus = false
                            mouse.accepted = false
                        }
                        anchors.fill: parent;
                        visible: parent.activeFocus;
                        propagateComposedEvents: true
                    }
                }

                Row {
                    width: parent.width
                    spacing: units.gu(1)
                    TextField {
                        id: dateField
                        objectName: "dateField"
                        property var date: { return new Date() }
                        onDateChanged: text = Qt.formatDateTime(date, "ddd d MMMM yyyy")
                        width: parent.width - height - parent.spacing
                        text: Qt.formatDateTime(date, "ddd d MMMM yyyy")
                        placeholderText: i18n.tr("Date...")
                        function setCurrentDate () {
                            text = Qt.formatDateTime(new Date(), "ddd d MMMM yyyy")
                        }

                        InverseMouseArea {
                            onClicked: {
                                memoryEditPage.forceActiveFocus()
                                parent.focus = false
                                mouse.accepted = false
                            }
                            anchors.fill: parent;
                            visible: parent.activeFocus;
                            propagateComposedEvents: true
                        }
                    }
                    Button {
                        id: dateButton
                        iconSource: image("select.png")
                        height: dateField.height
                        width: height
                        property alias date: dateField.text
                        onClicked: PopupUtils.open(Qt.resolvedUrl("DatePicker.qml"), dateField)
                    }
                }

                TextArea {
                    id: descriptionArea
                    objectName: "descriptionArea"
                    placeholderText: i18n.tr("Memory...")
                    height: wideAspect ? units.gu(24) : units.gu(12)
                    //maximumLineCount: 10
                    anchors.left: parent.left
                    anchors.right: parent.right
                    onHighlightedChanged: rect.show = highlighted
                    Behavior on height{ UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }

                    InverseMouseArea {
                        onClicked: {
                            memoryEditPage.forceActiveFocus()
                            parent.focus = false
                            mouse.accepted = false
                        }
                        anchors.fill: parent;
                        visible: parent.activeFocus;
                        propagateComposedEvents: true
                    }
                }

                Rectangle {
                    id: rect
                    width: descriptionArea.width
                    height: 0
                    color: "transparent"
                    visible: false
                    //visible: descriptionArea.highlighted

                    property bool show

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
                        onStarted: rect.visible = true
                    }
                    ParallelAnimation {
                        id: animateHide
                        NumberAnimation {
                            target: rect;
                            properties: "height";
                            from: rect.height
                            to: 0
                            duration: UbuntuAnimation.FastDuration
                        }
                        onRunningChanged: if(!animateHide.running) rect.visible = false
                    }
                    onShowChanged: {
                        if(show)
                            animateShow.start()
                        else
                            animateHide.start()
                    }

                    //onVisibleChanged: animateShow.start()
                    TextTagsRow {
                        height: rect.height
                    }
                }

                TextField {
                    id: tagsField
                    objectName: "tagsField"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: i18n.tr("Tags... (separed by a comma)")
                    validator: RegExpValidator { regExp: /^[\S]*$/ }

                    InverseMouseArea {
                        onClicked: {
                            memoryEditPage.forceActiveFocus()
                            parent.focus = false
                            mouse.accepted = false
                        }
                        anchors.fill: parent;
                        visible: parent.activeFocus;
                        propagateComposedEvents: true
                    }
                }

                Behavior on width { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
            }
            Column {
                id: secondColumn
                width: wideAspect ? parent.width / 2 - units.gu(2) : parent.width
                spacing: units.gu(1)

                PhotoLayout {
                    id: photoLayout
                    editable: true
                    iconSize: wideAspect ? units.gu(12) : units.gu(8)
                    Behavior on iconSize { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
                }

                AudioLayout {
                    id: audioLayout
                    editable: true
                    memory: memory
                    iconSize: wideAspect ? units.gu(12) : units.gu(8)
                    Behavior on iconSize { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
                }

                TextField {
                    id: locationField
                    objectName: "LocationField"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    placeholderText: i18n.tr("Location...")
                    hasClearButton: true
                    onTextChanged: {
                        citiesModel.clear();
                        searchWorker.sendMessage({
                            action: "searchByName",
                            params: {name:locationField.text, units:"metric"}
                        })
                    }

                    InverseMouseArea {
                        onClicked: {
                            memoryEditPage.forceActiveFocus()
                            parent.focus = false
                            mouse.accepted = false
                        }
                        anchors.fill: parent;
                        visible: parent.activeFocus;
                        propagateComposedEvents: true
                    }
                }

                ListView {
                    id: listView;
                    objectName: "SearchResultList"
                    visible: false
                    clip: true
                    height: wideAspect ? units.gu(45) : units.gu(20)
                    width: parent.width
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

    tools: toolbar

    function save() {
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

        var memory = component.createObject(toolbar,
                               {   "title": titleField.text,
                                   "tags" : tagsField.text,
                                   "description": descriptionArea.text,
                                   "date": dt,
                                   "location": locationField.text,
                                   "weather": "",
                                   "audio": audioLayout.path,
                                   "photos": photoLayout.photos
                                })
        model.append ({ "mem": memory })

        if(editing)
            model.move(model.count-1, index, 1)

        homePage.saveMemories()

        stack.push(tabs)
        memoryEditPage.clear()
    }

}
