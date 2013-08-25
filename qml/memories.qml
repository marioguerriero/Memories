import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.HUD 1.0 as HUD
import Memories 0.1
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
    
    width: units.gu(110)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    property bool showToolbar: height > units.gu(75)

    headerColor: "#414141"
    backgroundColor: "#696969"
    footerColor: "#929292"

    // HUD
    HUD.HUD {
        applicationIdentifier: "memories"
        HUD.Context {
            HUD.Action {
                label: i18n.tr("Quit")
                keywords: i18n.tr("Quit;Exit")
                onTriggered: Qt.quit()
            }
            HUD.Action {
                label: i18n.tr("New Memory")
                keywords: i18n.tr("New;Add")
                onTriggered : newMemory()
            }
            HUD.Action {
                label: i18n.tr("Grid Layout")
                keywords: i18n.tr("Grid")
                onTriggered : homePage.saveSetting("showGrid", true)
            }
            HUD.Action {
                label: i18n.tr("List Layout")
                keywords: i18n.tr("List")
                onTriggered : homePage.saveSetting("showGrid", false)
            }
            HUD.Action {
                label: i18n.tr("Set a Password")
                keywords: i18n.tr("Password")
                onTriggered : homePage.editPassword()
            }
        }
    }

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

    // from Memories library
    Utils {
        id: utils
    }

    // Helper functions
    function newMemory() {
        memoryEditPage.clear()
        stack.push(memoryEditPage)
    }

    function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }

    function image(name) {
        return "../../resources/images/" + name
    }
}
