/**
 * This file is part of Memories.
 *
 * Copyright 2013-2015 (C) Mario Guerriero <marioguerriero33@gmail.com>
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

import QtQuick 2.2
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import "../../js/MD5.js" as Crypto

Page {
    id: home
    objectName: "homePage"
    title:  truncate(i18n.tr("Memories"), parent.width, units.gu(3))
    visible: false

    actions: [
        Action {
            text: i18n.tr("Quit")
            keywords: i18n.tr("Exit")
            onTriggered: Qt.quit()
        },
        Action {
            text: i18n.tr("New Memory")
            keywords: i18n.tr("New;Add")
            onTriggered : newMemory()
        },
        Action {
            text: i18n.tr("Grid Layout")
            keywords: i18n.tr("Grid")
            onTriggered : homePage.saveSetting("showGrid", true)
        },
        Action {
            text: i18n.tr("List Layout")
            keywords: i18n.tr("List")
            onTriggered : homePage.saveSetting("showGrid", false)
        },
        Action {
            text: i18n.tr("Set a Password")
            keywords: i18n.tr("Password")
            onTriggered : homePage.editPassword()
        }
    ]

    states: [
        State {
            when: showToolbar
            PropertyChanges {
                target: tools
                opened: true
                locked: false
            }

            PropertyChanges {
                target: parent
                anchors.bottomMargin: units.gu(-2)
            }
        }
    ]

    // Used to get the locked status while there is a password
    property bool locked: (password != nullPassword)

    Label {
        id: label
        objectName: "label"
        anchors.centerIn: parent
        fontSize: "large"
        text: i18n.tr("No memories!")
        visible: (memoryModel.count == 0)
    }

    // Filter sidebar
    FilterSidebar {
        id: sidebar
        objectName: "filterSidebar"
        visible: !label.visible && !locked
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        expanded: {
            if(wideAspect)
                appendTags(getTags())
            return wideAspect
        }
    }

    // List
    Component {
        id: memoryComponent

        Memory {

        }
    }

    property ListModel model: memoryModel
    ListModel {
        id: memoryModel
        onRowsInserted: {
            sidebar.appendTags(getTags())
            gridLayout.updateColumns()
        }
        onRowsRemoved: {
            sidebar.appendTags(getTags())
            gridLayout.updateColumns()
        }
    }

    Item {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: sidebar.right
            right: parent.right
        }
        ListView {
            id: list
            anchors.fill: parent
            visible: !locked && !showGrid
            clip: true
            model: memoryModel
            delegate: MemoryItem {
                memory: mem
            }
        }
        Scrollbar {
            flickableItem: list
            align: Qt.AlignTrailing
        }
        GridLayout {
            id: gridLayout
            anchors.fill: parent
            visible: showGrid && !locked
        }
    }

    // Toolbar
    head.actions: [
        Action {
            visible: !wideAspect && sidebar.currentCategory != sidebar.nullCategory
            text: i18n.tr("Reset filters")
            iconSource: icon("reset")
            onTriggered: {
                clearFilter()
                sidebar.currentCategory = sidebar.nullCategory
            }
        },

        Action {
            text: i18n.tr("New")
            iconSource: icon("add")
            onTriggered: newMemory()
        }
    ]

    function saveMemories() {
        print("Saving...")

        var memories = []

        for (var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            memories.push(memory.toJSON())
        }

        var tempContents = []
        tempContents = memoriesDatabase.contents
        tempContents.memories = JSON.stringify(memories)
        memoriesDatabase.contents = tempContents
    }

    function loadMemories() {
        console.log("Loading Memories...")
        if(memoriesDatabase.contents.memories) {
            var memories = JSON.parse(memoriesDatabase.contents.memories)
            for(var i = 0; i < memories.length; i++) {
                newMemoryObject(memories[i])
            }
        }
    }

    function newMemoryObject(args) {
        var memory = memoryComponent.createObject(memoryModel, args)

        if (memory === null) {
            console.log("Unable to create memory object!")
        }

        memoryModel.append({"mem": memory})
    }

    function removeMemory(memory) {
        for (var i = 0; i < memoryModel.count; i++) {
            var item = memoryModel.get(i).mem
            if (item === memory) {
                memoryModel.remove(i)
                item.destroy()
                return
            }
        }
    }

    // Search and filter functions
    function clearFilter() {
        for(var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            memory.visible = true
        }
    }

    function filterByTag(filter) {
        clearFilter()
        for(var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            var tags = memory.getTags()
            memory.visible = false
            for(var n = 0; n < tags.length; n++) {
                if(tags[n] == filter)
                    memory.visible = true
            }
        }
        // Update the sidebar
        sidebar.currentCategory = filter
    }

    function filterFavorites() {
        clearFilter()
        for(var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            memory.visible = memory.favorite
        }
    }

    function getTags() {
        var tags = []
        for(var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            var memoryTags = memory.getTags()
            for(var n = 0; n < memoryTags.length; n++) {
                var tag = memoryTags[n].replace(" ", "")
                tags.push(tag)
            }
        }
        return tags
    }

    function getMemories() {
        var memories = []
        for(var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            memories.push(memory)
        }
        return memories
    }

    // Utils functions
    function editPassword() {
        PopupUtils.open(passwordEditDialog)
    }
}
