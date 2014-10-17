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
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Content 0.1

Flickable {
    id: flickable

    anchors {
        left: parent.left
        right: parent.right
    }

    height: photoGrid.height

    contentWidth: photoGrid.width
    interactive: contentWidth > width

    flickableDirection: Flickable.HorizontalFlick

    // Component properties
    property var photos: []
    property bool editable: true
    property int iconSize: units.gu(8)

    property int currentIndex: 0

    Grid {
        id: photoGrid
        spacing: units.gu(2)

        columns: wideAspect ? calculateColumns() : (editing ? photos.length + 1 : photos.length)
        // Used to get columns value according to the window width
        function calculateColumns() {
            var width = flickable.width
            var tmp = (width - iconSize)
            return Math.round(tmp / (iconSize))
        }

        Button {
            iconSource: image("import-image.png")
            height: iconSize
            width: height

            visible: editable

            onClicked: activeTransfer = picSourceSingle.request()
        }

        Button {
            iconSource: image("camera-white.png")
            height: iconSize
            width: height

            visible: editable

            onClicked: stack.push(cameraPage)
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
                        photoGrid.showPhoto(index);
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
                        photos.splice(index, 1);
                        repeater.model = photos
                    }
                }

                UbuntuNumberAnimation on opacity { from: 0; to: 100; }

            }
        }

        function showPhoto(index) {
            galleryPage.photos = photos
            galleryPage.showPhoto(index)
            stack.push(galleryPage)
        }

        function addPhoto(filename) {
            photos.push(filename.toString().replace("file://", ""))
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
        photoGrid.addPhoto(path)
    }

    // Content HUB
    property list<ContentItem> importItems
	property var activeTransfer

    ContentPeer {
    	id: picSourceSingle
    	contentType: ContentType.Pictures
    	handler: ContentHandler.Source
    	selectionType: ContentTransfer.Single
	}

	ContentTransferHint {
    	id: transferHint
		anchors.fill: parent
        activeTransfer: parent.activeTransfer
	}
  	
	Connections {
        target: parent.activeTransfer ? parent.activeTransfer : null
		onStateChanged: {
            if (activeTransfer.state === ContentTransfer.Charged) {
                importItems = activeTransfer.items;
				for(var i = 0; i < importItems.length; i++)
					addPhoto(importItems.get(i))			
			}
		}
	}
}
