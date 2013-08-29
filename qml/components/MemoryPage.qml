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

    property bool editing: false
    onParentNodeChanged: {
        editing = false
    }

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

            onTriggered: {
                memoryEditPage.setMemory(memory)
                stack.push(memoryEditPage);
            }
        }

        ToolbarButton {
            text: i18n.tr("Delete")
            iconSource: icon("delete")

            onTriggered: {
                onClicked: PopupUtils.open(dialog)
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

            title: exported ? i18n.tr("Memory exported successfully") : i18n.tr("An error occurred!")
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
                    stack.push(homePage)
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
        anchors {
            margins: units.gu(2)
            fill: parent
        }

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
            color: "white"
            font.pointSize: units.gu(1.5)
        }

        ListItem.ThinDivider { }

        Label {
            text: i18n.tr("Tags")
            fontSize: "large"
            font.bold: true
        }

        Label {
            id: tags
            fontSize: "medium"
        }

        /*Label {
            id: weather
            //visible: (text != "") && !editing
            visible: false // for now
        }*/

        ListItem.ThinDivider { }

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
        tags.text = memory.tags
        locationLabel.text = memory.location
        //weather.text = memory.weather
        photoLayout.photos = memory.photos
    }

}
