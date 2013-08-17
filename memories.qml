import QtQuick 2.0
import Ubuntu.Components 0.1
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
    automaticOrientation: true
    
    width: units.gu(100)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    state: wideAspect ? "wide" : ""
    states: [
        State {
            name: "wide"
            PropertyChanges {
                target: stack
                width: units.gu(40)
                anchors {
                    fill: null
                    top: parent.top
                    bottom: parent.bottom
                }
            }
            PropertyChanges {
                target: homePage
                x: stack.width
                width: stack.parent.width - x
                anchors {
                    left: undefined
                    right: undefined
                    bottom: undefined
                }
                clip: true
                visible: true
            }
        }
    ]

    headerColor: "#414141"
    backgroundColor: "#696969"
    footerColor: "#929292"

    PageStack {
        id: stack
        Component.onCompleted: {
            push(homePage)
            homePage.loadMemories()
        }
        Component.onDestruction: {
            homePage.saveMemories()
        }

        // Pages
        MemoryEdit{
            id: memoryEditPage
        }

        MemoryPage {
            id: memoryPage
        }

        HomePage {
            id: homePage
        }

        /*CameraPage {
            id: cameraPage
        }*/
    }

    // Helper functions
    function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }
    /*function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/apps/144/" + name + ".png"
    }*/
}
