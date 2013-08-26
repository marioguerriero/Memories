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
import Ubuntu.Components.ListItems 0.1 as ListItem

Flickable {
    id: flickable

    anchors {
        left: parent.left
        right: parent.right
    }

    height: photoRow.height

    contentWidth: photoRow.width
    interactive: contentWidth > width

    flickableDirection: Flickable.HorizontalFlick

    // Component properties
    property var photos: [ ]
    property bool editable: true
    property int iconSize: units.gu(8)

    property int currentIndex: 0

    Row {
        id: photoRow
        spacing: units.gu(2)

        Button {
            iconSource: image("import-image.png")
            height: iconSize
            width: height

            visible: editable

            onClicked: photoRow.selectPhoto();
        }

        Repeater {
            id: repeater
            model: [ ]

            delegate: UbuntuShape {
                id: photo
                height: iconSize
                width: height

                property int idx;

                image: Image {
                    source: modelData
                    fillMode: Image.PreserveAspectCrop
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        idx = index;
                        photoRow.showPhoto(idx);
                    }
                }

                // Close item
                MouseArea {
                    id: closeItem
                    objectName: "closeItem"
                    width: units.gu(3)
                    height: units.gu(3)

                    visible: editable

                    Image {
                        width: parent.width
                        height: parent.height
                        anchors.fill: parent
                        source: "../../resources/images/close_badge.png"
                    }

                    onClicked: {
                        photos.splice(photo.idx, 1);
                        repeater.model = photos
                    }
                }

                UbuntuNumberAnimation on opacity { from: 0; to: 100; }

            }
        }

        function showPhoto(index) {
            console.log("Not implemented feature.")
        }

        function selectPhoto() {
            PopupUtils.open(Qt.resolvedUrl("./PhotoChooser.qml"), photoRow);
        }

        function addPhoto(filename) {
            photos.push(filename)
            // Update the model manually, since push() doesn't trigger
            // the *Changed event
            repeater.model = photos
        }

        function removePhoto(index) {
            photos.splice(index, 1)
            repeater.model = photos
        }
    }

    onPhotosChanged: {
        for(var n = 0; n < photos.length; n++)
            if(!utils.fileExists(photos[n]))
                photos.splice(n, 1)

        repeater.model = photos
    }

    function addPhoto(path) {
        photoRow.addPhoto(path)
    }
}
