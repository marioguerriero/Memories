import QtQuick 2.0
import Ubuntu.Components 0.1
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
        Component.onCompleted: push(home);

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

            Column {
                spacing: units.gu(1)
                anchors {
                    margins: units.gu(2)
                    fill: parent
                }

                Text {
                    id: label
                    objectName: "label"

                    text: i18n.tr("No memories were found")
                }
                // List
                ListModel {
                    id: model
                    onRowsInserted: {
                        label.visible = false
                    }
                }

                ListView {
                    id: list
                    anchors.fill: parent
                    model: model
                    delegate: MemoryItem {text:name}
                }
                Scrollbar {
                    flickableItem: list
                    align: Qt.AlignTrailing
                }
            }

            tools: Toolbar {}
        }
    }
}
