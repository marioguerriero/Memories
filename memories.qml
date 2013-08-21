import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import "components"
import "components/MD5.js" as Crypto

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
    
    width: units.gu(110)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)

    headerColor: "#414141"
    backgroundColor: "#696969"
    footerColor: "#929292"

    PageStack {
        id: stack
        Component.onCompleted: {
            homePage.reloadSettings()
            push(homePage)
            homePage.loadMemories()
            // Is there a password??
            if(homePage.password != homePage.nullPassword)
                PopupUtils.open(Qt.resolvedUrl("./components/UnlockDialog.qml"), homePage);
            else
                homePage.locked = false
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

        CameraPage {
            id: cameraPage
        }

        onCurrentPageChanged: {
            // Stop Camera when you don't need it
            if(currentPage != cameraPage)
                cameraPage.stop()
            else
                cameraPage.start()
        }
    }

    // Helper functions
    function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }
}
