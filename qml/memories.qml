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
import Ubuntu.OnlineAccounts 0.1
import Friends 0.1

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

    headerColor: "#464646"
    backgroundColor: "#797979"
    footerColor: "#808080"

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

    // Friends social network support
    ListModel {
        id: accountsModel
    }

    FriendsDispatcher {
        id: friends
        onSendComplete: {
            if (success) {
                console.log ("Send completed successfully");
            } else {
                console.log ("Send failed: " + errorMessage.split("str: str:")[1]);
                // TODO: show some error dialog/widget
            }
        }
        onUploadComplete: {
            if (success) {
                console.log ("Upload completed successfully");
            } else {
                console.log ("Upload failed: " + errorMessage);
                // TODO: show some error dialog/widget
            }
        }
    }

    AccountServiceModel {
        id: accounts
        serviceType: "microblogging"
        Component.onCompleted: {
            for(var i=0; i<accounts.count; i++) {
                var displayName = accounts.get(i, "displayName");
                var accountId = accounts.get(i, "accountId");
                var serviceName = accounts.get(i, "serviceName");
                var features = friends.featuresForProtocol(serviceName.toLowerCase().replace(".",""));
                if(features.indexOf("send") > -1) {
                    console.log (serviceName + " Supports send");
                    accountsModel.append({
                        "displayName": displayName,
                        "id": accountId,
                        "provider": serviceName,
                        "iconName": serviceName.toLowerCase().replace(".",""),
                        "sendEnabled": true
                    });
                }
            }
        }
    }

    // Pages
    PageStack {
        id: stack
        Component.onCompleted: {
            reloadSettings()
            push(tabs)
            homePage.loadMemories()
            // Is there a password??
            if(password != nullPassword)
                PopupUtils.open(Qt.resolvedUrl("./components/UnlockDialog.qml"), homePage);
            else
                homePage.locked = false
        }

        Component.onDestruction: {
            homePage.saveMemories()
        }

        // Pages
        //HomePage {
        //    id: homePage
        //}

        MemoryPage {
            id: memoryPage
        }

        MemoryEdit {
            id: memoryEditPage
        }

        GalleryPage {
            id: galleryPage
        }

        CameraPage {
            id: cameraPage
        }

        Tabs {
            id: tabs

            Tab {
                title: page.title
                page: HomePage {
                    id: homePage
                    visible: true
                }
            }

            Tab {
                title: page.title
                page: SettingsPage {
                    id: settingsPage
                }
            }
        }

//        Tabs {
//            id: tabs

//            Tab {
//                title: page.title
//                page: MemoryEdit {
//                    id: memoryEditPage
//                }
//            }

//            Tab {
//                title: page.title
//                page: MemoryPage {
//                    id: memoryPage
//                }
//            }

//            Tab {
//                title: page.title
//                page: HomePage {
//                    id: homePage
//                }
//            }

//            Tab {
//                title: page.title
//                page: GalleryPage {
//                    id: galleryPage
//                }
//            }

//            Tab {
//                title: page.title
//                page: CameraPage {
//                    id: cameraPage
//                }
//            }

//            Tab {
//                title: page.title
//                visible: false
//                page: Page {
//                    visible: false
//                    title:"test"
//                    Rectangle {anchors.fill:parent; color:"red"}
//                }
//            }
//        }

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
        path: "memories-storage"
    }

    U1db.Document {
        id: memoriesDatabase

        database: storage
        docId: "memories-settings"
        create: true

        defaults: {
            memories: [{}]
        }
    }

    // Settings
    property string password
    property string nullPassword: ""

    property bool showGrid: false

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
        var tmp = getSetting("password")
        password =  tmp ? tmp : nullPassword

        showGrid = getSetting("showGrid") ? "undefined" : false
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
