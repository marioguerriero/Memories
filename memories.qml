import QtQuick 2.0
import Ubuntu.Components 0.1
import U1db 1.0 as U1db
import "components"

MainView {
    id: mainView

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename
    applicationName: "Memories"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(50)
    height: units.gu(75)
    
    headerColor: "#414141"
    backgroundColor: "#696969"
    footerColor: "#929292"

    PageStack {
        id: stack
        Component.onCompleted: {
            push(home)
            loadMemories()
        }
        Component.onDestruction: {
            saveMemories()
        }

        // Different pages
        NewMemory {
            id: newMemory
        }

        MemoryPage {
            id: memoryPage
        }

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

            // List
            Component {
                id: memoryComponent

                Memory {

                }
            }
            ListModel {
                id: model
                onRowsInserted: {
                    label.visible = false
                }
                onRowsRemoved: {
                    label.visible = (model.count == 0)
                }
            }
            ListView {
                id: list
                anchors.fill: parent
                model: model
                delegate: MemoryItem {
                    memory:mem
                }
            }
            Scrollbar {
                flickableItem: list
                align: Qt.AlignTrailing
            }
            tools: Toolbar {}
        }
    }

    // Memories managment
    U1db.Database {
        id: storage
        path: "memoriesdb"
    }

    U1db.Document {
        id: memoriesDatebase

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

        for (var i = 0; i < model.count; i++) {
            var memory = model.get(i).mem
            memories.push(memory.toJSON())
        }

        var tempContents = {}
        tempContents = memoriesDatebase.contents
        tempContents.memories = JSON.stringify(memories)
        memoriesDatebase.contents = tempContents
    }

    function loadMemories() {
        print("Loading Memories...")
        var memories = JSON.parse(memoriesDatebase.contents.memories)
        for (var i = 0; i < memories.length; i++) {
            newMemoryObject(memories[i])
        }
    }

    function newMemoryObject(args) {
        var memory = memoryComponent.createObject(model, args)

        if (memory === null) {
            console.log("Unable to create memory object!")
        }

        model.append({"mem": memory})
    }

    function removeMemory(memory) {
        for (var i = 0; i < model.count; i++) {
            var item = model.get(i).mem
            if (item === memory) {
                model.remove(i)
                item.destroy()
                return
            }
        }
    }

    // Helper functions
    function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }
}
