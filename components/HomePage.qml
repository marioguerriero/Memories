import QtQuick 2.0
import Ubuntu.Components 0.1
import U1db 1.0 as U1db

Page {
    id: home
    title: {
        var string = i18n.tr("Memories")
        var title = ""
        var length = string.length
        var pixel = 3 // The approximative size of each character
        var dif = mainView.width / (length*pixel) // -1 as it is for spacing

        for(var n = 0; n < string.length; n++) {
            if(dif < length && n >= (dif-3))
                title = string.substring(0, dif-2) + "..."
            else
                title = string
        }
        return title
    }
    visible: false

    Label {
        id: label
        objectName: "label"
        anchors.centerIn: parent
        fontSize: "large"
        text: i18n.tr("No memories!")
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
        }
        onRowsRemoved: {
            label.visible = (memoryModel.count == 0)
        }
    }
    ListView {
        id: list
        anchors.fill: parent
        model: memoryModel
        delegate: MemoryItem {
            memory: mem
        }
    }
    Scrollbar {
        flickableItem: list
        align: Qt.AlignTrailing
    }

    tools: ToolbarItems {

        ToolbarButton {
            text: i18n.tr("New")
            iconSource: icon("add")

            onTriggered: {
                memoryEditPage.clear()
                stack.push(memoryEditPage)
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
        filter("")
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
    function filter(filter) {
        for(var i = 0; i < memoryModel.count; i++) {
            var tags = memoryModel.get(i).mem.getTags()
            for(var n = 0; n < tags.length; n++) {
                var tag = tags[n].replace(" ", "")
                //tags[n].replace(" ", "")
                //print(tag)
                //memoryModel.get(i).visible = false
            }
        }
    }
}
