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
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0
import Qt.labs.folderlistmodel 1.0

Page {
    id: page
    onWidthChanged: title = memory ? memory.title : ""

    visible: false

    actions: [
        Action {
            text: i18n.tr("Edit")
            keywords: i18n.tr("Edit")
            onTriggered: edit()
        },
        Action {
            text: i18n.tr("Delete")
            keywords: i18n.tr("Delete")
            onTriggered: PopupUtils.open(dialog)
        }
    ]

    property bool editing: false
    onParentNodeChanged: {
        editing = false
    }

    property var tags: []
    onTagsChanged: repeater.model = tags

    tools: ToolbarItems {
        ToolbarButton {
            action: Action {
                text: i18n.tr("Favorite")
                iconSource: memory ? (memory.favorite ? icon("favorite-selected") : icon("favorite-unselected")) : ""
                onTriggered: {
                    memory.favorite = !memory.favorite
                    homePage.saveMemories()
                }
            }
        }
        ToolbarButton {
            action: Action {
                text: i18n.tr("Edit")
                iconSource: icon("edit")
                onTriggered: edit()
            }
        }
        ToolbarButton {
            action: Action {
                text: i18n.tr("Delete")
                iconSource: icon("delete")
                onTriggered: PopupUtils.open(dialog)
            }
        }
    }

    // Delete dialog
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Delete")
            text: i18n.tr("Are you sure you want to delete this memory?")
            Button {
                text: i18n.tr("Delete")
                color: UbuntuColors.orange
                onClicked: {
                    PopupUtils.close(dialogue)
                    memory.remove()
                    stack.clear()
                    stack.push(tabs)
                }
            }
            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    // Page content
    Flickable {
        id: flickable

        anchors {
            left: parent.left
            right: parent.right
            fill: parent
        }

        clip: true

        height: layout.height

        contentHeight: layout.height
        interactive: contentHeight > height

        flickableDirection: Flickable.VerticalFlick

        Grid {
            id: layout

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: units.gu(2)
            }

            spacing: wideAspect ? units.gu(4) : units.gu(2)
            columns: wideAspect ? 2 : 1

            Behavior on columns { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }

            Column {
                id: firstColumn
                width: wideAspect ? parent.width / 2 : parent.width
                spacing: units.gu(2)

                Label {
                    id: dateLabel
                    objectName: "dateLabel"
                    color: UbuntuColors.orange
                    fontSize: "large"
                }

                Label {
                    id: locationLabel
                    fontSize: "large"
                    font.bold: true
                }

                Label {
                    id: memoryArea
                    width: parent.width
                    wrapMode: Text.WordWrap
                    visible: text != ""
                    onLinkActivated: Qt.openUrlExternally(link)
                    color: "white"
                    fontSize: "medium"
                    Behavior on height { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
                }

                ListItem.ThinDivider { visible: !wideAspect }

                AudioLayout {
                    id: audioLayout
                    editable: false
                    memory: memory
                    iconSize: wideAspect ? units.gu(14) : units.gu(10)
                    Behavior on iconSize { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
                }

                Behavior on width { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
            }

            Column {
                id: secondColumn
                spacing: units.gu(2)
                width: wideAspect ? parent.width / 2 : parent.width

                // Tags
                Label {
                    visible: tags.length > 0
                    text: i18n.tr("Tags")
                    fontSize: "large"
                    font.bold: true
                }

                Flickable {
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    height: tagRow.height

                    contentWidth: tagRow.width
                    interactive: contentWidth > width

                    flickableDirection: Flickable.HorizontalFlick

                    Row {
                        id: tagRow
                        spacing: units.gu(2)
                        Repeater {
                            id: repeater
                            model: []

                            delegate: Button {
                                text: modelData
                                onClicked: {
                                    homePage.filterByTag(modelData)
                                    stack.clear()
                                    stack.push(tabs)
                                }
                            }
                        }
                    }
                }

                ListItem.ThinDivider { visible: tags.length > 0 }

                // Photos
                PhotoLayout {
                    id: photoLayout
                    editable: false
                    iconSize: wideAspect ? units.gu(16) : units.gu(14)
                    Behavior on iconSize { UbuntuNumberAnimation { duration: UbuntuAnimation.SlowDuration } }
                }
            }
        }
    }
    property Memory memory;

    onMemoryChanged: {
        if(memory == null)
            return;

        dateLabel.text = memory.date
        title = memory.title
        memoryArea.text = memory.description
        tags = memory.getTags()
        locationLabel.text = memory.location
        //weather.text = memory.weather
        photoLayout.photos = memory.photos
        photoLayout.memory = memory
    }

    function edit() {
        memoryEditPage.setMemory(memory)
        stack.push(memoryEditPage);
    }

}
