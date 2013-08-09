import QtQuick 2.0
import Ubuntu.Components 0.1
import U1db 1.0 as U1db
import "components"

MainView {
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"
    
    // Note! applicationName needs to match the .desktop filename
    applicationName: "memories"
    
    /* 
     This property enables the application to change orientation 
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true
    
    width: units.gu(50)
    height: units.gu(75)
    
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
            ListModel {
                id: model
                onRowsInserted: {
                    label.visible = false
                    print ("Add to database!!!")
                }
                onRowsRemoved: {
                    label.visible = (model.count == 0)
                    print ("Delete from database!!!")
                }
            }

            ListView {
                id: list
                anchors.fill: parent
                model: model
                delegate: MemoryItem {
                    text: name
                    tags: tg
                    description: desc
                    date: dt
                    location: loc
                    weather: wt
                    index:count
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
            var memory = model.get(i).modelData
            memories.push(memory.toJSON())
        }

        var tempContents = {}
        tempContents = memoriesDatebase.contents
        tempContents.memories = JSON.stringify(memories)
        memoriesDatebase.contents = tempContents
    }

    function loadMemories() {
        var memories = JSON.parse(memoriesDatebase.contents.memories)
        for (var i = 0; i < memories.length; i++) {
            newMemoryObject(memories[i])
        }
    }

    function newMemoryObject(args) {
        var memory = memoryComponent.createObject(memoriesModel, args)

        if (memory === null) {
            console.log("Unable to create memory object!")
        }

        memoriesModel.append({"modelData": memory})
    }
}
