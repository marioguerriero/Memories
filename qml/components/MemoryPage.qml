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
    id: page
    title: ""   
    function setTitle(text) {
        if (text.length > parent.width / units.gu(2)) {
            text = text.substring(0, parent.width / units.gu(2.3));
            text += "...";
        }
        page.title = text
    }

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

    property bool editing: false
    onParentNodeChanged: {
        editing = false
    }

    property var tags: []
    onTagsChanged: repeater.model = tags

    // Friends Popover
    Component {
        id: shareComponent
        SharePopover {
            id: sharePopover
            onSend: {
                var share_string = page.memory.getShareString()
                friends.sendForAccountAsync(id, share_string)
                PopupUtils.close(sharePopover)
            }
        }
    }

    tools: ToolbarItems {

        ToolbarButton {
            text: i18n.tr("Favorite")
            iconSource: memory ? (memory.favorite ? icon("favorite-selected") : icon("favorite-unselected")) : ""

            onTriggered: {
                memory.favorite = !memory.favorite;
            }
        }

        ToolbarButton {
            id: exportButton
            objectName: "exportButton"
            text: i18n.tr("Export")
            iconSource: image("export-document.png")
            onTriggered: {
                exported = memory.exportAsPdf()
                PopupUtils.open(exportDialog)
            }
        }

        ToolbarButton {
            id: shareButton
            objectName: "shareButton"
            text: i18n.tr("Share")
            iconSource: icon("share")
            visible: accountsModel.count > 0

            onTriggered: {
                PopupUtils.open(shareComponent, shareButton)
            }
        }

        ToolbarButton {
            text: i18n.tr("Edit")
            iconSource: icon("edit")

            onTriggered: edit()
        }

        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")

            onTriggered: {
                PopupUtils.open(dialog)
            }
        }

        locked: false
        opened: false
    }

    // Export confirmation dialog
    property bool exported: false
    Component {
        id: exportDialog

        Dialog {
            id: exportDialogue

            title: exported ? i18n.tr("Memory exported successfully") : i18n.tr("An error occurred")
            text: exported ? memory.title + i18n.tr(" was exported in ") + memory.exportPath : i18n.tr("Please try again")

            Button {
                text: i18n.tr("Close")
                color: UbuntuColors.orange
                onClicked: PopupUtils.close(exportDialogue)
            }
        }
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
                gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                text: "Delete"
                color: UbuntuColors.orange
                onClicked: {
                    PopupUtils.close(dialogue)
                    memory.remove()
                    stack.clear()
                    stack.push(tabs)
                }
            }
        }
    }

    // Page content
    Flickable {
        id: flickable

        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(2)
            fill: parent
        }

        clip: true

        height: col.height

        contentHeight: col.height
        interactive: contentHeight > height

        flickableDirection: Flickable.VerticalFlick

        Column {
            id: col
            spacing: units.gu(2)
            width: parent.width

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

            Text {
                id: memoryArea
                anchors.right: parent.right
                anchors.left: parent.left
                width: parent.width
                wrapMode: Text.WordWrap
                visible: text != ""
                onLinkActivated: Qt.openUrlExternally(link)
                color: "white"
                font.pointSize: units.gu(1.5)
            }

            ListItem.ThinDivider { }

            /*Label {
                id: tags
                visible: text.length > 0
                fontSize: "medium"
            }*/

            /*Label {
                id: weather
                //visible: (text != "") && !editing
                visible: false // for now
            }*/

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
                iconSize: units.gu(12)
            }
        }
    }
    property Memory memory;

    onMemoryChanged: {
        if(memory == null)
            return;

        dateLabel.text = memory.date
        setTitle(memory.title)
        memoryArea.text = memory.description
        tags = memory.getTags()
        locationLabel.text = memory.location
        //weather.text = memory.weather
        photoLayout.photos = memory.photos
    }

    function edit() {
        memoryEditPage.setMemory(memory)
        stack.push(memoryEditPage);
    }

}
