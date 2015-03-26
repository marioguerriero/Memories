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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db

import "components"

MainView {
    id: mainView

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    applicationName: "com.ubuntu.developer.mefrio.memories"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    automaticOrientation: true

    width: units.gu(110)
    height: units.gu(75)

    property bool wideAspect: width > units.gu(80)
    property bool showToolbar: height > units.gu(75)

    backgroundColor: "#464646"

	// Use new toolbar
    useDeprecatedToolbar: false

    // Translate the launcher description
    property string description: i18n.tr("Keep track of your best moments with your hands")

	// Saving window state
    StateSaver.properties: "height, width"

	// New properties of this page
    readonly property real minimumWidth: units.gu(50)
    readonly property real minimumHeight: units.gu(75)

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

        AboutPage {
            id: aboutPage
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

        onCurrentPageChanged: {
            // Stop Camera when you don't need it
            if(currentPage != cameraPage)
                cameraPage.stop()
            else
                cameraPage.start()
        }
    }

	Component.onCompleted: {
		// When root component is completed the StateSaver restore it to previous dimensions.
        // If it is too small, set height and width to a proper size.
        if((mainView.width < minimumWidth) || (mainView.height < minimumHeight)){
            mainView.width = minimumWidth
            mainView.height = minimumHeight
        }
	}

    // Memories managment
    U1db.Database {
        id: storage
        path: "memories-storage.db"
    }

    U1db.Document {
        id: memoriesDatabase

        database: storage
        docId: "memories-settings.db"
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

    // Helper functions
    function newMemory() {
        memoryEditPage.clear()
        stack.push(memoryEditPage)
    }

    function truncate(name, width, unit) {
        unit = typeof unit === "undefined" ? units.gu(2) : unit
        if (name.length > width / unit) {
            name = name.substring(0, width / (unit + units.gu(0.2)));
            name += "...";
        }
        return name;
    }

    function icon(name) {
        return "/usr/share/icons/ubuntu-mobile/actions/scalable/" + name + ".svg"
    }

    function image(name) {
        return "../../resources/images/" + name
    }
}
