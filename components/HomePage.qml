import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db

Page {
    id: home
    title: i18n.tr("Memories")
    visible: false

    Label {
        id: label
        objectName: "label"
        anchors.centerIn: parent
        fontSize: "large"
        text: i18n.tr("No memories!")
    }

    // Filter sidebar
    FilterSidebar {
        id: sidebar
        objectName: "filterSidebar"
        visible: !label.visible
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
            label.visible = false
            sidebar.appendTags(getTags())
        }
        onRowsRemoved: {
            label.visible = (memoryModel.count == 0)
            sidebar.appendTags(getTags())
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
            clip: true
            model: memoryModel
            delegate: MemoryItem {
                memory: mem
                height: {
                    if(!memory.visible)
                        return 0
                }
            }
        }
        Scrollbar {
            flickableItem: list
            align: Qt.AlignTrailing
        }
    }

    // Password manager
    Component {
        id: passwordEnterDialog
        Dialog {
            id: dialogue
            title: i18n.tr("Add your password")
            text: i18n.tr()
            TextField {
                id: passwordField
                placeholderText: i18n.tr("Password...")
                echoMode: TextInput.Password
            }
            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                text: i18n.tr("Save")
                color: UbuntuColors.orange
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    Component {
        id: popoverComponent

        Popover {
            id: popover

            property alias passwordChecked: passwordCheckbox.checked

            Column {
                id: containerLayout
                anchors {
                    left: parent.left
                    top: parent.top
                    right: parent.right
                }
                Standard {
                    //FIXME: Hack because of Suru theme!
                    Label {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            margins: units.gu(2)
                        }

                        text: i18n.tr("Protect memories with password")
                        fontSize: "medium"
                        color: Theme.palette.normal.overlayText
                    }

                    control: CheckBox {
                        id: passwordCheckbox
                        checked: (password != "")
                        onClicked: {
                            PopupUtils.close(popover)
                            if(checked)
                                PopupUtils.open(passwordEditDialog)
                            else
                                saveSetting("password", "")
                        }
                    }

                    showDivider: false
                }
            }
        }
    }

    Component {
        id: passwordEditDialog
        Dialog {
            id: dialogue
            title: i18n.tr("Protect your memories")
            text: i18n.tr("Set a password to keep unwanted people away from you records.")
            TextField {
                id: passwordField
                placeholderText: i18n.tr("Password...")
                echoMode: TextInput.Password
            }
            Button {
                text: i18n.tr("Cancel")
                gradient: UbuntuColors.greyGradient
                onClicked: {
                    PopupUtils.close(dialogue)
                }
            }
            Button {
                text: i18n.tr("Save")
                color: UbuntuColors.orange
                onClicked: PopupUtils.close(dialogue)
            }
        }
    }

    // Toolbar
    tools: ToolbarItems {

        ToolbarButton {
            id: newButton
            text: i18n.tr("New")
            iconSource: icon("add")

            onTriggered: {
                memoryEditPage.clear()
                stack.push(memoryEditPage)
            }
        }

        ToolbarButton {
            id: optionsButton
            text: i18n.tr("Options")
            iconSource: icon("settings")

            onTriggered: {
                PopupUtils.open(popoverComponent, optionsButton)
            }
        }

        locked: false
        opened: false
    }

    // Memories managment
    U1db.Database {
        id: storage
        path: "memoriesdb"
    }

    U1db.Document {
        id: memoriesDatabase

        database: storage
        docId: 'memories'
        create: true

        defaults: {
            memories: [{}]
        }
    }

    function saveMemories() {
        print("Saving Memories...")

        var memories = []

        for (var i = 0; i < memoryModel.count; i++) {
            var memory = memoryModel.get(i).mem
            memories.push(memory.toJSON())
        }

        var tempContents = {}
        tempContents = memoriesDatabase.contents
        tempContents.memories = JSON.stringify(memories)
        memoriesDatabase.contents = tempContents
    }

    function loadMemories() {
        print("Loading Memories...")
        var memories = JSON.parse(memoriesDatabase.contents.memories)
        for(var i = 0; i < memories.length; i++) {
            newMemoryObject(memories[i])
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

    // Settings
    property string password

    U1db.Database {
        id: settingsDatabase
        path: "memories"
    }

    U1db.Document {
        id: settings

        database: settingsDatabase
        docId: 'settings'
        create: true

        defaults: {
            password: ""
        }
    }

    function getSetting(name) {
        var tempContents = {};
        tempContents = settings.contents
        return tempContents.hasOwnProperty(name) ? tempContents[name] : settings.defaults[name]
    }

    function saveSetting(name, value) {
        if (getSetting(name) !== value) {
            print(name, "=>", value)
            var tempContents = {}
            tempContents = settings.contents
            tempContents[name] = value
            settings.contents = tempContents

            reloadSettings()
        }
    }

    function reloadSettings() {
        password = getSetting("password")
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
}
