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
            iconSource: "../resources/images/import-image.png"
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
                        source: "../resources/images/close_badge.png"
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
            console.log("Not implemented feature.");
        }

        function selectPhoto() {
            PopupUtils.open(Qt.resolvedUrl("./PhotoChooser.qml"), photoRow);
        }

        function addPhoto(filename) {
            photos.push(filename);
            // Update the model manually, since push() doesn't trigger
            // the *Changed event
            repeater.model = photos
        }

        function removePhoto(index) {
            photos.splice(index, 1);
            repeater.model = photos
        }
    }

    onPhotosChanged: {
        repeater.model = photos
    }

    function addPhoto(path) {
        photoRow.addPhoto(path)
    }
}
