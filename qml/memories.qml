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
import Ubuntu.Components.Popups 0.1
import U1db 1.0 as U1db
import Ubuntu.HUD 1.0 as HUD
import Memories 0.1
import "components"

MainView {
    id: mainView

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the .desktop filename
    applicationName: "memories"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    width: units.gu(110)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    property bool showToolbar: height > units.gu(75)

    headerColor: "#414141"
    backgroundColor: "#696969"
    footerColor: "#929292"

    // HUD
    HUD.HUD {
        applicationIdentifier: applicationName
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
